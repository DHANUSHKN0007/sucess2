'use strict';
// Used by reset-data.ps1 and reset-data.sh. Counts or removes the exam-delivery rows in PostgreSQL.
//   node deploy/reset-data-db.js --count   prints "ROWS<TAB>table<TAB>n" for each table that exists (and "MISSING<TAB>table")
//   node deploy/reset-data-db.js --wipe    counts, then empties every listed table in ONE transaction and prints "CLEARED<TAB>table<TAB>n"
// Exit 0 = done, 1 = the wipe failed and was rolled back, 2 = could not connect or read .env (nothing was touched).
//
// Never CASCADE: if a table outside this list still references one of these, TRUNCATE refuses and nothing changes, rather than
// silently emptying a table that holds accounts or institution data.
const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '..');

// Exam, sitting, schedule, package, result and student-response data. Every table that references one of these is also here.
// Not listed, so kept: account (staff and students), session_token, student_roster*, student_list_history, department,
// academic_group, subject, laboratory*, hod_assignment_history, faculty_scope, question banks and their items, paper_blueprint,
// course_outcome_*, audit, schema_migrations.
const TABLES = [
  'examination_cycle', 'examination_session', 'examination_sitting', 'sitting_examiner',
  'secure_package', 'lab_package_acknowledgement', 'lab_result_import', 'student_session_result',
  'session_roster_snapshot', 'session_unlock_credential', 'computer_assignment',
  'relogin_authorization', 'session_transfer_history', 'security_violation_log',
  'paper_version', 'paper_version_question', 'generated_paper', 'generated_paper_question', 'answer_key_correction',
  'exam', 'exam_question', 'assignment', 'attempt', 'answer',
];

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

async function connect() {
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
  return db;
}

async function main() {
  const mode = process.argv[2];
  if (mode !== '--count' && mode !== '--wipe') throw new Error('Usage: node reset-data-db.js --count | --wipe');
  const db = await connect();
  const counts = [];
  try {
    const present = new Set((await db.query(
      "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name = ANY($1)", [TABLES])).rows.map((r) => r.table_name));
    for (const t of TABLES) {
      if (!present.has(t)) { console.log(`MISSING\t${t}`); continue; }
      counts.push([t, Number((await db.query(`SELECT count(*) AS n FROM public."${t}"`)).rows[0].n)]);
    }
    if (mode === '--count') {
      for (const [t, n] of counts) console.log(`ROWS\t${t}\t${n}`);
      return;
    }
    try {
      await db.query('BEGIN');
      if (counts.length) await db.query(`TRUNCATE TABLE ${counts.map(([t]) => `public."${t}"`).join(', ')}`);
      await db.query('COMMIT');
    } catch (err) {
      await db.query('ROLLBACK').catch(() => {});
      console.error(`The wipe failed and was rolled back; no row was removed: ${err.message}`);
      process.exitCode = 1;
      return;
    }
    for (const [t, n] of counts) console.log(`CLEARED\t${t}\t${n}`);
  } finally {
    await db.end();
  }
}

main().catch((err) => { console.error(`Could not reach the database: ${err.message}`); process.exit(2); });
