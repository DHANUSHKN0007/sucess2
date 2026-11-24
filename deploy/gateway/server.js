'use strict';
// A public entry point: serves one built portal and forwards only that portal's allowlisted API routes to one backend.
// One instance per portal, chosen by GATEWAY_PROFILE: "student" forwards to the lab server, "admin" and "coe" forward to
// the central backend. It listens on loopback only; Tailscale is the way in.
const http = require('http');
const fs = require('fs');
const net = require('net');
const path = require('path');

// Built from the route table in DEPLOYMENT.md and cross-checked against every /api call in the portal source.
// LOCAL STAFF, SYSTEM and TEST routes are deliberately absent: anything not listed is a plain 404.
const ALLOWED = new Set([
  'GET /api/health',
  'POST /api/student/login',
  'POST /api/student/logout',
  'GET /api/student/instructions',
  'GET /api/student/exam-session',
  'GET /api/student/exam/questions',
  'POST /api/student/exam/start',
  'GET /api/student/exam/state',
  'POST /api/student/exam/answers',
  'POST /api/student/exam/submit',
  'POST /api/student/exam/heartbeat',
  'POST /api/security/violation',
  'POST /api/security/unlock',
  'POST /api/instructor/login',
  'POST /api/instructor/logout',
  'GET /api/recovery/relogin-authorisations',
  'POST /api/recovery/relogin-authorisations/approve',
  'POST /api/recovery/relogin-authorisations/consume',
  'GET /api/recovery/overview',
  'GET /api/recovery/transfers',
  'GET /api/recovery/audit-logs',
  'GET /api/recovery/config',
]);

// A staff route is "METHOD /path". "*" stands for exactly one path segment and a trailing "/**" for anything below it.
// A segment may not be dot-only or hold an encoded dot, slash or backslash, so no spelling climbs out of a listed prefix.
const SEGMENT = "(?:[A-Za-z0-9_~!$&'()*+,;=:@-]|\\.(?!\\.*(?:/|$))|%(?!2[eEfF]|5[cC])[0-9A-Fa-f]{2})+";
const escapeRe = (s) => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
function compileRoutes(list) {
  const exact = new Set();
  const patterns = [];
  for (const entry of list) {
    const [method, route] = entry.split(' ');
    if (!route.includes('*')) { exact.add(entry); continue; }
    const parts = route.split('/').map((seg) => (seg === '**' ? `${SEGMENT}(?:/${SEGMENT})*` : seg === '*' ? SEGMENT : escapeRe(seg)));
    patterns.push({ method, re: new RegExp(`^${parts.join('/')}$`) });
  }
  return (method, pathname) => exact.has(`${method} ${pathname}`) || patterns.some((p) => p.method === method && p.re.test(pathname));
}

const ALL_METHODS = ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'];

// Admin portal (principal, HOD and admin users). Every call it makes is under /auth, /principal or /hod, plus the health
// probe and the event stream; the token and role checks on each are central's.
const ADMIN_ROUTES = [
  'GET /api/v1/health', 'GET /api/v1/events',
  'POST /api/v1/auth/login', 'POST /api/v1/auth/logout', 'GET /api/v1/auth/me', 'POST /api/v1/auth/change-password',
  'PATCH /api/v1/auth/profile', 'PATCH /api/v1/auth/preferences/theme',
  ...ALL_METHODS.flatMap((m) => [`${m} /api/v1/principal/**`, `${m} /api/v1/hod/**`]),
];

