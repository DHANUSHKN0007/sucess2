# CampusExam — Deployment Handoff Prompt

**Goal:** someone who did not write this code pulls the repo, runs two scripts, pastes one Tailscale command, and a safe exam is reachable from students' browsers. All answers stay on the host PC.

```
git pull
.\deploy\setup.ps1          # once per machine
.\deploy\start-exam.ps1     # each exam: checks, starts, PRINTS the tailscale command
<paste the printed tailscale command>
.\deploy\stop-exam.ps1      # when the sitting ends
```

**Relationship to `TAILSCALE_HARDENING_PROMPT.md`:** this file **supersedes its Phase 6**, **corrects its Phases 2 and 4** (see "Corrections" at the bottom), and **adds Parts A–D**. Its Phases 3 and 5 still apply unchanged.

**Order of work:** Phase 1 and 1b committed → **Part A** → **Part B** → Phase 3 → Phase 5 → **Part C** → **Part D**. One part per session, one commit per numbered task.

## Ground rules

- No Docker. Commit directly on `main`, plain commit messages, **no Co-Authored-By trailer, no session link, no AI attribution**. **Never push.**
- Do not reformat files you are not changing. If a premise below is wrong when you read the code, **stop and report**.
- Nothing may listen on the LAN. Every service binds `127.0.0.1`; the only way in is Tailscale.
- Deployer may be unfamiliar with the code and is probably on Windows. Scripts: `.ps1` first, `.sh` equivalent second. Fail with a plain-English message and the fix, never a stack trace.

---

## Part A — Lock down LabServer (critical; do before anything public)

Verified in the current code. Any one of these defeats the exam if port 8082 is reachable.

| # | Finding | Where |
|---|---|---|
| A1 | **Client-controlled clock.** `getEffectiveTime` uses the request's `X-Simulated-Time-Ms` / `X-Effective-Time-Ms` headers or `simulatedTimestampMs` form field instead of the server clock. A student can start early, or keep answering after time is up. | `LabServer.java:1078-1090` |
| A2 | **Timer bypass.** `X-Bypass-Start-Check` header or `forceStart` field switches off the start-window and expiry checks. | `:1304, 1318, 1374, 1687, 1706-1710` |
| A3 | **Forgeable invigilator token.** `requireInstructor` lets through any bearer token starting `INSTR-AUTH-`, even if never issued. Tokens are made from `currentTimeMillis` + 8 chars. | `:2878-2890`, issued at `:2859` |
| A4 | **Unauthenticated test routes**: `test/reset-submissions` (wipes cohorts, packages, answers, sessions), `test/inject-ambiguity`, `test/remove-ambiguity`, `test/expire-session`, and the `test/activate-package` alias. | `:799-870` |
| A5 | **Staff routes with no `requireInstructor` visible**: `package/import`, `package/manual-import`, `packages/activate`, `results/finalize`, `results/download`, `results/transfer-to-central`, `monitoring/*`, `labs/servers`. Confirm each; assume exposed until proven otherwise. | `:652-756, :799-812` |

### Tasks

