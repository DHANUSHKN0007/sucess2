#!/usr/bin/env bash
# Ends the sitting: stops every exam service and confirms nothing is still listening.
# It does NOT touch Tailscale Funnel. The funnels are meant to stay configured across restarts on a permanent host; while the
# services are down they simply answer with an error.
#   ./deploy/stop-exam.sh
DEPLOY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DEPLOY_DIR/env.sh"
if [ -f "$REPO_ROOT/.env" ]; then load_exam_env; else PORT=8081; LAB_PORT=8082; GATEWAY_PORT=3002; ADMIN_GATEWAY_PORT=3003; COE_GATEWAY_PORT=3004; BACKUP_DIR=backups; fi
PORTS="$PORT $LAB_PORT $GATEWAY_PORT $ADMIN_GATEWAY_PORT $COE_GATEWAY_PORT 3000 3001"

echo "Stopping exam services..."
PID_FILE="$REPO_ROOT/CampusExam/lab_storage/exam_pids"
if [ -f "$PID_FILE" ]; then
    while read -r p; do [ -n "$p" ] && kill_tree "$p"; done < "$PID_FILE"
    rm -f "$PID_FILE"
fi
# Anything still holding one of the exam ports (a child that outlived its parent, or a service started by hand).
if command -v lsof >/dev/null 2>&1; then
    while read -r port addr pid; do
        [ -n "$pid" ] || continue
        echo "  Stopping process $pid listening on port $port"
        kill_tree "$pid"
    done < <(listeners_on $PORTS)
    sleep 1
    left="$(listeners_on $PORTS)"
    if [ -n "$left" ]; then
        echo "Still listening: $(echo "$left" | awk '{ print "port " $1 " (process id " $3 ")" }' | paste -sd, -)"
        echo "  Fix: kill those processes, then run this again."
        exit 1
    fi
    echo "[ OK ] Nothing is listening on the exam ports. Tailscale Funnel was left as it was."
else
    echo "[WARN] lsof is not installed, so open ports could not be confirmed closed. Check by hand."
fi

case "$BACKUP_DIR" in /*) BACKUP_PATH="$BACKUP_DIR" ;; *) BACKUP_PATH="$REPO_ROOT/$BACKUP_DIR" ;; esac
echo
echo "Before you close up:"
echo "  1. Finalise and export the results from the COE portal. If you have not yet, run ./deploy/start-exam.sh again"
echo "     (do NOT run its tailscale command) and export them; the lab server and COE portal were just stopped."
echo "  2. Copy the answers and results off this machine. For example:"
echo "       mkdir -p '$BACKUP_PATH' && cp -R '$REPO_ROOT/CampusExam/lab_storage' '$BACKUP_PATH/lab_storage_$(date +%Y%m%d-%H%M)'"
echo "  Keep lab_storage until the results are approved; it is the only copy of the students' answers."
