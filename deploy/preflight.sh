#!/usr/bin/env bash
# Checks everything an exam sitting depends on. One line per check; every failure says what is wrong and how to fix it.
# Exit code 0 = safe to start. Run it alone any time:  ./deploy/preflight.sh
# start-exam.sh runs it first and refuses to start when it fails.
DEPLOY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DEPLOY_DIR/env.sh"

FAILURES=0
ok()   { printf '  [ OK ] %s\n' "$1"; }
warn() { printf '  [WARN] %s\n' "$1"; }
fail() { FAILURES=$((FAILURES + 1)); printf '  [FAIL] %s\n         Fix: %s\n' "$1" "$2"; }

echo "CampusExam preflight"

# --- .env ---------------------------------------------------------------------------------------------------------------
if [ ! -f "$REPO_ROOT/.env" ]; then
    fail ".env does not exist." "Run ./deploy/setup.sh; it creates .env from .env.example."
    printf '\nPreflight FAILED. Nothing else can be checked without .env.\n'
    exit 1
fi
load_exam_env

missing=""
for k in JWT_SECRET LAB_INSTRUCTOR_USERNAME LAB_INSTRUCTOR_PASSWORD_HASH DB_URL DB_USER DB_PASSWORD DB_NAME; do
    if [ -z "${!k}" ]; then missing="$missing $k"; fi
done
if [ -n "$missing" ]; then
    fail ".env has no value for:$missing." "Run ./deploy/setup.sh (it fills JWT_SECRET and the instructor login), or set them in .env."
else
    ok ".env has every required value."
fi

if [ -n "$JWT_SECRET" ]; then
    if [ "${#JWT_SECRET}" -lt 32 ]; then
        fail "JWT_SECRET is only ${#JWT_SECRET} characters; at least 32 are required." "Delete the JWT_SECRET line in .env and run ./deploy/setup.sh to generate a strong one."
    else
        ok "JWT_SECRET is set and long enough."
    fi
fi

if [ -n "$LAB_INSTRUCTOR_PASSWORD_HASH" ] && ! [[ "$LAB_INSTRUCTOR_PASSWORD_HASH" =~ ^[0-9a-fA-F]{32}:[0-9a-fA-F]{64}$ ]]; then
    fail "LAB_INSTRUCTOR_PASSWORD_HASH is not in the expected <salt>:<hash> form, so instructor login would be disabled." "Delete both LAB_INSTRUCTOR_* lines in .env and run ./deploy/setup.sh to create a new login."
fi

# --- switches that must be off ------------------------------------------------------------------------------------------
for flag in LAB_TEST_MODE LAB_STAFF_ALLOW_REMOTE ALLOW_SAMPLE_EXAM; do
    if [ "$(printf '%s' "${!flag}" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')" = "true" ]; then
        fail "$flag is true." "Set $flag=false in .env."
    else
        ok "$flag is off."
    fi
done

# --- ports and bind addresses -------------------------------------------------------------------------------------------
ports_ok=1
for name in PORT LAB_PORT GATEWAY_PORT; do
    value="${!name}"
    if ! [[ "$value" =~ ^[0-9]{1,5}$ ]] || [ "$value" -lt 1 ] || [ "$value" -gt 65535 ]; then
        fail "$name is '$value', not a port number." "Set $name in .env to a number from 1 to 65535."
        ports_ok=0
    fi
done
if is_loopback "$BIND"; then ok "The central backend is set to listen on $BIND only."
else fail "BIND=$BIND: the central backend would listen beyond this PC." "Set BIND=127.0.0.1 in .env. Students reach the exam through Tailscale, never directly."; fi
if is_loopback "$LAB_BIND"; then ok "The lab server is set to listen on $LAB_BIND only."
else fail "LAB_BIND=$LAB_BIND: the lab server would listen beyond this PC." "Set LAB_BIND=127.0.0.1 in .env. Students reach the exam through Tailscale, never directly."; fi

if ! command -v lsof >/dev/null 2>&1; then
    fail "lsof is not installed, so open ports cannot be checked." "Install it (for example: sudo apt install lsof)."
elif [ "$ports_ok" = 1 ]; then
    MANAGED="$PORT $LAB_PORT $GATEWAY_PORT 3000 3001"
    clean=1
    # 8080 is the Node backend (backend/server.js). start-exam does not start it; if it is running it must not face the network.
    while read -r port addr pid; do
        [ -n "$port" ] || continue
        if ! is_loopback "$addr"; then
            fail "Port $port (process id $pid) is listening on $addr, not on 127.0.0.1 only." "Stop that process (./deploy/stop-exam.sh, or kill $pid). Every exam service must bind 127.0.0.1."
            clean=0
        elif [[ " $MANAGED " == *" $port "* ]]; then
            fail "Port $port is already in use (process id $pid)." "Run ./deploy/stop-exam.sh, or kill $pid."
            clean=0
        fi
    done < <(listeners_on $MANAGED 8080)
    if [ "$clean" = 1 ]; then ok "Ports $MANAGED are free and nothing is exposed on port 8080."; fi
