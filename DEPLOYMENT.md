# Deployment

Goal: someone who did not write this code pulls the repo, runs two scripts, pastes three Tailscale commands, and a
safe exam is reachable from students' and staff browsers. All answers stay on the host PC.

```
git pull
.\deploy\setup.ps1          # once per machine: builds, creates the instructor, admin and COE logins
.\deploy\start-exam.ps1     # each exam: checks, starts, PRINTS the three tailscale commands
<paste the printed tailscale commands>
.\deploy\stop-exam.ps1      # when the sitting ends (leaves Funnel as it is)
```

On Linux or macOS use `./deploy/setup.sh`, `./deploy/start-exam.sh` and `./deploy/stop-exam.sh`. The `.sh` scripts
have not been run by the authors; the PowerShell scripts are the primary path.

Read these three statements before anything else:

- **Every Funnel URL (student, admin and COE) is public and appears in Certificate Transparency logs.** Anyone can
  discover them; they are not secret. Access control is the logins, never the secrecy of a URL.
- **Fullscreen and DevTools controls in the student portal are deterrents, not locks.** A determined candidate with
  physical control of a browser can defeat them; the server records violations and refuses answers from a locked
  session, but it cannot stop someone reading the screen.
- **The student credential is open.** See "Student login is an open credential" below.

## Prerequisites

| Need | Version | Why |
|---|---|---|
| Windows 10/11 (or Linux/macOS) | | The host PC. Wired network and mains power for the sitting. |
| Node.js | 18 or newer | Builds the portals; runs the gateway. |
| JDK (not just a JRE) | 17 or newer | Compiles and runs the central backend and the lab server. |
| PostgreSQL | 14 or newer (the scripts look for 16 first) | **Required.** See below. |
| Tailscale | current; the Funnel syntax below was checked against 1.104.7 | The only way in from outside. |
| Python 3 | any | `setup.sh` and `set-staff-password.sh` only, to hash the instructor and staff passwords. |

**PostgreSQL is required.** It must be installed, running on this PC, and reachable at the `DB_URL` in `.env` before
`start-exam` will run. The central backend (which builds exam packages and answers the COE and admin portals) reads and
writes it. The lab server itself keeps students' sessions and answers as files under `CampusExam\lab_storage`, not in
PostgreSQL. `deploy\preflight.ps1` fails with "PostgreSQL does not answer" when it is down.

## One-time Tailscale admin-console steps

