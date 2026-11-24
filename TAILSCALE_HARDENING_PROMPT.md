# CampusExam — Fix, Harden & Tailscale-Ready Prompt

**Target repo:** this working directory (`sucess2-main`)
**Goal:** fix the multi-machine login failure, make the codebase safe to expose over a Tailscale Funnel link, close the known security holes, and harden exam-integrity (inspect-element) controls — while all examination data stays on the host PC.

---

## 0. Ground rules

- **No Docker.** This repo has no Dockerfile and does not need one. Do not introduce containers.
- **Commit directly on `main`** after each completed phase. Plain commit messages. **No** `Co-Authored-By` trailers, no session links, no AI attribution of any kind.
- **Never `git push`.** The repo owner pushes manually when everything is done.
- Do not reformat or restructure files you are not changing. Keep diffs reviewable — this is a team repo.
- Where a change alters how the system is started or configured, update `.env.example`, `SETUP_GUIDE.md` and `README.md` in the same phase.
- If a phase's premise turns out to be wrong when you read the code, **stop and report** instead of inventing a workaround.

### Service map (for reference)

| Service | Port | Audience |
|---|---|---|
| Node unified backend (`backend/server.js`) | 8080 | admin/COE — **internal only** |
| `CampusExam.java` central | 8081 | admin/COE — **internal only** |
| `LabServer.java` lab server | 8082 | **students** |
| Admin portal | 3000 | internal only |
| COE portal | 3001 | internal only |
| Student portal | 3002 | **students** |
| Document converter | 5001 | internal only |

Only **3002 + 8082** are ever reachable from the public internet. Everything else is tailnet-only.

---

## Phase 1 — Fix the workstation-ID collision (the real bug)

**Symptom:** when one student logs in, every other machine is rejected.

**Cause:** `CampusExam/LabServer.java:1179` defaults the workstation ID to the literal `"PC-01"` when the client omits it:

```java
String comp = String.valueOf(form.getOrDefault("workstationId",
    form.getOrDefault("computerNumber", "PC-01"))).trim().toUpperCase(Locale.ROOT);
```

The student portal never sends that field — `StudentLoginRequest` (`src/types/examination.ts:34`) carries only `usn` and `dateOfBirth`. So every browser claims to be `PC-01`, and the one-candidate-per-workstation safeguard at `LabServer.java:1344` correctly rejects the second student with `409 WORKSTATION_IN_USE`.

**Do NOT "fix" this by deriving the ID from the remote IP.** Behind a Tailscale Funnel all requests arrive from the Tailscale proxy on loopback, so every student would share one address and collide identically. The ID must come from the client.

### Tasks

1. **Server — fail closed.** In `handleStudentLogin` (`LabServer.java:1179`), remove the `"PC-01"` fallback. If `workstationId`/`computerNumber` is blank, throw:
   ```java
   throw new LabException(400, "Workstation ID is required", "MISSING_WORKSTATION_ID");
   ```
   Leave the binding/safeguard logic at lines 1340-1360 unchanged — it is correct.

2. **Frontend — resolve a stable per-machine ID.** Add a small module (e.g. `src/services/workstationService.ts`):
   - Read key `mitm_workstation_id` from `localStorage`.
   - If absent, generate `WS-${crypto.randomUUID().slice(0,8).toUpperCase()}` and persist it.
   - Export a setter so an invigilator can overwrite it with the real sticker number.
   - `localStorage` is the correct scope here: the ID belongs to the **machine**, unlike the session token (see Phase 3).

3. **Login form — make it meaningful.** Add a short, required **"Computer Number"** field to `src/pages/login/StudentLoginPage.tsx`, pre-filled from `workstationService` and editable. A random UUID stops the 409 but makes the safeguard useless; a typed `PC-07` matching the label on the machine keeps the safeguard real and gives the COE monitoring view (`LabServer.java:2744`) truthful data.

4. **Wire it through.** Add `workstationId: string` to `StudentLoginRequest` (`src/types/examination.ts:34`), include it in the payload sent from `useExamSession.tsx:510` / `studentAuthService.login()`.

5. **Surface the 409 clearly.** When the API returns `WORKSTATION_IN_USE`, show the student the server's message (which names the occupying USN) plus "ask your invigilator" — not a generic failure toast.

**Acceptance:** two different machines log in two different students concurrently and both reach the instructions page. A third browser deliberately sending a duplicate computer number still gets the 409.

