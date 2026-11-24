'use strict';
// Run by preflight. Exits 1 and names the accounts when a demo staff password published in README.md or
// CampusExam/database_dump.sql would still sign in; exits 2 when that cannot be checked (a check that cannot run is a failure).
// It asks the database what each active staff account would accept; it never calls the central backend.
//   node deploy/check-demo-credentials.js
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const root = path.resolve(__dirname, '..');

// This is a denylist, not a credential source: the passwords the README's "Default Credentials" table and the old
// built-in account list published. README.md also offers Admin@123 for every staff account.
const DEMO_PASSWORDS = {
  admin: ['ADMIN@7157'], principal: ['PRINCIPAL@7658'], coe: ['COE@5828'],
  'hod.civil': ['CIVIL@0134'], 'hod.cse': ['CSE@2109'], 'hod.cse.ai': ['CSEAI@4939'], 'hod.cse.ds': ['CSEDS@4636'],
  'hod.cse.bs': ['CSEBS@1588'], 'hod.cse.aiml': ['AIML@1504'], 'hod.cse.iotcs': ['IOTCS@7534'], 'hod.comp': ['COMPENG@5354'],
  'hod.ece': ['ECE@5175'], 'hod.ise': ['ISE@3325'], 'hod.mech': ['MECH@9626'],
};
const ANY_STAFF = ['Admin@123'];

function readEnv() {
  const env = {};
  const file = path.join(root, '.env');
  if (!fs.existsSync(file)) return env;
  for (const raw of fs.readFileSync(file, 'utf8').split(/\r?\n/)) {
    const line = raw.trim();
    const i = line.indexOf('=');
    if (!line || line.startsWith('#') || i < 1) continue;
    let v = line.slice(i + 1).trim();
    if (v.length >= 2 && ((v[0] === '"' && v.endsWith('"')) || (v[0] === "'" && v.endsWith("'")))) v = v.slice(1, -1);
    env[line.slice(0, i).trim()] = v;
  }
  return env;
}

// username -> password_hash from the dump's account table, for accounts whose demo password is not published anywhere.
function dumpHashes() {
  const out = new Map();
  const file = path.join(root, 'CampusExam', 'database_dump.sql');
  if (!fs.existsSync(file)) return out;
  let inside = false;
  for (const line of fs.readFileSync(file, 'utf8').split(/\r?\n/)) {
    if (line.startsWith('COPY public.account ')) { inside = true; continue; }
    if (!inside) continue;
    if (line === '\\.') break;
    const cols = line.split('\t');
    if (cols.length > 2) out.set(cols[1].toLowerCase(), cols[2]);
  }
  return out;
}

function matches(password, hash) {
  const m = /^([0-9a-f]{32,}):([0-9a-f]{64})$/i.exec(hash || '');
  if (!m) return false;
  const derived = crypto.pbkdf2Sync(password, Buffer.from(m[1], 'hex'), 600000, 32, 'sha256');
  return crypto.timingSafeEqual(derived, Buffer.from(m[2], 'hex'));
}

async function main() {
  const env = readEnv();
  const url = /^jdbc:postgresql:\/\/([^:/]+)(?::(\d+))?\/([^?]+)/.exec(env.DB_URL || '');
  if (!url) throw new Error('DB_URL in .env is not a jdbc:postgresql://host:port/database address.');
  let Client;
  try {
    ({ Client } = require(path.join(root, 'backend', 'node_modules', 'pg')));
  } catch {
    throw new Error('The backend packages are not installed (backend/node_modules/pg). Run deploy/setup.');
  }
  const db = new Client({ host: url[1], port: Number(url[2] || 5432), database: url[3], user: env.DB_USER, password: env.DB_PASSWORD, connectionTimeoutMillis: 5000 });
  await db.connect();
  let rows;
  try {
    rows = (await db.query("SELECT username, password_hash, role, status FROM account WHERE role <> 'STUDENT' AND upper(coalesce(status, 'ACTIVE')) NOT IN ('INACTIVE', 'SUSPENDED')")).rows;
  } finally {
    await db.end();
  }
  const dump = dumpHashes();
  const found = [];
  for (const row of rows) {
    const name = row.username.toLowerCase();
    const envHash = (env['STAFF_PASSWORD_HASH_' + name.toUpperCase().replace(/[^A-Z0-9]/g, '_')] || '').trim();
    const envOnly = name === 'admin' || name === 'coe';
    // What central would accept: the .env hash when there is one; admin and coe accept nothing else; the rest use the database.
    const effective = envHash || (envOnly ? '' : row.password_hash);
    if (!effective) continue;
    if (dump.get(name) === effective) { found.push(`${row.username} (still the database_dump.sql password)`); continue; }
    const hit = [...(DEMO_PASSWORDS[name] || []), ...ANY_STAFF].some((pw) => matches(pw, effective));
    if (hit) found.push(`${row.username} (a password published in README.md)`);
  }
  if (found.length) {
    for (const f of found) console.log(`DEMO ${f}`);
    process.exit(1);
  }
  console.log(`No demo staff password opens any of the ${rows.length} active staff accounts.`);
}

main().catch((err) => { console.error(`Could not check the demo credentials: ${err.message}`); process.exit(2); });