1. **`LAB_TEST_MODE` switch.** New env var, default `false`. When false: `getEffectiveTime` always returns `System.currentTimeMillis()`; `testBypass` is always false; `test/*` routes return 404; the headers and form fields above are **ignored silently** (no error — don't tell an attacker they exist). When true, print a loud banner at startup. Fixes A1, A2, A4.
2. **Real instructor tokens.** Generate with `SecureRandom` (128-bit), store in `RuntimeState.instructorSessions` with an expiry (default 8 h), and make `requireInstructor` accept **only** stored, unexpired tokens. Delete the `INSTR-AUTH-` prefix escape hatch. Fixes A3.
3. **Classify every route** in `dispatch()` as `STUDENT` (valid session token), `INSTRUCTOR` (`requireInstructor`), `SYSTEM` (central → lab, e.g. package import/activate, results transfer) or `TEST`. Add `requireInstructor` to every `INSTRUCTOR` route. For `SYSTEM` routes, read how `CampusExam.java` authenticates today (package signature against `keys/`?). If packages are signature-verified, document that and leave it. If not, **stop and report** the gap rather than inventing a protocol. Write the final classification table into `DEPLOYMENT.md` — Part B's gateway allowlist is built from it.
4. **Student routes take identity from the token, never the body.** Walk `student/exam/*`, `security/violation`, `student/heartbeat`; confirm each rejects missing/expired tokens and ignores any client-supplied `usn`.
5. **Tests.** Run the existing Python suites with `LAB_TEST_MODE=true`. Add tests proving that with it `false` (a) a forged `X-Simulated-Time-Ms` is ignored, (b) `test/reset-submissions` returns 404, (c) `Bearer INSTR-AUTH-anything` returns 401.

**Commits:** `Gate LabServer test hooks and client-supplied time behind LAB_TEST_MODE` · `Issue random expiring instructor tokens; remove INSTR-AUTH prefix bypass` · `Require instructor auth on staff routes` · `Add tests for lab server lockdown`

---

## Part B — Gateway: one public port, one Tailscale command

Why: Funnel to `127.0.0.1:8082` directly would expose the **whole** lab server (staff routes included). A small gateway gives Funnel one port to point at, serves the built portal, and lets only student-facing routes through.

### Tasks

1. **`deploy/gateway/server.js`** — Node built-ins only (`http`, `fs`, `path`); no new dependencies. Listens on `127.0.0.1:${GATEWAY_PORT:-3002}`.
   - Serves `student-portal/.../dist` with SPA fallback to `index.html`. Hashed assets: long cache. `index.html` and `/api/*`: `Cache-Control: no-store`. Refuse any `*.map` request.
   - Reverse-proxies `/api/*` to `127.0.0.1:8082`, **only** for routes on an allowlist (method + path pattern). Everything else returns a plain 404. Build the allowlist from the Part A classification **and** from what the portal actually calls — grep `student-portal/**/src` for every `/api/...` call. Expected set: `health`, `student/{login,logout,instructions,exam-session,exam/questions,exam/start,exam/state,exam/answers,exam/submit,exam/heartbeat}`, `security/{violation,unlock,audit-logs}`, `instructor/{login,logout}`, and the `recovery/*` routes the instructor page uses. Staff-only routes (`package/*`, `results/*`, `test/*`, `labs/*`, `monitoring/*`) are **not** on the allowlist.
   - **Strips** `X-Simulated-Time-Ms`, `X-Effective-Time-Ms`, `X-Bypass-Start-Check` before proxying (defence in depth; Part A already ignores them).
   - Body limit (default 1 MB), request timeout, and SSE pass-through only if the portal needs it.
   - Headers: `Content-Security-Policy` (`default-src 'self'`; no inline script unless the build needs it — check), `X-Frame-Options: DENY`, `X-Content-Type-Options: nosniff`, `Referrer-Policy: no-referrer`, `Permissions-Policy` denying camera/mic/geolocation.
   - Per-client rate limit on `student/login` and `instructor/login`. **Do not assume `X-Forwarded-For`**: log which client-address headers Tailscale Funnel actually sets, make the header name configurable (`CLIENT_IP_HEADER`), and fall back to a global login-rate ceiling if no trustworthy address is available.
   - Access log line per request (time, method, path, status, client id) to `lab_storage/logs/gateway.log`, **never** logging request bodies or tokens.
2. **Same-origin client** — execute Phase 2 of `TAILSCALE_HARDENING_PROMPT.md` with the correction below (base URL is the empty string).
3. **Tighten CORS** in `backend/server.js:34` to an env allowlist (Phase 2 task 5). The gateway makes cross-origin unnecessary.

**Acceptance:** with only the gateway reachable, student login → exam → submit works; `curl` to `/api/test/reset-submissions`, `/api/package/import`, `/api/results/download` through the gateway returns 404; `*.map` returns 404; no `127.0.0.1`/`192.168.` string appears in `dist/`.

**Commits:** `Add exam gateway serving portal and allowlisted student API` · `Resolve API base URL same-origin` · `Restrict backend CORS to configured origins`

---

## Part C — Deployer experience

### Tasks

1. **`.env.example`** — complete and commented. Add `JWT_SECRET=` (empty, required), `LAB_TEST_MODE=false`, `GATEWAY_PORT=3002`, `CLIENT_IP_HEADER=`, `ALLOWED_ORIGINS=`, `LAB_LINK_SECRET=` if Part A needed it. Remove the stale `192.168.1.100:8080` from `student-portal/.env.production`. Confirm `.gitignore` covers `.env`, `lab_storage/`, `*.pem`, key files and `node_modules`; add what is missing.
2. **`deploy/setup.ps1` (+ `.sh`)** — idempotent. Checks Node, JDK, PostgreSQL and Tailscale are installed and says exactly which is missing and where to get it; creates `.env` from `.env.example` **only if absent**, generating `JWT_SECRET` (≥48 random bytes, hex); `npm ci` in each app; production build of the student portal; compiles the Java; runs the existing DB init (read `init_database.ps1` first — never run a destructive reset without an explicit confirmation prompt).
3. **`deploy/preflight.ps1`** — callable alone and by start. Checks: required ports free; `.env` complete; `JWT_SECRET` set and ≥32 chars; `LAB_TEST_MODE` not true; `dist/` exists and contains no `.map`; Postgres reachable; `lab_storage` writable with free space reported; backup path writable; host sleep/hibernate disabled (`powercfg /query`); Tailscale installed, logged in, MagicDNS and HTTPS on. Each failure: one line stating the problem and the fix.
4. **`deploy/start-exam.ps1` (+ `.sh`)** — runs preflight, **refuses to start in exposed mode if any gate fails**, starts every service bound to `127.0.0.1` (reuse `start-all.ps1` logic; do not duplicate it badly), starts the gateway, waits for `/api/health` through the gateway, then **prints — never auto-runs —** the Tailscale command(s) and the resulting URL. Verify exact flag syntax against `tailscale funnel --help` on the machine; if Tailscale is absent where you work, mark the syntax "verify on target" in the docs rather than guessing. The expected public step is a single `tailscale funnel --bg <GATEWAY_PORT>`.
5. **`deploy/stop-exam.ps1` (+ `.sh`)** — stops all services, runs `tailscale funnel reset` (or the verified equivalent), confirms nothing is left listening, and reminds the deployer to export results and take the backup.
6. **Staff access** — admin/COE portals stay on the host PC's localhost; that is enough for exam prep. Remote staff access via `tailscale serve` is **optional** and documented separately, never required and never public.
7. **`DEPLOYMENT.md`** — one page a stranger can follow: prerequisites with versions; one-time Tailscale admin-console steps (enable MagicDNS and HTTPS; add the `funnel` node attribute to the tailnet policy — copy the current snippet from Tailscale's docs, don't write it from memory); one-time setup; **per-exam checklist** (power, wired network, sleep off, DB up, package loaded and activated by COE, exam code issued); start; verify from a phone **on mobile data**; during the exam; stop; export and backup; a troubleshooting table covering at least `409 WORKSTATION_IN_USE`, blank page / mixed-content, 502 from gateway, Funnel not enabled, port in use, DB down, wrong clock on host. State plainly: **the Funnel URL is public and appears in Certificate Transparency logs — access control is the exam code and per-student login, never URL secrecy**, and **Fullscreen/DevTools controls are deterrents, not locks**.
8. Link `DEPLOYMENT.md` from `README.md` and `SETUP_GUIDE.md`; reconcile contradictions rather than adding a third version of the truth.

**Commits:** one per numbered task.

---

## Part D — Final verification (a stranger's dry run)

1. `git clone` into a **fresh directory**; follow `DEPLOYMENT.md` literally, touching nothing from memory. Record every step where the doc was wrong or incomplete, fix the doc, repeat once.
2. With the stack up through the gateway only: two machines, two students, concurrent login → both succeed; duplicate computer number → 409 with the clear message.
3. Forged time header, forged `Bearer INSTR-AUTH-x`, `POST /api/test/reset-submissions`, `GET /api/results/download` → all rejected or 404.
4. Kill and restart the lab server mid-exam → sessions, answers and timers survive; report anything that does not.
5. Start with `JWT_SECRET` unset, then with `LAB_TEST_MODE=true`, then with `dist/` missing → `start-exam` refuses each time with a readable message.
6. `grep -r "127.0.0.1\|192.168\|localhost" dist/` → nothing baked in. No `.map` files.
7. Report: what changed, what is still open, anything skipped and why.

---

## Corrections to `TAILSCALE_HARDENING_PROMPT.md`

- **Phase 2 task 3 is wrong.** The client's endpoints already begin with `/api/` (e.g. `/api/student/login`), so a base URL of `/api` would send `/api/api/student/login`, which `LabServer.dispatch()` (it strips only one `api/`) would not route. The base URL must be the **empty string**.
- **Phase 4's premise is mostly wrong.** Answers are not RAM-only: `saveAnswersToDisk` runs on answer save (`LabServer.java:1977`), sessions go through `saveSessionToDisk` (`:2373`), submissions are written at `:2335`, lock states, transfers and audit logs at `:2451-2462`. **Before adding anything, audit what is persisted and test a mid-exam restart.** Known gaps to check: `saveSessionToDisk`/`saveAnswersToDisk` rewrite whole files non-atomically (only the helper at `:2395` uses temp-file + `SYNC`), so a crash mid-write can corrupt a student's file; startup replay is unverified; no append-only log, hash chain, or periodic snapshot. Fix those; do not rebuild persistence that exists.
- **Phase 6 is superseded** by Parts B and C. Do not path-mount Funnel to two ports.
