"""
Lab server lockdown checks. Run against a lab server started WITHOUT LAB_TEST_MODE
(the production default) on 127.0.0.1:8082, with an active exam whose roster contains
4MH21CS003 / 2004-01-03 (the same roster the Phase 8 suite uses).

Set LAB_INSTRUCTOR_USERNAME and LAB_INSTRUCTOR_PASSWORD to the instructor account the
server was started with. Leave them unset to check a server started without one (login
must then be disabled). Takes ~20 s because failed instructor logins slow later attempts.

Central (CENTRAL_URL, default http://127.0.0.1:8081) reads the same two variables, so start it with the
same account. If central is not reachable its checks are skipped, not failed.
"""
import json
import os
import statistics
import sys
import time
import urllib.error
import urllib.request

LAB = "http://127.0.0.1:8082/api"
CENTRAL = os.environ.get("CENTRAL_URL", "http://127.0.0.1:8081") + "/api"
INSTRUCTOR_ID = os.environ.get("LAB_INSTRUCTOR_USERNAME", "")
INSTRUCTOR_PASSWORD = os.environ.get("LAB_INSTRUCTOR_PASSWORD", "")
OLD_BUILT_IN_LOGINS = [("lab", "lab@123"), ("EMGR-LOGIN-01", "ProTick-0011")]
results = []


def call(method, path, data=None, headers=None, base=LAB):
    req = urllib.request.Request(f"{base}/{path}", method=method, headers={"Content-Type": "application/json", **(headers or {})},
                                 data=json.dumps(data).encode() if data is not None else None)
    try:
        with urllib.request.urlopen(req, timeout=40) as r:
            return r.status, json.loads(r.read().decode() or "{}")
    except urllib.error.HTTPError as e:
        return e.code, json.loads(e.read().decode() or "{}")


def check(name, ok, details):
    results.append(ok)
    print(f"[{'PASS' if ok else 'FAIL'}] {name} - {details}")


def check_central():
    try:
        call("GET", "health", base=CENTRAL)
    except urllib.error.URLError as e:
        print(f"[SKIP] Central instructor login checks - central not reachable at {CENTRAL} ({e.reason})")
        return
    attempts = [("blank login", {"recoveryId": "", "recoveryKey": ""}), ("login with no fields", {})]
    attempts += [(f"old built-in login {user}", {"recoveryId": user, "recoveryKey": password}) for user, password in OLD_BUILT_IN_LOGINS]
    for name, payload in attempts:
        code, body = call("POST", "instructor/login", payload, base=CENTRAL)
        if INSTRUCTOR_ID and INSTRUCTOR_PASSWORD:
            check(f"Central refuses {name}", code == 401, f"HTTP {code}")
        else:
            check(f"Central (no instructor account configured) refuses {name}",
                  code == 503 and body.get("code") == "INSTRUCTOR_LOGIN_NOT_CONFIGURED", f"HTTP {code}, {body.get('code')}")
    if INSTRUCTOR_ID and INSTRUCTOR_PASSWORD:
        code, body = call("POST", "instructor/login", {"recoveryId": INSTRUCTOR_ID, "recoveryKey": INSTRUCTOR_PASSWORD}, base=CENTRAL)
        check("Central accepts the configured instructor", code == 200 and body.get("authenticated") is True, f"HTTP {code}")