// COE portal: its central calls, listed from every centralRequest/centralUploadRequest/centralBlobRequest in its source.
// Its seven lab-server calls (monitoring, workstation-bind, pc-recovery, verify-unlock, labs/servers, package-receipt) are
// absent on purpose: the lab server answers staff routes only to this PC.
const COE_ROUTES = [
  'GET /api/v1/health', 'GET /api/v1/events',
  'POST /api/v1/auth/coe/login', 'POST /api/v1/auth/coe/logout', 'POST /api/v1/auth/coe/change-password', 'PATCH /api/v1/auth/profile',
  'GET /api/v1/audit/logs',
  'GET /api/v1/course-outcomes', 'GET /api/v1/course-outcomes/*', 'GET /api/v1/course-outcomes/*/revisions/*/document',
  'POST /api/v1/course-outcomes/*/review',
  'GET /api/v1/examinations/scheduled', 'GET /api/v1/examinations/unlock-credentials', 'GET /api/v1/examinations/*',
  'POST /api/v1/examinations/schedule', 'PUT /api/v1/examinations/*', 'DELETE /api/v1/examinations/*',
  'GET /api/v1/examinations/*/question-paper-archive', 'GET /api/v1/examinations/*/question-sets',
  'GET /api/v1/examinations/*/sittings/*/question-paper-archive/answer-key/download',
  'GET /api/v1/examinations/*/sittings/*/question-paper-archive/data',
  'GET /api/v1/examinations/*/sittings/*/question-paper-archive/download',
  'GET /api/v1/examinations/*/sittings/*/question-paper-archive/download-excel',
  'POST /api/v1/examinations/*/cancel', 'POST /api/v1/examinations/*/confirm-schedule', 'POST /api/v1/examinations/*/examiners',
  'POST /api/v1/examinations/*/prepare-and-send-package', 'POST /api/v1/examinations/*/retry-transfer',
  'POST /api/v1/examinations/*/select-set', 'PUT /api/v1/examinations/*/settings', 'PUT /api/v1/examinations/*/sittings',
  'POST /api/v1/examinations/*/sittings/*/unlock-credential',
  'POST /api/v1/examinations/*/sittings/*/unlock-credential/regenerate',
  'POST /api/v1/examinations/*/sittings/*/unlock-credential/revoke',
  'GET /api/v1/institution/departments', 'GET /api/v1/institution/eligibility', 'GET /api/v1/institution/laboratories',
  'GET /api/v1/institution/published-question-sets', 'GET /api/v1/institution/semesters', 'GET /api/v1/institution/subjects',
  'POST /api/v1/institution/laboratories', 'PATCH /api/v1/institution/laboratories/*',
  'GET /api/v1/results/answer-key-corrections', 'GET /api/v1/results/examinations',
  'POST /api/v1/results/answer-key-corrections/*/review', 'POST /api/v1/results/import-verified',
  'POST /api/v1/results/verify-upload', 'POST /api/v1/results/*/approve-release',
];

const CSP_STUDENT = "default-src 'self'; style-src 'self' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; "
  + "img-src 'self'; object-src 'none'; base-uri 'self'; form-action 'self'; frame-ancestors 'none'";
// Staff pages also show uploaded images and PDFs from blob: URLs, run the in-browser OCR/PDF workers, and compile WebAssembly.
const CSP_STAFF = "default-src 'self'; script-src 'self' 'wasm-unsafe-eval'; style-src 'self' https://fonts.googleapis.com; "
  + "font-src 'self' https://fonts.gstatic.com; img-src 'self' data: blob:; worker-src 'self' blob:; frame-src 'self' blob:; "
  + "object-src 'self' blob:; base-uri 'self'; form-action 'self'; frame-ancestors 'none'";

const STAFF_BODY_BYTES = 60 * 1024 * 1024; // central accepts uploads up to 55 MB
const LOGIN_BODY_BYTES = 16 * 1024;

