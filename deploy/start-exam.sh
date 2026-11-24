#!/usr/bin/env bash
# Starts every exam service bound to 127.0.0.1 and PRINTS the Tailscale command that publishes the gateway.
# It never runs that command: you run it yourself when you are ready to let students in.
#   ./deploy/start-exam.sh
DEPLOY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DEPLOY_DIR/env.sh"

if [ ! -f "$REPO_ROOT/.env" ]; then
    echo "Not starting: .env does not exist. Run ./deploy/setup.sh first."
    exit 1
fi
# Every .env value is exported into this shell; each service started below inherits all of them.
load_exam_env

# Without these two there is no instructor login, so a crashed student PC could not be recovered.
for k in LAB_INSTRUCTOR_USERNAME LAB_INSTRUCTOR_PASSWORD_HASH; do
    if [ -z "${!k}" ]; then
        echo "Not starting: $k is missing from .env."
        echo "  Fix: run ./deploy/setup.sh; it creates the instructor login and shows its password once."
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
start_service gateway "$REPO_ROOT" -- node "$REPO_ROOT/deploy/gateway/server.js"
start_service coe-portal "$REPO_ROOT/coe-portal (7)" PORT=3001 -- npm run dev -- --port 3001 --host 127.0.0.1
start_service admin-portal "$REPO_ROOT/admin-portal (7)" PORT=3000 -- npm run dev -- --port 3000 --host 127.0.0.1

echo
echo "Waiting for the services to answer..."
wait_until 90 tcp_open 127.0.0.1 "$PORT" \
    || stop_with_message "the central backend did not open port $PORT within 90 seconds (is PostgreSQL up and DB_* in .env correct?)."
wait_until 90 gateway_healthy \
    || stop_with_message "http://127.0.0.1:$GATEWAY_PORT/api/health did not answer within 90 seconds, so the gateway or the lab server is not working."
echo "  [ OK ] The gateway reaches the lab server (/api/health)."
wait_until 120 tcp_open 127.0.0.1 3001 \
    || echo "  [WARN] The COE portal is not up yet (the first start compiles it). Exam delivery is unaffected; see coe-portal.err.log."

# Proof, not configuration: ask the OS what is actually listening and where.
while read -r port addr pid; do
    [ -n "$port" ] || continue
    if ! is_loopback "$addr"; then
        stop_with_message "port $port is listening on $addr, beyond this machine. Everything has been stopped."
    fi
done < <(listeners_on "$PORT" "$LAB_PORT" "$GATEWAY_PORT" 3000 3001)
echo "  [ OK ] Every service listens on 127.0.0.1 only."

PUBLIC_NAME="$(tailscale_query 'j.Self.DNSName' | sed 's/\.$//')"
[ -n "$PUBLIC_NAME" ] || PUBLIC_NAME="<this machine's Tailscale name>"

echo
echo "===================================================================="
echo "  EXAM SERVICES ARE RUNNING (reachable from this machine only)"
echo "===================================================================="
echo "  Students cannot get in yet. When you are ready, run this ONE command yourself:"
echo
echo "      tailscale funnel --bg $GATEWAY_PORT"
echo
echo "  Students then open:   https://$PUBLIC_NAME/"
echo "  Staff, on this machine:  COE portal http://127.0.0.1:3001    Admin portal http://127.0.0.1:3000"
echo "  That address is public. Access control is the student login, never the secrecy of the URL."
echo "  When the sitting ends:  ./deploy/stop-exam.sh"
echo "===================================================================="
