#!/usr/bin/env bash
# Sets a staff password as a PBKDF2 hash in .env. The password itself is never stored.
# Usage: ./deploy/set-staff-password.sh [-h|--help] [username [password]]
#   No arguments: sets admin and coe, each with a generated password shown once.
#   username: any staff account (hod.cse -> STAFF_PASSWORD_HASH_HOD_CSE); password is optional and generated when left out.
# Writes STAFF_PASSWORD_HASH_<USER> (admin -> STAFF_PASSWORD_HASH_ADMIN). The central backend reads it at start,
# so restart the exam services after a change.
# Format: <saltHex>:<hashHex>, PBKDF2-HMAC-SHA256, 600000 iterations, 32-byte hash (same as make-instructor-credential).
# Needs python3 (or python).
set -e
case "$1" in -h|--help|-\?) sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;; esac
. "$(dirname "${BASH_SOURCE[0]}")/env.sh"

[ -f "$REPO_ROOT/.env" ] || { echo "No .env yet. Run ./deploy/setup.sh first." >&2; exit 1; }
PY=""
for candidate in python3 python; do
    if "$candidate" -c 'import hashlib' >/dev/null 2>&1; then PY=$candidate; break; fi
done
[ -n "$PY" ] || { echo "python3 is required" >&2; exit 1; }

set_one() {
    local name key line
    name="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')"
    [ -n "$name" ] || return 0
    key="STAFF_PASSWORD_HASH_$(printf '%s' "$name" | tr '[:lower:]' '[:upper:]' | sed 's/[^A-Z0-9]/_/g')"
    # Passed through the environment rather than argv so it does not show in the process list.
    line="$(STAFF_PASSWORD="$2" STAFF_USER="$name" "$PY" -c '
import hashlib, os, secrets, sys
pw = os.environ.get("STAFF_PASSWORD", "")
generated = not pw
if generated:
    pw = secrets.token_urlsafe(18)
elif not 8 <= len(pw) <= 128:
    print("The password must have 8 to 128 characters.", file=sys.stderr); sys.exit(2)
salt = os.urandom(16)
digest = hashlib.pbkdf2_hmac("sha256", pw.encode("utf-8"), salt, 600000, 32)
if generated:
    print("  Generated password for \x27" + os.environ["STAFF_USER"] + "\x27 (shown once - store it now): " + pw, file=sys.stderr)
print(salt.hex() + ":" + digest.hex())
')" || exit 1
    set_env_value "$key" "$line"
    echo "Set $key in .env for '$name'."
}

if [ $# -eq 0 ]; then
    set_one admin ""
    set_one coe ""
else
    set_one "$1" "${2:-}"
fi
echo "Restart the exam services (./deploy/stop-exam.sh, then ./deploy/start-exam.sh) for the change to take effect."