**Commit:** `Fix workstation ID collision causing 409 on concurrent student logins`

---

## Phase 2 — Same-origin API client (required for Tailscale)

`src/api/client.ts:62-81` resolves the API base URL in a way that cannot work behind an HTTPS tunnel:

```ts
} else if (window.location && window.location.hostname && window.location.hostname !== 'localhost' && ...) {
  resolvedUrl = `http://${window.location.hostname}:8082`;
}
...
this.baseUrl = (resolvedUrl && !resolvedUrl.includes(':8080') ? resolvedUrl : 'http://127.0.0.1:8082')...
```

Three defects:
- **Mixed content.** A Funnel-served page is HTTPS; a `http://host:8082` fetch is blocked outright by the browser. This alone breaks the whole portal once tunnelled.
- **The `:8080` filter silently discards any configured URL containing `:8080`** — including this repo's own `.env.production` (`VITE_API_URL=http://192.168.1.100:8080`) — and falls back to `127.0.0.1:8082`, i.e. the student's own laptop.
- Hardcoded ports and IPs make LAN / tunnel / localhost three different builds.

### Tasks

1. Rewrite the `ApiClient` constructor so the **default base URL is the empty string** (same-origin relative requests). Precedence: explicit `VITE_LAB_API_BASE_URL` → `window.__ENV__` override → `localStorage` override (keep for debugging) → `''`.
2. **Delete the `:8080` filter** and the `http://${hostname}:8082` branch entirely.
3. Set `VITE_LAB_API_BASE_URL=` (empty string) in `.env.production` — the client's endpoints already begin with `/api/`, so a `/api` base would send `/api/api/...` and not route. Leave `.env.development` pointing at `http://localhost:8082` for local work.
4. Confirm path handling end-to-end: the client posts `/api/student/login`, and `LabServer.dispatch()` (`LabServer.java:632`) strips a leading `api/`. This resolves correctly whether or not the tunnel strips the mount prefix — verify both, do not assume.
5. Tighten CORS in `backend/server.js:34` — replace `origin: true` with an explicit allowlist read from env. Same-origin requests need no CORS at all; the wildcard-with-credentials setting is a liability.
6. Add a Vite dev-server `allowedHosts` entry for the `.ts.net` hostname (env-driven), for dev only.

**Acceptance:** `npm run build` output served statically works unchanged on localhost, over LAN, and behind an HTTPS tunnel, with no IP baked into the bundle and zero CORS preflights.

**Commit:** `Resolve API base URL same-origin; remove hardcoded ports and 8080 filter`

---

## Phase 3 — Security fixes (do these BEFORE any tunnel goes up)

1. **Hardcoded JWT secret.** `backend/server.js:20`:
   ```js
   const JWT_SECRET = process.env.JWT_SECRET || 'mitm_ems_jwt_secret_key_2026';
   ```
   That literal is in a public GitHub repo — anyone can mint valid Principal/HOD tokens. Make the server **throw on boot** if `JWT_SECRET` is missing or shorter than 32 chars. Add it to `.env.example` with a generation hint, never a real value.

2. **Header-based identity spoofing.** `backend/server.js:878, 936, 964, 1040, 1120, 1153, 1181, 1204` all do:
   ```js
   const deptId = req.headers['x-hod-department-id'] || req.user?.departmentId || 'CS';
   ```
   The client-supplied header outranks the verified token, and defaults to `CS`. Invert it: take the department from `req.user` only, 401 if there is no verified token, and accept the header solely as a Principal-role override.

3. **Permissive auth middleware.** `authenticateToken` (`backend/server.js:50-63`) swallows invalid tokens and calls `next()`, so most routes are effectively unauthenticated. Add a `requireAuth` / `requireRole` middleware and apply it to every `/principal/*`, `/hod/*`, `/coe/*`, `/examinations/*`, `/results/*` and `/monitoring/*` route. Keep `/health` and the login routes open.

4. **Unauthenticated submit-as-anyone.** `backend/server.js:557` — `/student/exam/submit` reads `usn` from the request body and marks that student submitted, with no token check. The LabServer equivalent validates session tokens properly (`LabServer.java:1505-1515`). Either delete the duplicated student routes from the Node backend or gate them behind `requireAuth` and take the USN from the token, never the body.

