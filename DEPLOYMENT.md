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
| `GATEWAY_PORT` | `3002` | Port on `127.0.0.1`. |
| `LAB_PORT` | `8082` | Lab server port on `127.0.0.1`. |
| `PORTAL_DIST_DIR` | the portal's `dist/` | Built portal to serve. |
| `GATEWAY_LOG_FILE` | `CampusExam/lab_storage/logs/gateway.log` | Access log: time, method, path without query, status, client address. Never bodies or tokens. |
| `GATEWAY_MAX_BODY_BYTES` | `1048576` | Larger request bodies get 413. |
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

### Point Tailscale at the gateway port only

`tailscale serve` or `tailscale funnel` must target the gateway port (`GATEWAY_PORT`, default 3002) and never
the lab server's 8082. Tailscale forwards from this host, so a tunnel aimed at 8082 reaches the lab server as a
loopback caller with no `X-Gateway-Origin` header, and `requireLocalStaff` treats it as local: the LOCAL STAFF
routes (`results/download`, `monitoring/*`, `labs/*`, ...) would be open to the internet. Only the gateway adds
`X-Gateway-Origin` and limits `/api` to the allowlist above. The exact `tailscale` flags are to be verified on the
target machine with `tailscale funnel --help`.