const PROFILES = {
  student: {
    routes: [...ALLOWED], loginRoutes: ['/api/student/login', '/api/instructor/login'], csp: CSP_STUDENT, requireBearer: false,
    portDefault: 3002, upstreamPortEnv: 'LAB_PORT', upstreamPortDefault: 8082, maxBodyBytes: 1024 * 1024,
    portalDir: ['student-portal (Final)', 'student-portal (Final)', 'student-portal'], logName: 'gateway.log',
    unavailable: ['LAB_SERVER_UNAVAILABLE', 'The lab server is not reachable. Tell the invigilator.'],
    timeout: ['GATEWAY_TIMEOUT', 'The lab server took too long to answer. Tell the invigilator.'],
  },
  admin: {
    routes: ADMIN_ROUTES, loginRoutes: ['/api/v1/auth/login'], csp: CSP_STAFF, requireBearer: true,
    portDefault: 3003, upstreamPortEnv: 'CENTRAL_PORT', upstreamPortDefault: 8081, maxBodyBytes: STAFF_BODY_BYTES,
    portalDir: ['admin-portal (7)'], logName: 'gateway-admin.log',
    unavailable: ['CENTRAL_UNAVAILABLE', 'The central server is not reachable. Try again shortly.'],
    timeout: ['GATEWAY_TIMEOUT', 'The central server took too long to answer. Try again shortly.'],
  },
  coe: {
    routes: COE_ROUTES, loginRoutes: ['/api/v1/auth/coe/login'], csp: CSP_STAFF, requireBearer: true,
    portDefault: 3004, upstreamPortEnv: 'CENTRAL_PORT', upstreamPortDefault: 8081, maxBodyBytes: STAFF_BODY_BYTES,
    portalDir: ['coe-portal (7)'], logName: 'gateway-coe.log',
    unavailable: ['CENTRAL_UNAVAILABLE', 'The central server is not reachable. Try again shortly.'],
    timeout: ['GATEWAY_TIMEOUT', 'The central server took too long to answer. Try again shortly.'],
  },
};

// Only these client headers reach the backend. Everything else is dropped, which is what keeps
// X-Simulated-Time-Ms, X-Effective-Time-Ms and X-Bypass-Start-Check from ever arriving.
const FORWARDED_HEADERS = ['authorization', 'content-type', 'accept', 'user-agent'];

const TYPES = {
  '.html': 'text/html; charset=utf-8', '.js': 'text/javascript; charset=utf-8', '.css': 'text/css; charset=utf-8',
  '.json': 'application/json', '.png': 'image/png', '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg', '.webp': 'image/webp',
  '.svg': 'image/svg+xml', '.ico': 'image/x-icon', '.woff2': 'font/woff2', '.woff': 'font/woff', '.txt': 'text/plain; charset=utf-8',
  // A module worker is refused unless it arrives as JavaScript, and WebAssembly streams only as application/wasm.
  '.mjs': 'text/javascript; charset=utf-8', '.wasm': 'application/wasm', '.pdf': 'application/pdf',
  '.xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
};

const HOP_BY_HOP = new Set(['connection', 'keep-alive', 'transfer-encoding', 'te', 'trailer', 'upgrade', 'proxy-authenticate', 'proxy-authorization']);
const UPSTREAM_TIMEOUT_MS = 60000; // above the 30 s the backends may hold a slowed login
const HASHED_ASSET = /^\/assets\/.+-[\w-]{8}\.\w+$/;

const LOGIN_FAILURES_PER_MINUTE = 20; // per client address, across the profile's logins; the backend applies its own limits too
const BEARER = /^Bearer [A-Fa-f0-9]{64}$/;
// Header names that may carry the caller's address. Their values are logged the first time they appear, so the
// deployer picks CLIENT_IP_HEADER from what Tailscale Funnel really sends rather than from an assumption.
const ADDRESS_HEADER = /forward|real-ip|client|ingress|(^|-)ip($|-)|^via$|^tailscale/;

// Preloaded once: the gateway serves only files it indexed here, so path tricks (.., encoded dots, Windows
// short names or ::$DATA streams) cannot reach anything else, and no source map is ever indexed.
// Rebuilding the portal needs a gateway restart.
function loadPortal(distDir) {
  if (!fs.existsSync(path.join(distDir, 'index.html'))) {
    throw new Error(`The portal build was not found in ${distDir}. Build it first: npm ci && npm run build in the portal's folder (deploy/setup does this).`);
  }
  const files = new Map();
  for (const rel of fs.readdirSync(distDir, { recursive: true })) {
    const file = path.join(distDir, rel);
    const ext = path.extname(rel).toLowerCase();
    if (ext === '.map' || !fs.statSync(file).isFile()) continue;
    files.set('/' + rel.split(path.sep).join('/'), { body: fs.readFileSync(file), type: TYPES[ext] || 'application/octet-stream' });
  }
  return files;
}

