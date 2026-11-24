"""
Lab server lockdown checks. Run against a lab server started WITHOUT LAB_TEST_MODE
(the production default) on 127.0.0.1:8082, with an active exam whose roster contains
4MH21CS003 / 2004-01-03 (the same roster the Phase 8 suite uses).
"""
import json
import sys
import time
import urllib.error
import urllib.request

LAB = "http://127.0.0.1:8082/api"
results = []


def call(method, path, data=None, headers=None):
    req = urllib.request.Request(f"{LAB}/{path}", method=method, headers={"Content-Type": "application/json", **(headers or {})},
                                 data=json.dumps(data).encode() if data is not None else None)
    try:
        with urllib.request.urlopen(req, timeout=10) as r:
            return r.status, json.loads(r.read().decode() or "{}")
    except urllib.error.HTTPError as e:
        return e.code, json.loads(e.read().decode() or "{}")


def check(name, ok, details):
    results.append(ok)
    print(f"[{'PASS' if ok else 'FAIL'}] {name} - {details}")


def main():
    forged = {"X-Simulated-Time-Ms": "0", "X-Effective-Time-Ms": "0", "X-Bypass-Start-Check": "1"}

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

    # Issued instructor tokens work until logout.
    code, inst = call("POST", "instructor/login", {"recoveryId": "lab", "recoveryKey": "lab@123"})
    auth = {"Authorization": f"Bearer {inst.get('token')}"}
    code, _ = call("GET", "package/list", headers=auth)
    check("Issued instructor token accepted", code == 200, f"HTTP {code}")
    call("POST", "instructor/logout", headers=auth)
    code, _ = call("GET", "package/list", headers=auth)
    check("Instructor token rejected after logout", code == 401, f"HTTP {code}")

    # Staff routes refuse anything the gateway forwarded.
    code, body = call("GET", "monitoring/sessions", headers={"X-Gateway-Origin": "gateway"})
    check("Gateway-forwarded staff request refused", code == 403 and body.get("errorCode") == "STAFF_ROUTE_LOCAL_ONLY", f"HTTP {code}")

    # Violations need a student session; a body studentUsn alone is not enough.
    code, _ = call("POST", "security/violation", {"studentUsn": "4MH21CS003", "violationType": "TAB_SWITCH", "label": "Tab"})
    check("Violation without session rejected", code == 401, f"HTTP {code}")

    passed = sum(results)
    print(f"\nLOCKDOWN RESULTS: {passed} PASSED / {len(results) - passed} FAILED")
    sys.exit(0 if passed == len(results) else 1)


if __name__ == "__main__":
    main()