5. **Fabricated fallback exam.** `backend/server.js:441` invents a fake `CS501 / Advanced Algorithms` paper when no exam is scheduled. Remove it, or gate it behind an explicit `ALLOW_SAMPLE_EXAM=true` dev flag, and return a clear "no scheduled examination" response otherwise.

6. **Credential strength + enumeration.** Student auth is USN + DOB — sequential IDs and low-entropy secrets. The rate limit at `LabServer.java:1186` is **per-USN** (5 attempts / 60s) and does nothing against sweeping across USNs. Add:
   - a per-source-address attempt cap with exponential backoff,
   - a global failed-login ceiling per sitting that raises an alert,
   - a **per-sitting exam code** the invigilator announces, required as a third login field and validated against the sitting record.

7. **Session token storage.** `src/api/client.ts:142-152` writes the token to **both** `sessionStorage` and `localStorage`, and `getStoredToken()` falls back to `localStorage`. On a shared lab PC the `localStorage` copy outlives the tab and is shared across tabs, so a later student can inherit or clobber an earlier session. Use `sessionStorage` only, for both read and write.

8. **Persist the audit trail.** `RuntimeState.suspiciousEvents`, `recoveryAuditLogs`, `sessionTransfers` and `pcRecoveryEvents` (`LabServer.java:97-100`) are in-memory only. Append each to a local append-only file (and/or Postgres) at write time so a restart cannot erase the evidence.

**Commit each numbered item separately**, e.g. `Require JWT_SECRET from environment`, `Derive HOD department from verified token`, …

---

## Phase 4 — Durable local answer storage

> **CORRECTED — read `DEPLOYMENT_HANDOFF_PROMPT.md` "Corrections" first.** Answers are already persisted to disk (`saveAnswersToDisk`, `saveSessionToDisk`). Audit and harden what exists; do not rebuild it. The "RAM-only" premise below is wrong.

`RuntimeState.studentAnswers`, `studentSessions`, `studentSubmissions`, `studentReceipts` (`LabServer.java:83-88`) are `ConcurrentHashMap`s. "Data stays on the local PC" currently means **in RAM** — a crash or restart at minute 40 of a 90-minute exam loses the room.

### Tasks

1. Write every answer through to durable local storage **at save time**, not at submit time: Postgres on the host, or an append-only JSONL file per sitting under `LAB_STORAGE_DIR`.
2. Make it an **append-only event log** (`usn, questionId, answer, serverTimestamp, seq`) rather than an in-place update, so a late or duplicated write can never silently overwrite an earlier answer.
3. On lab-server startup, **replay** the log to rebuild `RuntimeState` so an in-progress exam survives a restart.
4. Add a hash chain over submissions (`hash(prev_hash + payload)`) so post-hoc tampering with the stored file is detectable.
5. Snapshot the store to a second local path every 1-2 minutes during an active sitting.

**Commit:** `Persist student answers to append-only local log with startup replay`

---

## Phase 5 — Exam integrity / inspect-element lock

`src/hooks/useExaminationSecurity.ts` already covers visibility change, window blur, fullscreen exit, `contextmenu`, copy/paste, and some key blocking (`F12` at line 202). **Harden what exists; do not rewrite it.**

### Be honest about the limits

DevTools cannot be blocked from inside a web page. A determined student can open DevTools before navigating, use a browser menu instead of a shortcut, disable JavaScript, or read the JSON straight off the network. Treat every client-side control below as a **deterrent that generates an audit event**, and make the *server* the real control. State this plainly in the docs you write — do not let anyone believe the client is a lock.

### Client-side tasks

1. Extend the `handleKeyDown` blocklist at `LabServer`-facing hook `useExaminationSecurity.ts:180-210` to cover: `F12`, `Ctrl/Cmd+Shift+I`, `Ctrl/Cmd+Shift+J`, `Ctrl/Cmd+Shift+C`, `Ctrl/Cmd+U` (view-source), `Ctrl/Cmd+S`, `Ctrl/Cmd+P`, `Ctrl/Cmd+Shift+P`. Keep `capture: true`.
2. Keep the existing `contextmenu` suppression; add `selectstart` and `dragstart` suppression on the question pane only (not on input fields).
3. Add a **DevTools-open heuristic**: poll `window.outerWidth - window.innerWidth` and `outerHeight - innerHeight` against a threshold, and/or a timing check on a `debugger` statement. On trip, raise the existing security-violation path — the same one tab-switching uses — rather than a new mechanism.
4. Route **every** violation through `securityService` to the server as an audit event with `usn`, `workstationId`, violation type and server timestamp. Enforce the lock screen (`FullScreenSecurityLockScreen.tsx`) server-side: the server records the lock state, and only a COE/invigilator credential clears it. A reload must not clear a lock.
5. Require fullscreen to start the exam (the hook already re-requests it at line 384) and treat exit as a violation, not an auto-recovery.