function openLog(file) {
  fs.mkdirSync(path.dirname(file), { recursive: true });
  const stream = fs.createWriteStream(file, { flags: 'a' });
  stream.on('error', (err) => console.error(`Gateway log ${file} is not writable: ${err.message}`));
  return (line) => stream.write(line + '\n');
}

// Control characters are replaced so a crafted URL cannot forge extra log lines.
const printable = (s) => String(s).replace(/[^\x20-\x7e]/g, '?').slice(0, 200);

function createGateway(cfg) {
  const profile = PROFILES[cfg.profile || 'student'];
  const allows = compileRoutes(cfg.routes || profile.routes);
  const loginRoutes = new Set(cfg.loginRoutes || profile.loginRoutes);
  const upstreamPort = cfg.upstreamPort || cfg.labPort;
  const portal = loadPortal(cfg.distDir);
  const log = cfg.logFile ? openLog(cfg.logFile) : () => {};
  const seenHeaders = new Set();
  const loginFailures = new Map(); // client address -> times of its recent 401s on a login route
  let warnedClientHeader = false;
  log(`${new Date().toISOString()} START client-address-header=${cfg.clientIpHeader || 'none'}`);

  // Logs each header name the first time it arrives, with its value when the name looks like an address.
  function noteHeaders(req) {
    for (const name of Object.keys(req.headers)) {
      if (seenHeaders.has(name) || seenHeaders.size >= 100) continue;
      seenHeaders.add(name);
      log(`HEADER-SEEN ${printable(name)}${ADDRESS_HEADER.test(name) ? ` = ${printable(req.headers[name])}` : ''} (socket ${req.socket.remoteAddress})`);
    }
  }

  // The address of the real caller, or null. Only the header named in CLIENT_IP_HEADER is believed, and only when it
  // holds one IP: a list means a hop appended to a value the client may have written itself.
  function clientOf(req) {
    if (!cfg.clientIpHeader) return null;
    const value = req.headers[cfg.clientIpHeader];
    if (typeof value === 'string' && net.isIP(value.trim())) return value.trim();
    if (!warnedClientHeader) {
      warnedClientHeader = true;
      log(`WARNING CLIENT_IP_HEADER=${cfg.clientIpHeader} was ${value === undefined ? 'missing' : `not a single IP address: ${printable(value)}`}; such requests rely on the lab server's own limits`);
    }
    return null;
  }

  function recentLoginFailures(client, now) {
    const recent = (loginFailures.get(client) || []).filter((at) => now - at < 60000);
    if (recent.length) loginFailures.set(client, recent); else loginFailures.delete(client);
    return recent.length;
  }
  const sweep = setInterval(() => { for (const client of [...loginFailures.keys()]) recentLoginFailures(client, Date.now()); }, 60000);
  sweep.unref();

  function reply(res, status, type, body) {
    res.writeHead(status, { 'Content-Type': type, 'Content-Length': Buffer.byteLength(body) });
    res.end(body);
  }
  // An event stream cannot send headers, so it alone may carry the token in the query string.
  function hasStaffToken(req, url, pathname) {
    if (BEARER.test(req.headers.authorization || '')) return true;
    const q = url.indexOf('?');
    return pathname === '/api/v1/events' && q !== -1 && /^[A-Fa-f0-9]{64}$/.test(new URLSearchParams(url.slice(q + 1)).get('token') || '');
  }
  const notFound = (res) => reply(res, 404, 'text/plain; charset=utf-8', 'Not Found');
  const fail = (res, status, errorCode, error) => reply(res, status, 'application/json; charset=utf-8', JSON.stringify({ error, errorCode }));

  function serveStatic(req, res, pathname) {
    if (req.method !== 'GET' && req.method !== 'HEAD') return notFound(res);
    let key;
    try { key = decodeURIComponent(pathname); } catch { return notFound(res); }
    let file = portal.get(key);
    // Routes of the single-page app have no file extension; a missing asset must stay a 404, not an HTML page.
    if (!file && path.extname(key) === '') {
      file = portal.get('/index.html');
      key = '/index.html';
    }
    if (!file) return notFound(res);
    const cache = key === '/index.html' ? 'no-store' : HASHED_ASSET.test(key) ? 'public, max-age=31536000, immutable' : 'public, max-age=3600';
    res.writeHead(200, { 'Content-Type': file.type, 'Content-Length': file.body.length, 'Cache-Control': cache });
    res.end(req.method === 'HEAD' ? undefined : file.body);
  }

  function proxy(req, res, client, maxBodyBytes) {
    if (Number(req.headers['content-length'] || 0) > maxBodyBytes) {
      req.resume();
      return fail(res, 413, 'REQUEST_TOO_LARGE', 'Request body is too large.');
    }
    const chunks = [];
    let size = 0;
    let tooLarge = false;
    req.on('data', (chunk) => {
      size += chunk.length;
      if (size > maxBodyBytes) {
        if (!tooLarge) fail(res, 413, 'REQUEST_TOO_LARGE', 'Request body is too large.');
        tooLarge = true;
      } else if (!tooLarge) {
        chunks.push(chunk);
      }
    });
    req.on('end', () => { if (!tooLarge) forward(req, res, client, Buffer.concat(chunks)); });
  }

  function forward(req, res, client, body) {
    const headers = { host: `127.0.0.1:${upstreamPort}`, 'content-length': body.length };
    for (const name of FORWARDED_HEADERS) if (req.headers[name]) headers[name] = req.headers[name];
    // The backend refuses local-only routes on any request carrying this. Set here for every proxied request,
    // after the copy above, so a client-supplied value can never stand in for it or be passed through.
    headers['x-gateway-origin'] = 'gateway';
    // The backend keys its login limits on this. Only ever the address checked in clientOf(); a client-sent
    // X-Gateway-Client is never copied, and with no trusted address none is sent.
    if (client) headers['x-gateway-client'] = client;

    // The allowlisted path is forwarded as written; it is never decoded or normalised on the way.
    const upstream = http.request({ host: '127.0.0.1', port: upstreamPort, method: req.method, path: req.url, headers }, (upRes) => {
      if (client && upRes.statusCode === 401 && loginRoutes.has(req.url.split('?')[0])) {
        loginFailures.set(client, [...(loginFailures.get(client) || []), Date.now()]);
      }
      const out = {};
      for (const [name, value] of Object.entries(upRes.headers)) {
        // Same-origin only: the lab server's own CORS headers are not passed on.
        if (HOP_BY_HOP.has(name) || name.startsWith('access-control-') || name === 'cache-control') continue;
        out[name] = value;
      }
      out['cache-control'] = 'no-store';
      res.writeHead(upRes.statusCode, out);
      upRes.pipe(res);
    });
    upstream.setTimeout(UPSTREAM_TIMEOUT_MS, () => upstream.destroy(new Error('timeout')));
    upstream.on('error', (err) => {
      if (res.headersSent) return res.destroy();
      if (err.message === 'timeout') return fail(res, 504, ...profile.timeout);
      fail(res, 502, ...profile.unavailable);
    });
    res.on('close', () => { if (!res.writableEnded) upstream.destroy(); });
    upstream.end(body);
  }

  const server = http.createServer((req, res) => {
    res.setHeader('Content-Security-Policy', profile.csp);
    res.setHeader('X-Frame-Options', 'DENY');
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader('Referrer-Policy', 'no-referrer');
    res.setHeader('Permissions-Policy', 'camera=(), microphone=(), geolocation=()');

    const url = req.url || '/';
    const q = url.indexOf('?');
    const pathname = q === -1 ? url : url.slice(0, q);
    noteHeaders(req);
    const client = clientOf(req);
    // Only method, path (no query string), status and client are logged: never bodies or tokens.
    res.on('finish', () => log(`${new Date().toISOString()} ${req.method} ${printable(pathname)} ${res.statusCode} ${client || '-'}`));

    // /lab-api is the COE portal's lab-server prefix: it is never forwarded, but it must answer 404, not the portal's HTML.
    if (/^\/(?:lab-)?api(?:\/|$)/.test(pathname)) {
      res.setHeader('Cache-Control', 'no-store');
      if (!allows(req.method, pathname)) return notFound(res);
      const isLogin = loginRoutes.has(pathname);
      // Without a trusted client address there is nothing to count against here; the backend's own limits apply.
      if (client && isLogin && recentLoginFailures(client, Date.now()) >= LOGIN_FAILURES_PER_MINUTE) {
        return fail(res, 429, 'RATE_LIMITED', 'Too many failed login attempts. Try again in a minute.');
      }
      // A staff caller with no token is turned away before its body is read, so only a signed-in user can make the
      // gateway buffer a large upload. The token itself, its expiry and the role are checked by central, not here.
      if (profile.requireBearer && !isLogin && pathname !== '/api/v1/health' && !hasStaffToken(req, url, pathname)) {
        req.resume();
        return fail(res, 401, 'UNAUTHORIZED', 'Sign in required.');
      }
      return proxy(req, res, client, isLogin ? Math.min(cfg.maxBodyBytes, LOGIN_BODY_BYTES) : cfg.maxBodyBytes);
    }
    serveStatic(req, res, pathname);
  });
  server.headersTimeout = 15000;
  server.requestTimeout = 30000;
  server.on('clientError', (err, socket) => socket.destroy());
  server.on('close', () => clearInterval(sweep));
  return server;
}

