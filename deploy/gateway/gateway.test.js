'use strict';
// Run with: node --test deploy/gateway/gateway.test.js
// A stub stands in for the lab server, so these check only what the gateway lets through.
const test = require('node:test');
const assert = require('node:assert/strict');
const http = require('http');
const fs = require('fs');
const os = require('os');
const path = require('path');
const { createGateway } = require('./server.js');

const listen = (server) => new Promise((resolve) => server.listen(0, '127.0.0.1', () => resolve(server.address().port)));

function send(port, { method = 'GET', path: p = '/', headers = {}, body } = {}) {
  return new Promise((resolve, reject) => {
    const req = http.request({ host: '127.0.0.1', port, method, path: p, headers }, (res) => {
      const chunks = [];
      res.on('data', (c) => chunks.push(c));
      res.on('end', () => resolve({ status: res.statusCode, headers: res.headers, body: Buffer.concat(chunks).toString() }));
    });
    req.on('error', reject);
    req.end(body);
  });
}

async function setup(t, extra = {}) {
  const { labStatus = 200, ...gatewayCfg } = extra;
  const distDir = fs.mkdtempSync(path.join(os.tmpdir(), 'gateway-dist-'));
  fs.mkdirSync(path.join(distDir, 'assets'));
  fs.writeFileSync(path.join(distDir, 'index.html'), '<!doctype html><title>portal</title>');
  fs.writeFileSync(path.join(distDir, 'assets', 'app-AbCd1234.js'), 'console.log(1)');
  fs.writeFileSync(path.join(distDir, 'assets', 'app-AbCd1234.js.map'), '{"secret":"source"}');
  fs.writeFileSync(path.join(distDir, 'favicon.png'), 'png');

  const seen = [];
  const lab = http.createServer((req, res) => {
    const chunks = [];
    req.on('data', (c) => chunks.push(c));
    req.on('end', () => {
      seen.push({ method: req.method, url: req.url, headers: req.headers, body: Buffer.concat(chunks).toString() });
      res.writeHead(labStatus, { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*', 'Cache-Control': 'max-age=60' });
      res.end('{"ok":true}');
    });
  });
  const labPort = await listen(lab);
  const gateway = createGateway({ distDir, labPort, logFile: null, maxBodyBytes: 100, ...gatewayCfg });
  const port = await listen(gateway);
  t.after(() => { gateway.close(); lab.close(); fs.rmSync(distDir, { recursive: true, force: true }); });
  return { port, seen };
}

test('serves the portal with security headers, SPA fallback and cache rules', async (t) => {
  const { port } = await setup(t);
  const index = await send(port, { path: '/' });
  assert.equal(index.status, 200);
  assert.equal(index.headers['cache-control'], 'no-store');
  assert.match(index.headers['content-security-policy'], /default-src 'self'/);
  assert.equal(index.headers['x-frame-options'], 'DENY');
  assert.equal(index.headers['x-content-type-options'], 'nosniff');
  assert.equal(index.headers['referrer-policy'], 'no-referrer');
  assert.match(index.headers['permissions-policy'], /camera=\(\)/);

  assert.equal((await send(port, { path: '/exam/instructions' })).body, index.body, 'client-side route falls back to index.html');
  assert.match((await send(port, { path: '/assets/app-AbCd1234.js' })).headers['cache-control'], /immutable/);
  assert.equal((await send(port, { path: '/assets/missing-AbCd1234.js' })).status, 404, 'a missing asset is not an HTML page');
});

test('never serves source maps', async (t) => {
  const { port } = await setup(t);
  for (const p of ['/assets/app-AbCd1234.js.map', '/assets/app-AbCd1234.js.MAP', '/assets/app-AbCd1234.js%2Emap', '/assets/app-AbCd1234.js.map?x=1', '/assets/app-AbCd1234.js.map.']) {
    assert.equal((await send(port, { path: p })).status, 404, p);
  }
});

test('forwards allowlisted routes and drops client-controlled time headers', async (t) => {
  const { port, seen } = await setup(t);
  const res = await send(port, {
    method: 'POST',
    path: '/api/student/login?x=1',
    headers: {
      'Content-Type': 'application/json', Authorization: 'Bearer abc',
      'X-Simulated-Time-Ms': '0', 'X-Effective-Time-Ms': '0', 'X-Bypass-Start-Check': '1', 'X-Forwarded-For': '9.9.9.9',
    },
    body: '{"usn":"U"}',
  });
  assert.equal(res.status, 200);
  assert.equal(res.headers['cache-control'], 'no-store');
  assert.equal(res.headers['access-control-allow-origin'], undefined);
  assert.equal(seen.length, 1);
  assert.equal(seen[0].url, '/api/student/login?x=1');
  assert.equal(seen[0].body, '{"usn":"U"}');
  assert.equal(seen[0].headers.authorization, 'Bearer abc');
  for (const name of ['x-simulated-time-ms', 'x-effective-time-ms', 'x-bypass-start-check', 'x-forwarded-for']) {
    assert.equal(seen[0].headers[name], undefined, name);
  }
});

test('X-Gateway-Origin is set by the gateway on every proxied request, whatever the client sent', async (t) => {
  const { port, seen } = await setup(t);
  const attempts = [{}, { 'X-Gateway-Origin': 'forged' }, { 'x-gateway-origin': '' }, { 'X-GATEWAY-ORIGIN': 'a', 'x-gateway-origin': 'b' }];
  for (const headers of attempts) {
    await send(port, { path: '/api/health', headers });
    await send(port, { method: 'POST', path: '/api/instructor/login', headers: { ...headers, 'Content-Type': 'application/json' }, body: '{}' });
  }
  assert.equal(seen.length, attempts.length * 2);
  for (const request of seen) assert.equal(request.headers['x-gateway-origin'], 'gateway', request.url);
});

test('a client-sent X-Gateway-Origin cannot reach a staff route', async (t) => {
  const { port, seen } = await setup(t);
  const staff = [['GET', '/api/monitoring/sessions'], ['GET', '/api/results/download'], ['POST', '/api/results/finalize'],
    ['GET', '/api/labs/servers'], ['GET', '/api/package/receipt'], ['POST', '/api/test/reset-submissions'], ['POST', '/api/package/import']];
  for (const [method, p] of staff) {
    for (const value of ['gateway', 'forged', '']) {
      const res = await send(port, { method, path: p, headers: { 'X-Gateway-Origin': value } });
      assert.equal(res.status, 404, `${method} ${p} with X-Gateway-Origin "${value}"`);
    }
  }
  assert.equal(seen.length, 0, 'nothing was forwarded to the lab server');
});

test('staff, system and test routes are a plain 404 and never reach the lab server', async (t) => {
  const { port, seen } = await setup(t);
  const routes = [
    ['POST', '/api/test/reset-submissions'], ['POST', '/api/test/expire-session'], ['POST', '/api/package/import'],
    ['POST', '/api/package/manual-import'], ['POST', '/api/packages/activate'], ['GET', '/api/package/list'],
    ['GET', '/api/results/download'], ['POST', '/api/results/finalize'], ['POST', '/api/results/transfer-to-central'],
    ['GET', '/api/monitoring/sessions'], ['GET', '/api/monitoring/stream'], ['GET', '/api/labs/servers'],
    ['POST', '/api/recovery/report-crash'], ['POST', '/api/recovery/consume-token'], ['POST', '/api/security/provision-unlock-credential'],
    ['GET', '/api/student/login'], ['POST', '/api/health'], ['OPTIONS', '/api/student/login'], ['GET', '/api'], ['GET', '/api/'],
  ];
  for (const [method, p] of routes) {
    const res = await send(port, { method, path: p });
    assert.equal(res.status, 404, `${method} ${p}`);
    assert.equal(res.body, 'Not Found', `${method} ${p}`);
  }
  assert.equal(seen.length, 0);
});

test('path tricks do not reach the lab server', async (t) => {
  const { port, seen } = await setup(t);
  for (const p of ['/api/student/../package/import', '/api/%73tudent/login', '/api/student/login/', '/api/v1/student/login',
    '/api/student//login', '/api/./student/login', '/api/student/login%00', '/lab-api/student/login', '//api/student/login',
    '/api/student\\login', 'http://127.0.0.1/api/student/login']) {
    const res = await send(port, { method: 'POST', path: p });
    assert.notEqual(res.headers['content-type'], 'application/json', p);
  }
  assert.equal(seen.length, 0);
});

test('rejects bodies over the limit', async (t) => {
  const { port, seen } = await setup(t);
  const declared = await send(port, { method: 'POST', path: '/api/student/login', headers: { 'Content-Type': 'application/json' }, body: 'x'.repeat(200) });
  assert.equal(declared.status, 413);
  const chunked = await send(port, { method: 'POST', path: '/api/student/login', headers: { 'Transfer-Encoding': 'chunked' }, body: 'x'.repeat(200) });
  assert.equal(chunked.status, 413);
  assert.equal(seen.length, 0);
});

test('answers 502 when the lab server is down', async (t) => {
  const down = http.createServer();
  const downPort = await listen(down);
  down.close();
  const { port } = await setup(t, { labPort: downPort });
  const res = await send(port, { path: '/api/health' });
  assert.equal(res.status, 502);
  assert.equal(JSON.parse(res.body).errorCode, 'LAB_SERVER_UNAVAILABLE');
});

test('only the configured header, holding one IP, becomes the trusted client address', async (t) => {
  const { port, seen } = await setup(t, { clientIpHeader: 'x-test-client' });
  const get = (headers) => send(port, { path: '/api/health', headers });
  await get({ 'X-Test-Client': '203.0.113.7' });
  await get({ 'X-Test-Client': '2001:db8::7', 'X-Gateway-Client': '6.6.6.6' });
  await get({ 'X-Gateway-Client': '6.6.6.6' });
  await get({ 'X-Test-Client': '1.1.1.1, 2.2.2.2', 'X-Gateway-Client': '6.6.6.6' });
  await get({ 'X-Test-Client': 'not-an-ip' });
  await get({ 'X-Forwarded-For': '5.5.5.5' });
  assert.deepEqual(seen.map((r) => r.headers['x-gateway-client']), ['203.0.113.7', '2001:db8::7', undefined, undefined, undefined, undefined]);
});

test('without CLIENT_IP_HEADER no address is trusted, whatever the client sends', async (t) => {
  const { port, seen } = await setup(t);
  await send(port, { path: '/api/health', headers: { 'X-Forwarded-For': '5.5.5.5', 'X-Real-IP': '5.5.5.5', 'X-Gateway-Client': '6.6.6.6' } });
  assert.equal(seen[0].headers['x-gateway-client'], undefined);
});

test('failed logins from one trusted client are cut off after 20 a minute, others are not', async (t) => {
  const { port, seen } = await setup(t, { clientIpHeader: 'x-test-client', labStatus: 401 });
  const login = (ip, route = '/api/student/login') => send(port, { method: 'POST', path: route, headers: { 'X-Test-Client': ip, 'Content-Type': 'application/json' }, body: '{}' });
  for (let i = 0; i < 20; i++) assert.equal((await login('203.0.113.7', i % 2 ? '/api/instructor/login' : '/api/student/login')).status, 401);
  const blocked = await login('203.0.113.7');
  assert.equal(blocked.status, 429);
  assert.equal(JSON.parse(blocked.body).errorCode, 'RATE_LIMITED');
  assert.equal(seen.length, 20, 'the blocked attempt never reached the lab server');
  assert.equal((await login('203.0.113.8')).status, 401, 'another client is unaffected');
  assert.equal((await send(port, { path: '/api/health', headers: { 'X-Test-Client': '203.0.113.7' } })).status, 401, 'only the login routes are limited');
});

test('with no trusted address the gateway does not limit logins itself', async (t) => {
  const { port, seen } = await setup(t, { labStatus: 401 });
  for (let i = 0; i < 25; i++) assert.equal((await send(port, { method: 'POST', path: '/api/student/login', body: '{}' })).status, 401);
  assert.equal(seen.length, 25);
});

test('the access log shows which address headers arrive and never holds tokens or bodies', async (t) => {
  const logFile = path.join(fs.mkdtempSync(path.join(os.tmpdir(), 'gateway-log-')), 'logs', 'gateway.log');
  const { port } = await setup(t, { logFile, clientIpHeader: 'x-test-client' });
  await send(port, {
    method: 'POST', path: '/api/student/login?usn=QUERYSECRET',
    headers: { 'X-Test-Client': '203.0.113.7', 'X-Forwarded-For': '198.51.100.4', 'X-Odd-Thing': 'v', Authorization: 'Bearer TOKENSECRET', 'Content-Type': 'application/json' },
    body: '{"dateOfBirth":"BODYSECRET"}',
  });
  await send(port, { path: '/api/monitoring/sessions' });
  let log = '';
  for (let i = 0; i < 20 && !log.includes('/api/monitoring/sessions'); i++) {
    await new Promise((resolve) => setTimeout(resolve, 50));
    log = fs.readFileSync(logFile, 'utf8');
  }
  assert.match(log, /START client-address-header=x-test-client/);
  assert.match(log, /HEADER-SEEN x-forwarded-for = 198\.51\.100\.4 \(socket /);
  assert.match(log, /HEADER-SEEN x-test-client = 203\.0\.113\.7/);
  assert.match(log, /HEADER-SEEN x-odd-thing \(socket /, 'a header that is not address-like is named but its value is not logged');
  assert.match(log, / POST \/api\/student\/login 200 203\.0\.113\.7\n/);
  assert.match(log, / GET \/api\/monitoring\/sessions 404 -\n/);
  for (const secret of ['TOKENSECRET', 'BODYSECRET', 'QUERYSECRET']) assert.doesNotMatch(log, new RegExp(secret));
});

// ---- admin and coe profiles: same gateway, forwarding to central ----
const TOKEN = 'a'.repeat(64);
const bearer = { authorization: `Bearer ${TOKEN}` };

test('admin profile forwards only its own routes and answers 404 to everything else', async (t) => {
  const { port, seen } = await setup(t, { profile: 'admin' });
  assert.equal((await send(port, { path: '/api/v1/health' })).status, 200);
  assert.equal((await send(port, { method: 'POST', path: '/api/v1/auth/login', body: '{}' })).status, 200);
  assert.equal((await send(port, { path: '/api/v1/hod/subjects', headers: bearer })).status, 200);
  assert.equal((await send(port, { method: 'PATCH', path: '/api/v1/principal/hods/7', headers: bearer, body: '{}' })).status, 200);
  const before = seen.length;
  for (const [method, p] of [['POST', '/api/v1/auth/coe/login'], ['GET', '/api/v1/examinations/scheduled'], ['GET', '/api/v1/labs/servers'],
    ['GET', '/api/v1/monitoring/sessions'], ['POST', '/api/v1/events/broadcast'], ['POST', '/api/v1/results/import-package'],
    ['GET', '/api/v1/coe/anything'], ['GET', '/lab-api/health'], ['GET', '/api/health'], ['GET', '/api/v1/hod'], ['GET', '/api/v1/hodx/a']]) {
    assert.equal((await send(port, { method, path: p, headers: bearer })).status, 404, `${method} ${p}`);
  }
  assert.equal(seen.length, before, 'none of them reached central');
});

test('coe profile forwards only the routes the COE portal calls', async (t) => {
  const { port, seen } = await setup(t, { profile: 'coe' });
  assert.equal((await send(port, { method: 'POST', path: '/api/v1/auth/coe/login', body: '{}' })).status, 200);
  assert.equal((await send(port, { path: '/api/v1/examinations/EXAM-CS501-12/sittings/S1/question-paper-archive/data', headers: bearer })).status, 200);
  assert.equal((await send(port, { method: 'POST', path: '/api/v1/examinations/7/prepare-and-send-package', headers: bearer, body: '{}' })).status, 200);
  const before = seen.length;
  for (const [method, p] of [['POST', '/api/v1/auth/login'], ['GET', '/api/v1/hod/subjects'], ['GET', '/api/v1/principal/hods'],
    ['GET', '/api/v1/labs/servers'], ['GET', '/api/v1/monitoring/sessions'], ['POST', '/api/v1/events/broadcast'],
    ['POST', '/api/v1/results/import-package'], ['GET', '/api/v1/examinations'], ['DELETE', '/api/v1/examinations/7/sittings/9']]) {
    assert.equal((await send(port, { method, path: p, headers: bearer })).status, 404, `${method} ${p}`);
  }
  assert.equal(seen.length, before, 'none of them reached central');
});

test('staff profiles turn away a caller with no valid token before reading its body', async (t) => {
  const { port, seen } = await setup(t, { profile: 'admin' });
  for (const headers of [{}, { authorization: 'Bearer short' }, { authorization: `Basic ${TOKEN}` }]) {
    const res = await send(port, { path: '/api/v1/hod/subjects', headers });
    assert.equal(res.status, 401);
    assert.equal(JSON.parse(res.body).errorCode, 'UNAUTHORIZED');
  }
  assert.equal((await send(port, { path: `/api/v1/hod/subjects?token=${TOKEN}` })).status, 401, 'a query token is for the event stream only');
  assert.equal(seen.length, 0);
  assert.equal((await send(port, { path: `/api/v1/events?token=${TOKEN}` })).status, 200, 'the event stream may carry it in the query');
  assert.equal((await send(port, { path: '/api/v1/events?token=nothex' })).status, 401);
});

test('staff wildcard routes ignore dot segments and encoded dots, slashes and backslashes', async (t) => {
  const { port, seen } = await setup(t, { profile: 'admin' });
  for (const p of ['/api/v1/hod/../auth/login', '/api/v1/hod/%2e%2e/auth/login', '/api/v1/hod/%2E%2E/principal/hods', '/api/v1/hod/a%2fb',
    '/api/v1/hod/a%5cb', '/api/v1/hod/./x', '/api/v1/hod//x', '/api/v1/hod/', '/api/v1/hod/a/../b']) {
    assert.equal((await send(port, { path: p, headers: bearer })).status, 404, p);
  }
  assert.equal(seen.length, 0);
  assert.equal((await send(port, { path: '/api/v1/hod/students/4MH24CS001', headers: bearer })).status, 200, 'an ordinary id still passes');
});

test('staff profiles forward only the safe headers, mark the request as from a gateway, and never pass time headers', async (t) => {
  const { port, seen } = await setup(t, { profile: 'coe', clientIpHeader: 'x-real-ip' });
  await send(port, { method: 'POST', path: '/api/v1/auth/coe/login', body: '{}', headers: {
    'content-type': 'application/json', 'x-gateway-origin': 'nope', 'x-gateway-client': '9.9.9.9', 'x-real-ip': '203.0.113.7',
    'x-simulated-time-ms': '1', 'x-bypass-start-check': 'true', 'x-effective-time-ms': '2', cookie: 'a=b' } });
  const h = seen[0].headers;
  assert.equal(h['x-gateway-origin'], 'gateway');
  assert.equal(h['x-gateway-client'], '203.0.113.7', 'the trusted address replaces whatever the client sent');
  for (const name of ['x-simulated-time-ms', 'x-bypass-start-check', 'x-effective-time-ms', 'cookie']) assert.equal(h[name], undefined, name);
});

test('a staff gateway answers 502 CENTRAL_UNAVAILABLE when central is down', async (t) => {
  const down = http.createServer();
  const downPort = await listen(down);
  await new Promise((r) => down.close(r));
  const { port } = await setup(t, { profile: 'coe', labPort: downPort });
  const res = await send(port, { method: 'POST', path: '/api/v1/auth/coe/login', body: '{}' });
  assert.equal(res.status, 502);
  assert.equal(JSON.parse(res.body).errorCode, 'CENTRAL_UNAVAILABLE');
});

test('staff logins are cut off after 20 failures a minute from one trusted client and the body cap is 16 KB', async (t) => {
  const { port } = await setup(t, { profile: 'admin', clientIpHeader: 'x-real-ip', labStatus: 401, maxBodyBytes: 60 * 1024 * 1024 });
  const login = (ip, body = '{}') => send(port, { method: 'POST', path: '/api/v1/auth/login', body, headers: { 'x-real-ip': ip } });
  for (let i = 0; i < 20; i++) assert.equal((await login('198.51.100.1')).status, 401);
  assert.equal((await login('198.51.100.1')).status, 429);
  assert.equal((await login('198.51.100.2')).status, 401, 'another client is unaffected');
  assert.equal((await login('198.51.100.3', 'x'.repeat(17 * 1024))).status, 413);
});
