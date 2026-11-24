#!/usr/bin/env bash
# Starts every exam service bound to 127.0.0.1 and PRINTS the three Tailscale commands that publish the student, admin and COE gateways.
# It never runs them: you run them yourself when you are ready to let people in.
#   ./deploy/start-exam.sh
DEPLOY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DEPLOY_DIR/env.sh"

if [ ! -f "$REPO_ROOT/.env" ]; then
    echo "Not starting: .env does not exist. Run ./deploy/setup.sh first."
    exit 1
fi
# Every .env value is exported into this shell; each service started below inherits all of them.
load_exam_env

# Without the first two there is no instructor login, so a crashed student PC could not be recovered. Without the last two
# the admin and COE accounts have no password at all.
for k in LAB_INSTRUCTOR_USERNAME LAB_INSTRUCTOR_PASSWORD_HASH STAFF_PASSWORD_HASH_ADMIN STAFF_PASSWORD_HASH_COE; do
    if [ -z "${!k}" ]; then
        echo "Not starting: $k is missing from .env."
        case "$k" in
            STAFF_PASSWORD_HASH_*) echo "  Fix: run ./deploy/set-staff-password.sh; it sets the admin and COE passwords and shows them once." ;;
            *) echo "  Fix: run ./deploy/setup.sh; it creates the instructor login and shows its password once." ;;
        esac
        exit 1
    fi
done

if ! "$DEPLOY_DIR/preflight.sh"; then
    echo "Not starting: fix the problems above, then run this again."
    exit 1
fi

CAMPUS_DIR="$REPO_ROOT/CampusExam"
LOG_DIR="$CAMPUS_DIR/lab_storage/logs"
PID_FILE="$CAMPUS_DIR/lab_storage/exam_pids"
mkdir -p "$LOG_DIR"
: > "$PID_FILE"

# start_service NAME DIR [VAR=value ...] -- COMMAND...
# The VAR=value pairs are the per-service values (port, bind address) that differ from the shared .env, because one
# .env key such as PORT cannot be right for the central backend, the lab server and the portals at once.
start_service() {
    local name="$1" dir="$2"; shift 2
    local extra=()
    while [ "$1" != "--" ]; do extra+=("$1"); shift; done
    shift
    ( cd "$dir" && env "${extra[@]}" nohup "$@" > "$LOG_DIR/$name.out.log" 2> "$LOG_DIR/$name.err.log" & echo $! >> "$PID_FILE" )
    echo "  [ OK ] $name started"
}

stop_started() {
    local p
    while read -r p; do [ -n "$p" ] && kill_tree "$p"; done < "$PID_FILE"
}

stop_with_message() {
    stop_started
    echo "Not running: $1"
    echo "  Service logs are in $LOG_DIR"
    exit 1
}

wait_until() {
    local seconds="$1"; shift
    while [ "$seconds" -gt 0 ]; do
        if "$@" > /dev/null 2>&1; then return 0; fi
        sleep 1
        seconds=$((seconds - 1))
    done
    return 1
}

echo
echo "Starting services (all on 127.0.0.1)..."
start_service central "$CAMPUS_DIR" PORT="$PORT" BIND="$BIND" -- java -cp "build_dev:lib/postgresql.jar" CampusExam
start_service lab-server "$CAMPUS_DIR" PORT="$LAB_PORT" BIND="$LAB_BIND" -- java -cp build_dev LabServer
# One gateway per portal, each given every value it reads.
start_service gateway "$REPO_ROOT" GATEWAY_PROFILE=student GATEWAY_PORT="$GATEWAY_PORT" LAB_PORT="$LAB_PORT" -- node "$REPO_ROOT/deploy/gateway/server.js"
start_service gateway-admin "$REPO_ROOT" GATEWAY_PROFILE=admin GATEWAY_PORT="$ADMIN_GATEWAY_PORT" CENTRAL_PORT="$PORT" -- node "$REPO_ROOT/deploy/gateway/server.js"
start_service gateway-coe "$REPO_ROOT" GATEWAY_PROFILE=coe GATEWAY_PORT="$COE_GATEWAY_PORT" CENTRAL_PORT="$PORT" -- node "$REPO_ROOT/deploy/gateway/server.js"
start_service coe-portal "$REPO_ROOT/coe-portal (7)" PORT=3001 -- npm run dev -- --port 3001 --host 127.0.0.1
start_service admin-portal "$REPO_ROOT/admin-portal (7)" PORT=3000 -- npm run dev -- --port 3000 --host 127.0.0.1

