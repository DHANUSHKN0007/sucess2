'use strict';
// The one public entry point for an exam: serves the built student portal and forwards only the
// allowlisted student/recovery API routes to the lab server. It listens on loopback only; Tailscale is the way in.
const http = require('http');
const fs = require('fs');
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

// Only these client headers reach the lab server. Everything else is dropped, which is what keeps
// X-Simulated-Time-Ms, X-Effective-Time-Ms and X-Bypass-Start-Check from ever arriving.
const FORWARDED_HEADERS = ['authorization', 'content-type', 'accept', 'user-agent'];

// The portal pulls Inter and Merriweather from Google Fonts; nothing else is loaded from outside.
const CSP = "default-src 'self'; style-src 'self' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; "
  + "img-src 'self'; object-src 'none'; base-uri 'self'; form-action 'self'; frame-ancestors 'none'";

const TYPES = {
  '.html': 'text/html; charset=utf-8', '.js': 'text/javascript; charset=utf-8', '.css': 'text/css; charset=utf-8',
  '.json': 'application/json', '.png': 'image/png', '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg', '.webp': 'image/webp',
  '.svg': 'image/svg+xml', '.ico': 'image/x-icon', '.woff2': 'font/woff2', '.woff': 'font/woff', '.txt': 'text/plain; charset=utf-8',
};

const HOP_BY_HOP = new Set(['connection', 'keep-alive', 'transfer-encoding', 'te', 'trailer', 'upgrade', 'proxy-authenticate', 'proxy-authorization']);
const UPSTREAM_TIMEOUT_MS = 60000; // above the 30 s the lab server may hold a slowed instructor login
const HASHED_ASSET = /^\/assets\/.+-[\w-]{8}\.\w+$/;

// Preloaded once: the gateway serves only files it indexed here, so path tricks (.., encoded dots, Windows
// short names or ::$DATA streams) cannot reach anything else, and no source map is ever indexed.
// Rebuilding the portal needs a gateway restart.
function loadPortal(distDir) {
  if (!fs.existsSync(path.join(distDir, 'index.html'))) {
    throw new Error(`The student portal build was not found in ${distDir}. Build it first: npm ci && npm run build in the student-portal folder.`);
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
const printable = (s) => String(s).replace(/[^\x21-\x7e]/g, '?').slice(0, 200);

function createGateway(cfg) {
  const portal = loadPortal(cfg.distDir);
  const log = cfg.logFile ? openLog(cfg.logFile) : () => {};

  function reply(res, status, type, body) {
    res.writeHead(status, { 'Content-Type': type, 'Content-Length': Buffer.byteLength(body) });
    res.end(body);
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

  function proxy(req, res, target) {
    if (Number(req.headers['content-length'] || 0) > cfg.maxBodyBytes) {
      req.resume();
      return fail(res, 413, 'REQUEST_TOO_LARGE', 'Request body is too large.');
    }
    const chunks = [];
    let size = 0;
    let tooLarge = false;
    req.on('data', (chunk) => {
      size += chunk.length;
      if (size > cfg.maxBodyBytes) {
        if (!tooLarge) fail(res, 413, 'REQUEST_TOO_LARGE', 'Request body is too large.');
        tooLarge = true;
      } else if (!tooLarge) {
        chunks.push(chunk);
      }
    });
    req.on('end', () => { if (!tooLarge) forward(req, res, target, Buffer.concat(chunks)); });
  }

  function forward(req, res, target, body) {
    const headers = { host: `127.0.0.1:${cfg.labPort}`, 'content-length': body.length };
    for (const name of FORWARDED_HEADERS) if (req.headers[name]) headers[name] = req.headers[name];

    const upstream = http.request({ host: '127.0.0.1', port: cfg.labPort, method: req.method, path: target, headers }, (upRes) => {
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
      if (err.message === 'timeout') return fail(res, 504, 'GATEWAY_TIMEOUT', 'The lab server took too long to answer. Tell the invigilator.');
      fail(res, 502, 'LAB_SERVER_UNAVAILABLE', 'The lab server is not reachable. Tell the invigilator.');
    });
    res.on('close', () => { if (!res.writableEnded) upstream.destroy(); });
    upstream.end(body);
  }

  const server = http.createServer((req, res) => {
    res.setHeader('Content-Security-Policy', CSP);
    res.setHeader('X-Frame-Options', 'DENY');
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader('Referrer-Policy', 'no-referrer');
    res.setHeader('Permissions-Policy', 'camera=(), microphone=(), geolocation=()');

    const url = req.url || '/';
    const q = url.indexOf('?');
    const pathname = q === -1 ? url : url.slice(0, q);
    // Only method, path (no query string), status and client are logged: never bodies or tokens.
    res.on('finish', () => log(`${new Date().toISOString()} ${req.method} ${printable(pathname)} ${res.statusCode} -`));

    if (pathname === '/api' || pathname.startsWith('/api/')) {
      res.setHeader('Cache-Control', 'no-store');
      // The allowlisted path is forwarded as written; it is never decoded or normalised on the way.
      if (!ALLOWED.has(`${req.method} ${pathname}`)) return notFound(res);
      return proxy(req, res, url);
    }
    serveStatic(req, res, pathname);
  });
  server.headersTimeout = 15000;
  server.requestTimeout = 30000;
  server.on('clientError', (err, socket) => socket.destroy());
  return server;
}

function fromEnv() {
  const port = Number(process.env.GATEWAY_PORT || 3002);
  const labPort = Number(process.env.LAB_PORT || 8082);
  if (!Number.isInteger(port) || port < 1 || port > 65535) throw new Error(`GATEWAY_PORT must be a port number, not "${process.env.GATEWAY_PORT}".`);
  if (!Number.isInteger(labPort) || labPort < 1 || labPort > 65535) throw new Error(`LAB_PORT must be a port number, not "${process.env.LAB_PORT}".`);
  const root = path.resolve(__dirname, '..', '..');
  return {
    port,
    labPort,
    distDir: path.resolve(process.env.PORTAL_DIST_DIR || path.join(root, 'student-portal (Final)', 'student-portal (Final)', 'student-portal', 'dist')),
    logFile: process.env.GATEWAY_LOG_FILE || path.join(root, 'CampusExam', 'lab_storage', 'logs', 'gateway.log'),
    maxBodyBytes: Number(process.env.GATEWAY_MAX_BODY_BYTES || 1024 * 1024),
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
      console.log(`Exam gateway listening on http://127.0.0.1:${cfg.port} -> lab server 127.0.0.1:${cfg.labPort}`);
      console.log(`Portal: ${cfg.distDir}`);
      console.log(`Access log: ${cfg.logFile}`);
    });
  } catch (err) {
    console.error(err.message);
    process.exit(1);
  }
}

module.exports = { createGateway, ALLOWED };