### Build-side tasks

6. **Disable source maps for production builds** in `vite.config.ts` (`build.sourcemap: false`). Shipping maps makes reading the client trivial.
7. Ensure correct answers never reach the browser. Audit the question-paper payload from `LabServer` and the `questionService` response: strip any answer-key field. `RuntimeState.answerKeys` (`LabServer.java:79`) must stay server-side — grading happens on the server.
8. Server-authoritative timing only. The client clock is advisory; `timerService.fetchAuthoritativeState()` already exists — confirm no path lets a client extend its own deadline.

**Commit:** `Harden examination security controls and log violations server-side`

---

## Phase 6 — Tailscale deployment readiness

> **SUPERSEDED** by Parts B and C of `DEPLOYMENT_HANDOFF_PROMPT.md` (single gateway port; do not path-mount Funnel to two services).

### Topology

- **Public (Funnel), one hostname, path-mounted:**
  - `/` → `http://127.0.0.1:3002` (built student portal, served statically)
  - `/api` → `http://127.0.0.1:8082` (lab server)
- **Tailnet-only (`tailscale serve`):** 3000, 3001, 8080, 8081, 5001. Invigilators/HODs join the tailnet; admin surfaces never face the internet.

Funnel constraints to document: only ports 443 / 8443 / 10000, HTTPS must be enabled on the tailnet, the `funnel` node attribute must be set in the tailnet policy, and traffic rides Tailscale relays (no bandwidth guarantee). TLS terminates on the host PC, so Tailscale relays bytes it cannot read.

### Tasks

1. Add `start-exam-tunnel.ps1` and `start-exam-tunnel.sh` that: verify the build exists, start the lab server and a static file server for `dist/`, then print the exact `tailscale funnel` / `tailscale serve` commands. **Print, do not auto-run** the tunnel commands — exposure must be a deliberate human act. Verify the flag syntax against `tailscale serve --help` on the installed version rather than assuming.
2. Add `stop-exam-tunnel.*` that runs `tailscale funnel off` / `tailscale serve off` and stops the services.
3. With Funnel as the only ingress, **keep `BIND=127.0.0.1`** (the `LabServer.java:43` default) — nothing needs to listen on the LAN interface, which is strictly safer than `-Mode LAN`. Update `start-all.ps1` docs so `-Mode LAN` is clearly the alternative, not a prerequisite.
4. **Serve a production build, never the Vite dev server,** through the tunnel. Add an npm script for build-and-serve-static.
5. Document in `SETUP_GUIDE.md`: the Funnel hostname appears in public Certificate Transparency logs, so the URL is **not** a secret — access control is the exam code plus per-student auth, never URL obscurity. Turn the Funnel off outside the exam window.
6. Add a pre-exam checklist: host PC sleep/hibernate disabled, on wired ethernet or mains power, Postgres running, disk space checked, backup path writable, tunnel reachable from a phone on mobile data.

**Commit:** `Add Tailscale exam tunnel scripts and deployment documentation`

---

## Phase 7 — Verification

Report results for each; do not mark a phase done on a passing build alone.

1. Two machines, two students, concurrent login → both succeed (Phase 1).
2. Duplicate computer number → `409 WORKSTATION_IN_USE` with a clear message (Phase 1).
3. Production build served over HTTPS → zero mixed-content errors, zero CORS preflights, no hardcoded IP in `dist/` (`grep` the bundle) (Phase 2).
4. Boot the Node backend without `JWT_SECRET` → refuses to start (Phase 3).
5. `GET /hod/dashboard` with a forged `x-hod-department-id` header and no token → 401 (Phase 3).
6. `POST /student/exam/submit` for another student's USN → rejected (Phase 3).
7. Kill and restart the lab server mid-exam → answers and timers survive (Phase 4).
8. Trip a security violation, then reload → lock state persists (Phase 5).
9. `grep` the question-paper network response for answer-key fields → none present (Phase 5).
10. `dist/` contains no `.map` files (Phase 5).

End with a short written summary of what changed, what is still open, and anything you chose not to do and why.