echo
echo "Waiting for the services to answer..."
wait_until 90 tcp_open 127.0.0.1 "$PORT" \
    || stop_with_message "the central backend did not open port $PORT within 90 seconds (is PostgreSQL up and DB_* in .env correct?)."
wait_until 90 gateway_healthy \
    || stop_with_message "http://127.0.0.1:$GATEWAY_PORT/api/health did not answer within 90 seconds, so the gateway or the lab server is not working."
echo "  [ OK ] The gateway reaches the lab server (/api/health)."
for g in "admin:$ADMIN_GATEWAY_PORT" "COE:$COE_GATEWAY_PORT"; do
    wait_until 60 gateway_healthy "${g#*:}" /api/v1/health \
        || stop_with_message "http://127.0.0.1:${g#*:}/api/v1/health did not answer within 60 seconds, so the ${g%%:*} gateway or the central backend is not working."
    echo "  [ OK ] The ${g%%:*} gateway reaches the central backend (/api/v1/health)."
done
wait_until 120 tcp_open 127.0.0.1 3001 \
    || echo "  [WARN] The COE portal is not up yet (the first start compiles it). Exam delivery is unaffected; see coe-portal.err.log."

# Proof, not configuration: ask the OS what is actually listening and where.
while read -r port addr pid; do
    [ -n "$port" ] || continue
    if ! is_loopback "$addr"; then
        stop_with_message "port $port is listening on $addr, beyond this machine. Everything has been stopped."
    fi
done < <(listeners_on "$PORT" "$LAB_PORT" "$GATEWAY_PORT" "$ADMIN_GATEWAY_PORT" "$COE_GATEWAY_PORT" 3000 3001)
echo "  [ OK ] Every service listens on 127.0.0.1 only."

PUBLIC_NAME="$(tailscale_query 'j.Self.DNSName' | sed 's/\.$//')"
[ -n "$PUBLIC_NAME" ] || PUBLIC_NAME="<this machine's Tailscale name>"

echo
echo "===================================================================="
echo "  EXAM SERVICES ARE RUNNING (reachable from this machine only)"
echo "===================================================================="
echo "  Nothing is public yet. These commands are never run for you. When you are ready, run all three yourself."
echo "  Funnel keeps them across restarts, so on a permanent host this is needed once, not per exam:"
echo
echo "      tailscale funnel --bg $GATEWAY_PORT"
echo "      tailscale funnel --bg --https=8443 $ADMIN_GATEWAY_PORT"
echo "      tailscale funnel --bg --https=10000 $COE_GATEWAY_PORT"
echo
echo "  Students open:   https://$PUBLIC_NAME/"
echo "  Admin portal:    https://$PUBLIC_NAME:8443/"
echo "  COE portal:      https://$PUBLIC_NAME:10000/"
echo "  Staff, on this machine, with every feature (document converter, lab-server screens):"
echo "                   COE portal http://127.0.0.1:3001    Admin portal http://127.0.0.1:3000"
echo "  Those addresses are public and appear in certificate transparency logs: discoverable, not secret."
echo "  Access control is the logins, never the secrecy of the URL."
echo "  When the sitting ends:  ./deploy/stop-exam.sh   (it leaves Funnel as it is)"
echo "===================================================================="