fi

# --- built artefacts -----------------------------------------------------------------------------------------------------
DIST="$REPO_ROOT/student-portal (Final)/student-portal (Final)/student-portal/dist"
if [ ! -f "$DIST/index.html" ]; then
    fail "The student portal has not been built (dist/index.html is missing)." "Run ./deploy/setup.sh."
else
    maps="$(find "$DIST" -name '*.map' -type f | wc -l | tr -d ' ')"
    if [ "$maps" -gt 0 ]; then
        fail "The student portal build contains $maps .map file(s), which expose its source code." "Delete them, or rebuild with ./deploy/setup.sh."
    else
        ok "The student portal is built and has no .map files."
    fi
fi
for cls in CampusExam LabServer; do
    if [ ! -f "$REPO_ROOT/CampusExam/build_dev/$cls.class" ]; then fail "$cls has not been compiled." "Run ./deploy/setup.sh."; fi
done

# --- PostgreSQL ----------------------------------------------------------------------------------------------------------
if [[ "$DB_URL" =~ ^jdbc:postgresql://([^:/]+)(:([0-9]+))?/ ]]; then
    db_host="${BASH_REMATCH[1]}"; db_port="${BASH_REMATCH[3]:-5432}"
    if tcp_open "$db_host" "$db_port"; then ok "PostgreSQL answers on $db_host:$db_port."
    else fail "PostgreSQL does not answer on $db_host:$db_port." "Start the PostgreSQL service (for example: sudo systemctl start postgresql), then run this again."; fi
else
    fail "DB_URL in .env is missing or not a jdbc:postgresql:// URL." "Set DB_URL, for example jdbc:postgresql://127.0.0.1:5432/campusexam_test."
fi

# --- storage -------------------------------------------------------------------------------------------------------------
folder_writable() { mkdir -p "$1" 2>/dev/null && touch "$1/.preflight_probe" 2>/dev/null && rm -f "$1/.preflight_probe"; }

LAB_STORAGE="$REPO_ROOT/CampusExam/lab_storage"
if folder_writable "$LAB_STORAGE"; then
    ok "lab_storage is writable, $(df -Pk "$LAB_STORAGE" | awk 'NR==2 { printf "%.1f", $4 / 1048576 }') GB free on that disk."
else
    fail "CampusExam/lab_storage is not writable; answers could not be saved." "Check the folder permissions and that the disk is not full or read-only."
fi
case "$BACKUP_DIR" in /*) BACKUP_PATH="$BACKUP_DIR" ;; *) BACKUP_PATH="$REPO_ROOT/$BACKUP_DIR" ;; esac
if folder_writable "$BACKUP_PATH"; then ok "Backup folder $BACKUP_PATH is writable."
else fail "Backup folder $BACKUP_PATH is not writable." "Set BACKUP_DIR in .env to a folder you can write to (ideally on another disk)."; fi

# --- host must not sleep -------------------------------------------------------------------------------------------------
warn "Cannot check sleep settings on this OS. Make sure this machine never sleeps or hibernates during the sitting."

# --- Tailscale -----------------------------------------------------------------------------------------------------------
if ! command -v tailscale >/dev/null 2>&1; then
    fail "Tailscale is not installed." "Install it from https://tailscale.com/download and sign in."
else
    state="$(tailscale_query 'j.BackendState')"
    if [ -z "$state" ]; then
        fail "Tailscale did not return a status." "Start it and sign in (sudo tailscale up), then run this again."
    elif [ "$state" != "Running" ]; then
        fail "Tailscale is not connected (state: $state)." "Run: sudo tailscale up"
    else
        ok "Tailscale is signed in and running."
        if [ "$(tailscale_query '!!(j.CurrentTailnet && j.CurrentTailnet.MagicDNSEnabled)')" = "true" ]; then ok "MagicDNS is on."
        else fail "MagicDNS is off for this tailnet." "Tailscale admin console > DNS > turn on MagicDNS."; fi
        if [ "$(tailscale_query '!!(j.Self && j.Self.CapMap && ("https" in j.Self.CapMap))')" = "true" ]; then ok "HTTPS certificates are on."
        else fail "HTTPS certificates are not enabled for this tailnet." "Tailscale admin console > DNS > Enable HTTPS."; fi
        if [ "$(tailscale_query '!!(j.Self && j.Self.CapMap && ("funnel" in j.Self.CapMap))')" = "true" ]; then ok "This machine is allowed to use Funnel."
        else fail "This machine is not allowed to use Funnel." "Add the funnel node attribute in the tailnet policy file (Tailscale admin console > Access controls). See DEPLOYMENT.md."; fi
    fi
fi

echo
if [ "$FAILURES" -gt 0 ]; then
    echo "Preflight FAILED: $FAILURES problem(s). Do not start the exam until they are fixed."
    exit 1
fi
echo "Preflight passed."
exit 0
