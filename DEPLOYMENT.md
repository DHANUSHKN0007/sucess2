# Deployment

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
each later attempt, up to 30 s. The workstation ID is client-supplied; the gateway can
later supply a trusted client address at the `PART B HOOK` in `LabServer.java`.
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
| `recovery/relogin-authorisations/consume` | The student is on a replacement PC with no session. The route works only for a USN an instructor approved in the last 10 minutes. The one-time `recoveryToken` is checked only if sent, and the student portal does not send it. |
| `security/unlock`, `…/verify-unlock` | The credential is the invigilator's unlock password in the body, not a token. |
| SYSTEM routes | No transport credential; the signed payload is the credential. |

### Lab server environment

| Variable | Default | Effect |
|---|---|---|
| `BIND` | `127.0.0.1` | Listen address. |
| `PORT` / `LAB_PORT` | `8082` | Listen port. |
| `LAB_TEST_MODE` | `false` | `true` honours `X-Simulated-Time-Ms`, `X-Effective-Time-Ms`, `simulatedTimestampMs`, `effectiveTimeMs`, `X-Bypass-Start-Check` and `forceStart`, and enables `test/*`. Never set it for a real examination. |
| `LAB_STAFF_ALLOW_REMOTE` | `false` | `true` lets non-local callers use the LOCAL STAFF routes. |
| `LAB_INSTRUCTOR_USERNAME` | unset | Instructor login name (case-insensitive). |
| `LAB_INSTRUCTOR_PASSWORD_HASH` | unset | `<saltHex>:<hashHex>`, PBKDF2-HMAC-SHA256, 600000 iterations, 32-byte hash. |