function fromEnv() {
  const name = (process.env.GATEWAY_PROFILE || 'student').trim().toLowerCase();
  const profile = PROFILES[name];
  if (!profile) throw new Error(`GATEWAY_PROFILE must be student, admin or coe, not "${process.env.GATEWAY_PROFILE}".`);
  const port = Number(process.env.GATEWAY_PORT || profile.portDefault);
  const upstreamPort = Number(process.env[profile.upstreamPortEnv] || profile.upstreamPortDefault);
  if (!Number.isInteger(port) || port < 1 || port > 65535) throw new Error(`GATEWAY_PORT must be a port number, not "${process.env.GATEWAY_PORT}".`);
  if (!Number.isInteger(upstreamPort) || upstreamPort < 1 || upstreamPort > 65535) throw new Error(`${profile.upstreamPortEnv} must be a port number, not "${process.env[profile.upstreamPortEnv]}".`);
  const root = path.resolve(__dirname, '..', '..');
  return {
    profile: name,
    port,
    upstreamPort,
    distDir: path.resolve(process.env.PORTAL_DIST_DIR || path.join(root, ...profile.portalDir, 'dist')),
    logFile: process.env.GATEWAY_LOG_FILE || path.join(root, 'CampusExam', 'lab_storage', 'logs', profile.logName),
    maxBodyBytes: Number(process.env.GATEWAY_MAX_BODY_BYTES || profile.maxBodyBytes),
    // No default on purpose: which header carries the caller's address behind Tailscale Funnel is read from the log, not assumed.
    clientIpHeader: (process.env.CLIENT_IP_HEADER || '').trim().toLowerCase(),
  };
}

if (require.main === module) {
  try {
    const cfg = fromEnv();
    const server = createGateway(cfg);
    server.on('error', (err) => {
      console.error(err.code === 'EADDRINUSE'
        ? `Port ${cfg.port} is already in use. Stop the other program, or set GATEWAY_PORT to a free port.`
        : `The gateway could not start: ${err.message}`);
      process.exit(1);
    });
    // Loopback only. Nothing here may listen on the LAN.
    server.listen(cfg.port, '127.0.0.1', () => {
      console.log(`Exam gateway (${cfg.profile}) listening on http://127.0.0.1:${cfg.port} -> 127.0.0.1:${cfg.upstreamPort}`);
      console.log(`Portal: ${cfg.distDir}`);
      console.log(`Access log: ${cfg.logFile}`);
      console.log(cfg.clientIpHeader
        ? `Client address header: ${cfg.clientIpHeader}`
        : 'Client address header: none (CLIENT_IP_HEADER is not set). Check the access log for HEADER-SEEN lines to see what Tailscale sends.');
    });
  } catch (err) {
    console.error(err.message);
    process.exit(1);
  }
}

module.exports = { createGateway, compileRoutes, ALLOWED, PROFILES };