Do these once per tailnet, signed in to the Tailscale admin console as an admin. They are taken from Tailscale's own
pages (https://tailscale.com/kb/1153/enabling-https and https://tailscale.com/kb/1223/funnel, read 2026-11-24); if the
console looks different, follow those pages, not this list.

1. Open the **DNS** page (https://console.tailscale.com/admin/dns). Make sure **MagicDNS** is enabled.
2. Under **HTTPS Certificates**, select **Enable HTTPS** and acknowledge that your machine names and your tailnet DNS
   name are published on a public ledger. Do not enable it if any machine name in the tailnet is sensitive.
3. Open **Access controls**. Expand the **Funnel** section and select **Add Funnel to policy**. This adds the default
   `nodeAttrs` section to the policy file and saves it. The result looks like this (the policy file accepts trailing
   commas):

   ```json
   "nodeAttrs": [
     {
       "target": ["autogroup:member"],
       "attr":   ["funnel"],
     },
   ],
   ```

   `autogroup:member` lets every member of the tailnet use Funnel; narrow `target` if you want fewer.
4. Sign in to Tailscale on the host PC.

Funnel can only listen on ports 443, 8443 and 10000, so the three portals share them:

| Portal | Funnel port | URL | Gateway on this PC (`.env`, default) |
|---|---|---|---|
| Student | 443 | `https://<name>/` | `GATEWAY_PORT`, 3002 |
| Admin | 8443 | `https://<name>:8443/` | `ADMIN_GATEWAY_PORT`, 3003 |
| COE | 10000 | `https://<name>:10000/` | `COE_GATEWAY_PORT`, 3004 |

`deploy\preflight.ps1` checks that Tailscale is running, that MagicDNS and HTTPS are on, and that this PC has the
`funnel` attribute.

## One-time setup

```
.\deploy\setup.ps1
```

It checks that Node.js, a JDK, PostgreSQL and Tailscale are installed (and says where to get any that are missing),
creates `.env` from `.env.example` only if it is absent, generates `JWT_SECRET`, creates the instructor login and the
admin and COE logins, installs the npm packages, builds the student, admin and COE portals, compiles the Java, and
offers to initialise the database. Running it again keeps every value already in `.env`.

- **Instructor (invigilator) login.** Setup writes `LAB_INSTRUCTOR_USERNAME` (default `invigilator`) and
  `LAB_INSTRUCTOR_PASSWORD_HASH` into `.env`, used by both the lab server and the central backend, and **prints the
  generated password once**. Nothing stores it: write it down then. To replace it, delete both `LAB_INSTRUCTOR_*` lines
  from `.env` and run setup again. `start-exam` refuses to start if either is missing.
- **Admin and COE logins.** These accounts have no built-in password. Setup runs `deploy\set-staff-password.ps1`, which
  writes `STAFF_PASSWORD_HASH_ADMIN` and `STAFF_PASSWORD_HASH_COE` (PBKDF2, same scheme as the instructor hash) into
  `.env` and **prints each generated password once**. Write them down. Change one later with
  `.\deploy\set-staff-password.ps1 -User coe` (add `-Password` to choose it; 8 to 128 characters) and restart the
  services. `start-exam` and preflight refuse to run while either hash is missing. See "Public staff portals" below for
  the principal and HOD accounts.
- **Database.** Setup asks before touching it (`-Yes` answers for you, `-SkipDatabase` skips it). It runs
  `init_database.ps1`, which creates the role and database from `.env` if they are missing and loads
  `CampusExam\database_dump.sql` only into a database that has no `account` table. The dump contains DROP statements,
  which is why there is a question. You may be asked for the PostgreSQL administrator password.
- `.env` is never committed: it is in `.gitignore` along with `lab_storage/`, `*.key`, `*.pem` and `node_modules/`.

## Per-exam checklist

Before the students arrive:

- [ ] Host PC on mains power and on a **wired** network. Sleep and hibernate off (preflight checks this; to fix, run
      `powercfg /change standby-timeout-ac 0` and `powercfg /change hibernate-timeout-ac 0`).
- [ ] The host clock and time zone are right. The lab server's clock is the only clock; students cannot change it.
- [ ] PostgreSQL running.
- [ ] `.\deploy\start-exam.ps1` finishes and prints the three Tailscale commands. Do not run them yet.
- [ ] **The exam package is loaded and activated through the COE portal** (`http://127.0.0.1:3001` on this PC)
      **before any student logs in**: the COE portal sends the sitting's signed, encrypted package to this lab server,
      where it is then activated. Check that it landed: open `http://127.0.0.1:8082/health` on the host PC and confirm
      the package and cohort counts are not zero. A student who is not on that package's roster cannot log in.
- [ ] **Hand-outs** (next section): the invigilator unlock password for each sitting, and the instructor login.
- [ ] Run the three printed `tailscale funnel` commands. Funnel keeps them across restarts, so on a permanent host
      this is needed once, not every exam.
- [ ] **Verify from a phone on mobile data**, not on the college Wi-Fi. Open the URL `start-exam` printed: the login
      page must load. Open `<URL>/api/health`: it must answer with a small JSON object containing `ok`. Open
      `<URL>/api/results/download`: it must be a 404, never a download. Then the staff portals: the admin URL
      (`:8443`) and the COE URL (`:10000`) must each show their sign-in page; `<admin URL>/api/v1/auth/me` and
      `<COE URL>/api/v1/examinations/scheduled` must answer 401 with no token, and `<either URL>/api/v1/nonsense` must
      be a plain 404.

### Hand-outs: exam code, unlock password, instructor login

| What | Where it comes from | Who gets it | Notes |
|---|---|---|---|
| **Examination code** (looks like `EXAM-CS501-12`) | Shown by the COE portal and by the lab server's monitoring | Invigilators, so they can identify the sitting | **Students are not asked for it and nothing checks it.** The student login takes USN and date of birth only, so announcing the code does not restrict who can log in. A per-sitting exam code as a third login field is described in `TAILSCALE_HARDENING_PROMPT.md` (Phase 3, item 6) and is **not built**. |
| **Invigilator unlock password** | Generated per sitting in the COE portal (session unlock credential). It is shown **once**; only a salted verifier is synced to the lab server | The invigilator in each lab, in person or by a channel that is not the exam URL's | Typed by the invigilator on a student's screen after a security lock. Three wrong tries lock that student's session permanently until the Chief Invigilator overrides. If it is lost, generate a new one in the COE portal; the old one stops working. |
| **Instructor login** (ID and password) | Created by `setup.ps1`; the password is shown once | The invigilators who may approve a student's re-login on another PC after a crash | Used from the "Invigilator sign-in" link on the student login page, at a PC the invigilator is standing at. |

### Student login is an open credential

A student signs in with USN and date of birth. USNs follow a pattern and dates of birth are known to
classmates, so **neither is a secret**. Once the URL is public, anyone who learns a classmate's USN and date of birth
can try to sign in as them from anywhere. What the system does about it:

- Only USNs on the activated package's roster can log in, and a wrong date of birth and an unknown USN get the same
  reply.
- Five failed logins for one USN lock it for 60 seconds. Ten failed logins from one source in a minute get
  `429 RATE_LIMITED`. Behind Funnel the gateway also limits failed logins per client address when it can trust one
  (see "Gateway" below).
- Login is allowed only from 30 minutes before the scheduled start.
- One active candidate per computer (`409 WORKSTATION_IN_USE`: "Another candidate is still signed in on this computer. Ask your
  invigilator."). The student portal generates a machine ID on first load, keeps it in the browser's local storage and
  sends it with the login; students never see or type it. It identifies a browser profile, so a second browser profile
  or a private window on the same PC counts as a different computer, and the monitoring screens show IDs like `WS-1A2B3C4D`.
- One live attempt per candidate (`409 SESSION_ACTIVE_ELSEWHERE`: "This candidate's examination is already in progress on another
  computer. Ask your invigilator."). After a candidate has started, a login from a different computer or browser profile is
  refused; the same browser signing in again resumes the same attempt and timer. Before the start a candidate can still
  change computers. Only an invigilator can move a started candidate to another computer ("Invigilator sign-in" on the
  login page, then approve that candidate's re-login; the approval is good for 10 minutes and moves the candidate once).

What it does **not** do is prove that the person typing is the student. The invigilators in the room are the control:
do not run an unsupervised sitting on this system.

## Start

```
.\deploy\start-exam.ps1
```

It stops with a plain-English message if anything is wrong. In order: `.env` complete, including the instructor, admin
and COE logins; preflight; every `.env` value is exported into each service it starts; the central backend, lab server,
the three gateways (student, admin, COE), COE portal and admin portal start, each bound to `127.0.0.1`; it waits for
`/api/health` through the student gateway and `/api/v1/health` through the admin and COE gateways; it asks the
operating system what is actually listening and stops everything if any service is bound beyond `127.0.0.1`. Then it
**prints, and never runs,** the three Tailscale commands and the three URLs:

```
tailscale funnel --bg 3002
tailscale funnel --bg --https=8443 3003
tailscale funnel --bg --https=10000 3004
```

The ports are always the **gateway** ports (`GATEWAY_PORT`, `ADMIN_GATEWAY_PORT`, `COE_GATEWAY_PORT`), never the lab
server's 8082 or central's 8081 (see "Point Tailscale at the gateway ports only" below). Service logs are in
`CampusExam\lab_storage\logs\`.

`preflight.ps1` refuses to start when: `.env` lacks a required value; `JWT_SECRET` is missing or under 32 characters;
`LAB_TEST_MODE`, `LAB_STAFF_ALLOW_REMOTE` or `ALLOW_SAMPLE_EXAM` is `true`; `BIND` or `LAB_BIND` is not loopback; any
exam port, or the Node backend's port 8080, is listening on anything other than `127.0.0.1`; an exam port is already in
use; the student, admin or COE portal is not built or has `.map` files; `STAFF_PASSWORD_HASH_ADMIN` or
`STAFF_PASSWORD_HASH_COE` is missing or malformed; PostgreSQL does not answer; **any active staff account still accepts
a demo password published in `README.md` or `database_dump.sql`** (it names the accounts and prints the command that
fixes them; the check is `deploy/check-demo-credentials.js`, which reads the database and never calls the backend);
`lab_storage` or `BACKUP_DIR` is not writable; the PC sleeps on mains power; or Tailscale is not running with MagicDNS,
HTTPS and Funnel. Run it alone with `.\deploy\preflight.ps1`.

The Node backend (`backend/server.js`, port 8080) is not part of an exam and `start-exam` does not start it. Its code
listens on `0.0.0.0`, so if it is running when you start an exam, preflight refuses until you stop it.

## Public staff portals (admin on 8443, COE on 10000)

**These URLs are public and appear in Certificate Transparency logs, so anyone can discover them. They are not secret;
the logins and the limits below are the only protection.**

`start-exam` runs one gateway per portal (`deploy/gateway/server.js` with `GATEWAY_PROFILE=admin` or `coe`). Each
serves that portal's built `dist`, forwards only that portal's `/api/v1` routes to the central backend on
`127.0.0.1:8081`, answers everything else (and every `*.map`) with a plain 404, sets security headers, strips client
time and bypass headers, limits body sizes and failed logins, and listens on `127.0.0.1` only. A production build of
either portal calls `/api/v1` on its own origin, never an address on `localhost`.

**What the public gateways do not carry.** The central backend is their only upstream, so two things work only on the
host PC, through the portals' own dev servers (`http://127.0.0.1:3000` admin, `http://127.0.0.1:3001` COE; `start-exam`
still starts them):

- the admin portal's document converter, templates and smart upload (served by the portal's own server, not central);
- the COE portal's lab-server screens: lab server list, live monitoring, package receipt, PC recovery, workstation
  bind, unlock events, `results/finalize` and `results/download`. The lab server answers staff routes only to the host
  PC, so over the public URL these calls get a 404 and the portal shows a network error.

Do the load-and-activate step, result finalisation and export on the host PC.

**Access control on central (port 8081).** Every route except login needs a server-issued session token (32 random bytes,
stored only as a SHA-256 digest, 12-hour expiry) and a role. The COE family (`examinations/**`, `results/**`,
`labs/**`, `monitoring/**`, laboratories, `approve-results`, `release-results`, `import-results`) and the re-login
`approve`/`consume` routes, package receipt and package import need COE or ADMIN; `principal/*` and `hod/*` need
those roles. **ADMIN is accepted on the COE family, and the admin gateway serves principal and HOD users too**; taking
ADMIN out of the COE family is a one-line change in `dispatchV1`. Besides login, two things answer without a staff
token: the embedded student runtime (`student/*`, `security/violation`, `security/unlock`, `instructor/*`), which only
loopback callers can reach and no staff gateway forwards, and the lab server's own loopback calls to
`events/broadcast` and `results/import-package`. Those calls carry no `X-Gateway-Origin` header, and a request through
any gateway always does, so it cannot pass as one.

**Login limits.** Copied from the lab server: 5 failed logins in 60 s per client get 429 `LOGIN_RATE_LIMITED`, and every
failure anywhere in the last 60 s adds 1 s to later attempts, up to 30 s. There is no global lockout. Behind Funnel the
client is the address the gateway trusts (`CLIENT_IP_HEADER`, see "Gateway"); with none, the key is the username.

**Staff passwords.** The admin and COE accounts sign in only with their `.env` hash: each restart overwrites the database hash on those
rows with it (or with an unusable one when it is missing). Principal and HOD accounts use an `STAFF_PASSWORD_HASH_<USERNAME>` hash when one is set (`hod.cse`
becomes `STAFF_PASSWORD_HASH_HOD_CSE`), otherwise the hash already in the database. **Those database hashes come from
`database_dump.sql` and are the demo passwords**, so preflight refuses to pass until each such account has a new one:
`.\deploy\set-staff-password.ps1 -User principal,hod.cse,...` (preflight prints the exact command). An account whose
password is set this way cannot change it in the portal (409); run the script again instead. Student accounts are not
covered: they authenticate only against an activated package roster.

## During the exam

- On this PC, `http://127.0.0.1:3000` (admin) and `http://127.0.0.1:3001` (COE) are the full portals, including what
  the public gateways cannot carry (see above). The same portals are public at `:8443` and `:10000` once the Funnel
  commands have been run.
- A student PC that crashes: the invigilator uses "Invigilator sign-in" on the student login page with the instructor
  login (the in-console recovery screen opens) and approves a re-login on another computer.
- A locked screen: the invigilator types the unlock password for that sitting.
- Restarting the lab server logs every instructor out. Sessions and answers are saved to `lab_storage` as they change
  and are reloaded on start, but a mid-exam restart has not been exercised end to end, so avoid one.

## Stop, export and back up

```
.\deploy\stop-exam.ps1
```

It stops every service, confirms nothing is still listening, and reminds you to export and back up. **It does not touch
Tailscale Funnel**: the funnels are meant to persist across restarts on a permanent host, and while the services are down
they answer with an error. To close them by hand run `tailscale funnel reset`. **Export the results from the COE portal
before you stop**, because stopping takes the lab server and the COE portal down (if you forgot, run `start-exam` again;
if Funnel is still on, the portals are public again as soon as it finishes). Then copy
`CampusExam\lab_storage` to `BACKUP_DIR` (default `backups\`) and keep it until the results are approved.

## Reset between sittings

```
.\deploy\stop-exam.ps1
.\deploy\reset-data.ps1        # ./deploy/reset-data.sh on Linux/macOS
```

Run it after the results are exported and approved, before the next batch, so nothing from the last sitting carries over.
It refuses while any exam service is listening, lists exactly what it will clear, and asks you to type `WIPE` (`-Force`,
or `--force` for the `.sh`, skips that). It then copies `CampusExam\lab_storage` and the result exports to
`backups\<timestamp>` (under `BACKUP_DIR`), checks the copy, clears the database in one transaction (all or nothing),
and last empties the folders. It prints what it cleared. If the database cannot be read, nothing is wiped.

| Wiped | Kept untouched |
|---|---|
| `lab_storage\packages`, `submissions` (sessions, answers, submissions, lock state, recovery history, suspicious events, PC recovery events), `results`, `credentials` (sitting unlock verifiers); `audit_storage\results` | `.env`, entirely (secrets, database login, instructor and staff hashes) |
| Database: examination cycles, sessions and sittings, packages and their receipts, results and result imports, per-sitting roster snapshots, unlock credentials, re-login and violation records, computer assignments, generated papers and paper versions, answer-key corrections, and the old exam, assignment, attempt and answer tables (`deploy/reset-data-db.js` lists them) | The RSA keys (`CampusExam\keys`, `CampusExam\lab_server_keys`); staff and student accounts; student rosters, departments, subjects, laboratories, question banks, the audit log; the service logs in `lab_storage\logs` |

The database rows are **not** in the backup; run `pg_dump` first if you may want them back. It never uses `CASCADE`:
if some table outside its list still references one of these, the database refuses and nothing changes. After a reset the
COE portal must load and activate a new package before students can log in. The reset only works with the default
`LAB_STORAGE_DIR` (`lab_storage/packages`) and says so if it is set to anything else.

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `409 WORKSTATION_IN_USE` at student login ("Another candidate is still signed in on this computer") | The previous candidate on this PC (this browser profile) has not submitted. | Ask the invigilator. Have the other candidate submit (that frees the computer), or use "Invigilator sign-in" to move a crashed session. |
| `409 SESSION_ACTIVE_ELSEWHERE` at student login ("already in progress on another computer") | The candidate started the exam in one browser profile and is signing in from another: a private window, another browser, or the same browser after its site data was cleared. | Ask the invigilator to use "Invigilator sign-in" in the browser the candidate is now using and approve the candidate's re-login. The candidate signs in again within 10 minutes and resumes the same attempt and timer. Each approval works once; moving again needs a new approval. |
| Blank white page, or the browser console says "mixed content" | The portal was built with an `http://` API address, which the browser refuses to call from an `https://` page. | The production build must be same-origin: `VITE_API_URL` and `VITE_LAB_API_BASE_URL` empty in the student portal's `.env.production`. Run `.\deploy\setup.ps1`, then `.\deploy\start-exam.ps1` (the gateway reads the portal when it starts). |
| `502 LAB_SERVER_UNAVAILABLE` from the gateway (`504 GATEWAY_TIMEOUT` if it is slow) | The gateway is up but the lab server is not answering. | Read `CampusExam\lab_storage\logs\lab-server.err.log`, then stop and start again. |
| The Tailscale command says Funnel is not enabled, or preflight says "not allowed to use Funnel" | The `funnel` node attribute or HTTPS is missing in the admin console. | Do the one-time admin-console steps above. |
| Preflight: "Port N is already in use" | An earlier run, or another program, holds the port. | `.\deploy\stop-exam.ps1`, or end the process named in the message in Task Manager. |
| Preflight: "PostgreSQL does not answer", or the central backend never opens its port | The PostgreSQL service is stopped, or `DB_URL`, `DB_USER`, `DB_PASSWORD` or `DB_NAME` in `.env` is wrong. | Start the service (Services, `postgresql-x64-NN`) and read `central.err.log`. |
| Timers wrong, or the exam is "not started yet" or "ended" at the wrong time | The host PC's clock or time zone is wrong. The lab server ignores any time a client sends. | Fix the clock (`w32tm /resync`) and the time zone, then restart the exam services. |
| `start-exam` or preflight says `STAFF_PASSWORD_HASH_ADMIN` (or `_COE`) is missing | The admin and COE accounts have no password until the hash is in `.env`. | Run `.\deploy\set-staff-password.ps1`, then restart the services. |
| Preflight: "A demo staff password still signs in" | The named principal or HOD accounts still hold the demo password from `database_dump.sql` or the README. | Run the `set-staff-password.ps1 -User ...` command preflight prints, write down the passwords, restart. |
| Students see "This examination's schedule could not be read, so sign-in is closed" (`500 SCHEDULE_INVALID`) | The package's date or start time is not a valid `YYYY-MM-DD` / `HH:MM[:SS]`. The lab server logs `Unreadable schedule for examination <id>` with the values it got. | Correct the sitting's date and time in the COE portal and send the package again. |
| Every student on one package gets "invalid credentials"; the lab log says `Activation into memory failed: java.lang.NullPointerException` | The package contains a null field, which the lab server cannot load. The COE portal now refuses to send such a package (next row), so this means a package prepared before that check existed. | Check the sitting's date and start time in the COE portal first, then prepare and send the package again. |
| COE portal: "Package not sent: `<field>` is missing for `<sitting>`. Nothing was sent to the Lab Server." (`400`) | The sitting is missing that field: date, start time, duration, subject, department, semester, cycle, a student's USN, name or date of birth, or a question's text, options or answer key. Or no question paper or roster has been generated yet. | Complete what the message names (the sitting's details, the roster, or the question paper), then send the package again. Nothing is generated or sent while a field is missing. |
| Downloading results says "Results were not generated: the package for this sitting has no `<field>`" (`409 PACKAGE_METADATA_MISSING`) | The package on the lab server has no subject, department, semester or cycle, which are printed on the official result documents. The lab no longer fills them in. | Prepare and send the package again from the COE portal, then download the results again. |
| Staff sign-in says `429 LOGIN_RATE_LIMITED` | Five failed logins in 60 s from that client. | Wait a minute. |
| Admin or COE password still the old one after `set-staff-password` | The central backend reads `.env` only when it starts. | `.\deploy\stop-exam.ps1`, then `.\deploy\start-exam.ps1`. |
| A COE or admin screen says it cannot reach the service, only over the public URL | That screen needs the lab server or the portal's converter, which the public gateways do not carry. | Use `http://127.0.0.1:3001` or `:3000` on the host PC. |
| `start-exam` says the instructor login is missing | `LAB_INSTRUCTOR_USERNAME` or `LAB_INSTRUCTOR_PASSWORD_HASH` is empty in `.env`. | Run `.\deploy\setup.ps1`; it prints a new password once. |

The route classification, gateway allowlist and environment variables below are reference material.

## Lab server route classification

Source: `dispatch()` in `CampusExam/LabServer.java`. Every route answers under the
prefixes `/lab-api/`, `/api/`, `/api/v1/`, `/lab-api/v1/` or bare; paths below are
shown with the prefix stripped. `{x}` is one path segment.

| Class | Method | Path(s) | Credential checked |
|---|---|---|---|
| PUBLIC | GET | `health` (and empty path) | none |
| STUDENT | POST | `student/login`, `auth/student-login` | USN + DOB + `workstationId` (this *is* the credential exchange) |
| STUDENT | POST | `student/logout` | student session token |
| STUDENT | GET | `student/instructions`, `student/exam-session`, `student/exam/questions`, `student/exam/state` | student session token |
| STUDENT | POST | `student/exam/start`, `student/exam/answers`, `student/exam/submit` | student session token; `answers`/`submit` reject a body `studentUsn` that differs from the token (403 `SESSION_MISMATCH`) |
| STUDENT | POST | `student/exam/heartbeat`, `student/heartbeat` | student session token |
| STUDENT | POST | `security/violation` | student session token; body `studentUsn` is ignored |
| STUDENT (recovery) | POST | `recovery/relogin-authorisations/consume`, `recovery/consume-token` | none of its own — see below |
| STUDENT PC (invigilator) | POST | `security/unlock`, `labs/{x}/sittings/{x}/verify-unlock` | invigilator unlock password, checked against the sitting's PBKDF2 verifier provisioned by central |
| INSTRUCTOR | POST | `instructor/login`, `recovery/login` | `LAB_INSTRUCTOR_USERNAME` + password checked against `LAB_INSTRUCTOR_PASSWORD_HASH` (credential exchange) |
| INSTRUCTOR | POST | `instructor/logout`, `recovery/logout` | none needed; removes the presented token |
| INSTRUCTOR | GET | `recovery/relogin-authorisations`, `recovery/overview`, `recovery/transfers`, `recovery/audit-logs`, `recovery/config`, `package/list` | `requireInstructor` |
| INSTRUCTOR | POST | `recovery/relogin-authorisations/approve`, `recovery/report-crash`, `package/manual-import`, `packages/activate`, `package/activate`, `results/transfer-to-central` | `requireInstructor` |
| SYSTEM | POST | `package/import`, `lab/package/import`, `labs/examinations/{id}/sittings/{x}/package-receipt` | SHA256withRSA signature against the central public key in `keys/`; payload AES-GCM encrypted to the lab key |
| SYSTEM | POST | `…/unlock-credential`, `security/provision-unlock-credential`, `…/unlock-credential/revoke` | SHA256withRSA signature against the central public key |
| LOCAL STAFF | GET | `labs/servers`, `labs/server` | `requireLocalStaff` only |
| LOCAL STAFF | GET | `package/receipt`, `labs/examinations/{id}/sittings/{x}/package-receipt` | `requireLocalStaff` only |
| LOCAL STAFF | GET | `monitoring/sessions`, `monitoring/sessions/{id}`, `monitoring/stream`, `monitoring/events` (SSE) | `requireLocalStaff` only |
| LOCAL STAFF | POST | `monitoring/sessions/{id}/unlock-event`, `labs/{x}/sittings/{x}/workstation-bind`, `labs/{x}/sittings/{x}/pc-recovery` | `requireLocalStaff` only |
| LOCAL STAFF | POST | `results/finalize`, `results/evaluate-and-export`, `lab/evaluate-and-export` | `requireLocalStaff` only |
| LOCAL STAFF | GET | `results/download`, `results/package` | `requireLocalStaff` only |
| TEST | POST | `test/reset-submissions`, `test/inject-ambiguity`, `test/remove-ambiguity`, `test/expire-session`, `test/activate-package` | 404 unless `LAB_TEST_MODE=true` |

`requireInstructor` accepts only a token issued by `instructor/login`: 128-bit
`SecureRandom`, held in memory for 8 hours (a server restart logs every instructor out).

There is no built-in instructor account, in any mode. `instructor/login` returns 503
`INSTRUCTOR_LOGIN_NOT_CONFIGURED` until both `LAB_INSTRUCTOR_*` variables are set. Create
the hash with `deploy/make-instructor-credential.ps1 [-Password <pw>]` or
`deploy/make-instructor-credential.sh [pw]`; with no password they generate a strong one
and print it once. Failed logins are limited to 5 per 60 s per workstation ID (then 429
`INSTRUCTOR_LOGIN_RATE_LIMITED`), and every failure in the last 60 s anywhere adds 1 s to
each later attempt, up to 30 s. Student logins keep their per-USN lockout (5 failures, 60 s)
and are also limited to 10 failures per 60 s per source (429 `RATE_LIMITED`). The source key
for both logins is the workstation ID, which a client supplies and can rotate, prefixed by
the client address when the gateway forwards one in `X-Gateway-Client` (see Gateway below).
With no trusted client address, the global delay above is what still slows an instructor
password guess; student guessing is then limited only by the per-USN lockout and the
per-workstation cap.
Test suites read the account from `LAB_INSTRUCTOR_USERNAME` / `LAB_INSTRUCTOR_PASSWORD`.

`requireLocalStaff` returns 403 `STAFF_ROUTE_LOCAL_ONLY` when the request carries an
`X-Gateway-Origin` header, or when the caller is neither loopback nor one of this host's
own interface addresses (skipped when `LAB_STAFF_ALLOW_REMOTE=true`). The gateway must set
`X-Gateway-Origin` on everything it proxies; anything that proxies from this host without
it — including `tailscale serve` pointed straight at port 8082 — arrives as loopback and
would pass the locality check.

### Routes with no credential of their own, and why

| Route(s) | Why it has no credential |
|---|---|
| `health` | Liveness probe. It reveals lab ID, package and cohort counts, and the active exam ID. |
| `student/login`, `instructor/login` | They issue the credential. |
| `instructor/logout` | It can only revoke the token it is given. |
| LOCAL STAFF routes (above) | Called by the COE portal, which sends the central JWT the lab server cannot verify, and, for `monitoring/sessions` only, by `CampusExam.java` (`fetchLabServerTelemetry`), which sends no auth header. No central→lab credential exists yet. Until one does, these are safe only from the lab server host itself. A COE browser or central server on another machine gets 403 unless `LAB_STAFF_ALLOW_REMOTE=true`, which re-opens them to anyone who can reach port 8082. |
| `recovery/relogin-authorisations/consume` | The student is on a replacement PC with no session. The route works only for a USN an instructor approved in the last 10 minutes, and the request must carry that approval's one-time `recoveryToken`. A refused request does not use the token up. The student portal does not send the token, so its consume call is refused and it falls back to its local path. |
| `security/unlock`, `…/verify-unlock` | The credential is the invigilator's unlock password in the body, not a token. |
| SYSTEM routes | No transport credential; the signed payload is the credential. |

### Lab server environment

| Variable | Default | Effect |
|---|---|---|
| `BIND` | `127.0.0.1` | Listen address. |
| `PORT` / `LAB_PORT` | `8082` | Listen port. |
| `LAB_TEST_MODE` | `false` | `true` honours `X-Simulated-Time-Ms`, `X-Effective-Time-Ms`, `simulatedTimestampMs`, `effectiveTimeMs`, `X-Bypass-Start-Check` and `forceStart`, and enables `test/*`. Never set it for a real examination. |
| `LAB_STAFF_ALLOW_REMOTE` | `false` | `true` lets non-local callers use the LOCAL STAFF routes. |
| `LAB_INSTRUCTOR_USERNAME` | unset | Instructor login name (case-insensitive). Central reads the same variable for its own `instructor/login`; with either variable unset or malformed, that login answers 503 `INSTRUCTOR_LOGIN_NOT_CONFIGURED`. |
| `LAB_INSTRUCTOR_PASSWORD_HASH` | unset | `<saltHex>:<hashHex>`, PBKDF2-HMAC-SHA256, 600000 iterations, 32-byte hash. Central reads it too. |

### Gateway (`deploy/gateway/server.js`)

This section describes the student profile. The admin and COE profiles use the same code with their own allowlists
(18 and 48 `/api/v1` routes, in `ADMIN_ROUTES` and `COE_ROUTES` in `server.js`), forward to central on `127.0.0.1:8081`, and
answer 401 before reading any body when a request to a non-login route has no `Authorization: Bearer` token.
`/lab-api/*` is a 404 on all three.

Serves the built student portal and forwards only the routes below to the lab server on
`127.0.0.1:8082`. It binds `127.0.0.1` only. Any other path, method or spelling under `/api`
is a plain 404. Only `Authorization`, `Content-Type`, `Accept` and `User-Agent` are passed on,
so a client's `X-Simulated-Time-Ms`, `X-Effective-Time-Ms` and `X-Bypass-Start-Check` never
arrive. It sets `X-Gateway-Origin: gateway` on every proxied request, replacing anything the
client sent. It reads the portal into memory at start, so a rebuild needs a restart.

| Proxied | Routes |
|---|---|
| PUBLIC | `GET health` |
| STUDENT | `POST student/login`, `student/logout`; `GET student/instructions`, `student/exam-session`, `student/exam/questions`, `student/exam/state`; `POST student/exam/start`, `student/exam/answers`, `student/exam/submit`, `student/exam/heartbeat`; `POST security/violation` |
| unlock | `POST security/unlock` |
| INSTRUCTOR (only what the portal calls) | `POST instructor/login`, `instructor/logout`; `GET recovery/relogin-authorisations`, `recovery/overview`, `recovery/transfers`, `recovery/audit-logs`, `recovery/config`; `POST recovery/relogin-authorisations/approve`, `recovery/relogin-authorisations/consume` |

Never proxied: LOCAL STAFF, SYSTEM and TEST routes, `package/*`, `results/*`,
`recovery/report-crash`, and the alias spellings the portal does not use
(`auth/student-login`, `student/heartbeat`, `recovery/login`, `recovery/logout`,
`recovery/consume-token`, `labs/{x}/sittings/{x}/verify-unlock`). The portal also calls three
paths the lab server does not serve: `PUT recovery/config`, `POST recovery/fresh-start` and
`GET security/audit-logs` (central serves that one). They are not proxied; each call fails
and the portal falls back to its local data.

| Variable | Default | Effect |
|---|---|---|
| `GATEWAY_PROFILE` | `student` | `student`, `admin` or `coe`: which routes, portal and upstream this instance serves. `start-exam` starts one of each. |
| `GATEWAY_PORT` | profile default (3002, 3003, 3004) | Port on `127.0.0.1`; `start-exam` sets it from `GATEWAY_PORT`, `ADMIN_GATEWAY_PORT` or `COE_GATEWAY_PORT`. |
| `LAB_PORT` | `8082` | Student profile only: lab server port on `127.0.0.1`. |
| `CENTRAL_PORT` | `8081` | Admin and COE profiles: central backend port on `127.0.0.1`. |
| `PORTAL_DIST_DIR` | the profile's portal `dist/` | Built portal to serve. |
| `GATEWAY_LOG_FILE` | `CampusExam/lab_storage/logs/gateway.log` (`gateway-admin.log`, `gateway-coe.log`) | Access log: time, method, path without query, status, client address. Never bodies or tokens. |
| `GATEWAY_MAX_BODY_BYTES` | `1048576` student, 60 MB admin and COE (uploads); logins 16 KB | Larger request bodies get 413. |
| `CLIENT_IP_HEADER` | unset | Name of the request header that carries the caller's address. |

`CLIENT_IP_HEADER` has no default because which header Tailscale Funnel sets is not assumed.
Start the gateway without it, send a request through the Funnel URL, and read the log: the
first time each header name arrives, a `HEADER-SEEN` line records it, with its value if the
name looks like an address. Set `CLIENT_IP_HEADER` to the header that holds the caller's IP.
The gateway believes that header only when it holds exactly one IP address; a list, or a
missing header, logs one `WARNING` line and the request is treated as having no trusted
address. With a trusted address the gateway sets `X-Gateway-Client` to it (replacing anything
the client sent), refuses a client's 21st failed login in a minute with 429, and the lab
server adds the address to its login limiter keys. With none, the gateway sends no
`X-Gateway-Client` and the lab server's own limits apply.

### Point Tailscale at the gateway ports only

`tailscale serve` or `tailscale funnel` must target a gateway port (`GATEWAY_PORT` 3002, `ADMIN_GATEWAY_PORT` 3003 or
`COE_GATEWAY_PORT` 3004) and never the lab server's 8082 or central's 8081, and never the dev portals on 3000 and 3001. Tailscale forwards from this host, so a tunnel aimed at 8082 reaches the lab server as a
loopback caller with no `X-Gateway-Origin` header, and `requireLocalStaff` treats it as local: the LOCAL STAFF
routes (`results/download`, `monitoring/*`, `labs/*`, ...) would be open to the internet. Only the gateway adds
`X-Gateway-Origin` and limits `/api` to the allowlist above. The syntax `tailscale funnel --bg <port>` was checked
against `tailscale funnel --help` on Tailscale 1.104.7; check it on your own version too.
