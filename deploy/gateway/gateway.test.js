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
      res.writeHead(200, { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*', 'Cache-Control': 'max-age=60' });
      res.end('{"ok":true}');
    });
  });
  const labPort = await listen(lab);
  const gateway = createGateway({ distDir, labPort, logFile: null, maxBodyBytes: 100, ...extra });
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