def main():
    forged ={"X-Simulated-Time-Ms": "0", "X-Effective-Time-Ms": "0", "X-Bypass-Start-Check": "1"}

    # (a) A forged client clock is ignored. Honoured, 1970 would reject the login as not started.
    code, login = call("POST", "student/login", {"usn": "4MH21CS003", "dateOfBirth": "2004-01-03", "workstationId": "LOCKDOWN-PC-03",
                                                 "simulatedTimestampMs": 0, "effectiveTimeMs": 0}, forged)
    skew = abs(login.get("serverTimestampMs", 0) / 1000 - time.time())
    check("Forged clock ignored on login", code == 200 and skew < 60, f"HTTP {code}, server clock skew {skew:.0f}s")
    token = login.get("student", {}).get("sessionToken")
    code, hb = call("POST", "student/heartbeat", {"simulatedTimestampMs": 0}, {"Authorization": f"Bearer {token}", **forged})
    skew = abs(hb.get("serverTimestampMs", 0) / 1000 - time.time())
    check("Forged clock ignored on heartbeat", code == 200 and skew < 60, f"HTTP {code}, server clock skew {skew:.0f}s")

    # (b) Test hooks look exactly like unknown routes.
    for path in ["test/reset-submissions", "test/activate-package", "test/expire-session"]:
        code, body = call("POST", path, {})
        check(f"{path} hidden", code == 404 and body.get("errorCode") == "NOT_FOUND", f"HTTP {code}")
    code, health = call("GET", "health")
    check("Exam survives reset attempt", health.get("packagesLoaded", 0) > 0, f"packagesLoaded={health.get('packagesLoaded')}")

    # (c) The old INSTR-AUTH- prefix no longer authenticates.
    forged_instr = {"Authorization": "Bearer INSTR-AUTH-anything"}
    code, _ = call("POST", "recovery/relogin-authorisations/approve", {"usn": "4MH21CS003", "reason": "x"}, forged_instr)
    check("Forged INSTR-AUTH token rejected on approve", code == 401, f"HTTP {code}")
    code, _ = call("GET", "package/list", headers=forged_instr)
    check("Forged INSTR-AUTH token rejected on package/list", code == 401, f"HTTP {code}")

    if INSTRUCTOR_ID and INSTRUCTOR_PASSWORD:
        # Issued instructor tokens work until logout.
        code, inst = call("POST", "instructor/login", {"recoveryId": INSTRUCTOR_ID, "recoveryKey": INSTRUCTOR_PASSWORD, "workstationId": "LOCKDOWN-B"})
        auth = {"Authorization": f"Bearer {inst.get('token')}"}
        code, _ = call("GET", "package/list", headers=auth)
        check("Issued instructor token accepted", code == 200, f"HTTP {code}")
        call("POST", "instructor/logout", headers=auth)
        code, _ = call("GET", "package/list", headers=auth)
        check("Instructor token rejected after logout", code == 401, f"HTTP {code}")
    else:
        for user, password in OLD_BUILT_IN_LOGINS:
            code, body = call("POST", "instructor/login", {"recoveryId": user, "recoveryKey": password})
            check(f"No instructor account configured: {user} refused", code == 503 and body.get("errorCode") == "INSTRUCTOR_LOGIN_NOT_CONFIGURED", f"HTTP {code}, {body.get('errorCode')}")

    # An unknown USN and a wrong DOB are indistinguishable by body and comparable in time.
    # Four wrong-DOB tries per USN stays under the per-USN lockout of five. Medians over 16
    # samples, because single requests on a desktop host jitter by 10-25 ms either way.
    unknown, wrong_dob, bodies = [], [], set()
    for i in range(16):
        for samples, usn, dob in [(unknown, f"4MH99ZZ{i:03d}", "2004-01-01"), (wrong_dob, f"4MH21CS00{6 + i % 4}", "1999-12-31")]:
            started = time.perf_counter()
            # A workstation ID of its own per probe keeps the per-source failure cap (checked below) out of this comparison.
            code, body = call("POST", "student/login", {"usn": usn, "dateOfBirth": dob, "workstationId": f"LOCKDOWN-{usn}"})
            samples.append((time.perf_counter() - started) * 1000)
            bodies.add((code, body.get("errorCode"), body.get("error"), body.get("message")))
    check("Unknown USN and wrong DOB give identical responses", len(bodies) == 1, f"{len(bodies)} distinct: {sorted(bodies)[0][:2]}")
    gap = abs(statistics.median(unknown) - statistics.median(wrong_dob))
    check("Unknown USN and wrong DOB take comparable time", gap < 25, f"median gap {gap:.1f} ms")

    # Sweeping many USNs from one workstation is cut off before the per-USN lockout ever applies.
    for i in range(10):
        code, _ = call("POST", "student/login", {"usn": f"4MH98ZZ{i:03d}", "dateOfBirth": "2004-01-01", "workstationId": "LOCKDOWN-SWEEP"})
    check("10th failed student login from one workstation still answered 401", code == 401, f"HTTP {code}")
    code, body = call("POST", "student/login", {"usn": "4MH98ZZ010", "dateOfBirth": "2004-01-01", "workstationId": "LOCKDOWN-SWEEP"})
    check("11th failed student login from one workstation rate-limited", code == 429 and body.get("errorCode") == "RATE_LIMITED", f"HTTP {code}, {body.get('errorCode')}")

    # Staff routes refuse anything the gateway forwarded.
    code, body = call("GET", "monitoring/sessions", headers={"X-Gateway-Origin": "gateway"})
    check("Gateway-forwarded staff request refused", code == 403 and body.get("errorCode") == "STAFF_ROUTE_LOCAL_ONLY", f"HTTP {code}")

    # Violations need a student session; a body studentUsn alone is not enough.
    code, _ = call("POST", "security/violation", {"studentUsn": "4MH21CS003", "violationType": "TAB_SWITCH", "label": "Tab"})
    check("Violation without session rejected", code == 401, f"HTTP {code}")

    if INSTRUCTOR_ID and INSTRUCTOR_PASSWORD:
        # Old built-in logins are gone. These and the next three failures all come from workstation A.
        for user, password in OLD_BUILT_IN_LOGINS:
            code, _ = call("POST", "instructor/login", {"recoveryId": user, "recoveryKey": password, "workstationId": "LOCKDOWN-A"})
            check(f"Old built-in login {user} rejected", code == 401, f"HTTP {code}")
        for _ in range(3):
            code, _ = call("POST", "instructor/login", {"recoveryId": INSTRUCTOR_ID, "recoveryKey": "wrong-password", "workstationId": "LOCKDOWN-A"})
        check("Wrong instructor password rejected", code == 401, f"HTTP {code}")
        code, body = call("POST", "instructor/login", {"recoveryId": INSTRUCTOR_ID, "recoveryKey": INSTRUCTOR_PASSWORD, "workstationId": "LOCKDOWN-A"})
        check("6th attempt from same workstation rate-limited", code == 429 and body.get("errorCode") == "INSTRUCTOR_LOGIN_RATE_LIMITED", f"HTTP {code}")
        # Another workstation is not locked out, only slowed by the five recent failures.
        started = time.time()
        code, _ = call("POST", "instructor/login", {"recoveryId": INSTRUCTOR_ID, "recoveryKey": INSTRUCTOR_PASSWORD, "workstationId": "LOCKDOWN-B"})
        waited = time.time() - started
        check("Other workstation signs in after a delay", code == 200 and waited >= 4, f"HTTP {code}, waited {waited:.1f}s")

    # A violation missing its details is a client error, not a server crash.
    token = call("POST", "student/login", {"usn": "4MH21CS005", "dateOfBirth": "2004-01-05", "workstationId": "LOCKDOWN-PC-05"})[1].get("student", {}).get("sessionToken")
    for missing in ["label", "violationType"]:
        payload = {"violationType": "TAB_SWITCH", "label": "Tab"}
        del payload[missing]
        code, body = call("POST", "security/violation", payload, {"Authorization": f"Bearer {token}"})
        check(f"Violation without {missing} rejected with 400", code == 400 and body.get("errorCode") == "MISSING_VIOLATION_DETAILS", f"HTTP {code}, {body.get('errorCode')}")

    check_central()

    passed = sum(results)
    print(f"\nLOCKDOWN RESULTS: {passed} PASSED / {len(results) - passed} FAILED")
    sys.exit(0 if passed == len(results) else 1)


if __name__ == "__main__":
    main()
