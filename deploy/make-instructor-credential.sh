#!/bin/sh
# Prints the LAB_INSTRUCTOR_PASSWORD_HASH line for the lab server's instructor login.
# Usage: ./make-instructor-credential.sh [password]
# With no password, generates a strong one and shows it once (on stderr, so stdout can be appended to .env).
# Format: <saltHex>:<hashHex>, PBKDF2-HMAC-SHA256, 600000 iterations, 32-byte hash (matches LabServer.derive).
# Needs python3 (or python).
set -e
PY=""
for candidate in python3 python; do
    if "$candidate" -c 'import hashlib' >/dev/null 2>&1; then PY=$candidate; break; fi
done
[ -n "$PY" ] || { echo "python3 is required" >&2; exit 1; }
# Passed through the environment rather than argv so it does not show in the process list.
INSTRUCTOR_PASSWORD="$1" "$PY" -c '
import hashlib, os, secrets, sys
pw = os.environ.get("INSTRUCTOR_PASSWORD", "")
generated = not pw
if generated:
    pw = secrets.token_urlsafe(18)
salt = os.urandom(16)
digest = hashlib.pbkdf2_hmac("sha256", pw.encode("utf-8"), salt, 600000, 32)
if generated:
    print("Generated instructor password (shown once - store it now): " + pw, file=sys.stderr)
print("LAB_INSTRUCTOR_PASSWORD_HASH=" + salt.hex() + ":" + digest.hex())
'
