#!/usr/bin/env bash
# Shared helpers for the deploy scripts. Source it:  . "$(dirname "${BASH_SOURCE[0]}")/env.sh"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Exports every KEY=VALUE line of .env. Lines are read, not sourced, so a value containing $ or ; stays literal.
# A switch the file leaves out gets a safe default, so a stray value in the deployer's shell never reaches a service.
load_exam_env() {
    local line key val pair
    for key in PORT BIND LAB_PORT LAB_BIND GATEWAY_PORT ADMIN_GATEWAY_PORT COE_GATEWAY_PORT LAB_TEST_MODE LAB_STAFF_ALLOW_REMOTE ALLOW_SAMPLE_EXAM BACKUP_DIR; do
        unset "$key"
    done
    while IFS= read -r line || [ -n "$line" ]; do
        line="${line%$'\r'}"
        case "$line" in ''|'#'*) continue ;; esac
        case "$line" in *=*) ;; *) continue ;; esac
        key="$(printf '%s' "${line%%=*}" | tr -d '[:space:]')"
        val="$(printf '%s' "${line#*=}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
        case "$val" in
            \"*\") val="${val#\"}"; val="${val%\"}" ;;
            \'*\') val="${val#\'}"; val="${val%\'}" ;;
        esac
        if [ -n "$key" ]; then export "$key=$val"; fi
    done < "$REPO_ROOT/.env"
    for pair in PORT=8081 BIND=127.0.0.1 LAB_PORT=8082 LAB_BIND=127.0.0.1 GATEWAY_PORT=3002 \
                ADMIN_GATEWAY_PORT=3003 COE_GATEWAY_PORT=3004 \
                LAB_TEST_MODE=false LAB_STAFF_ALLOW_REMOTE=false ALLOW_SAMPLE_EXAM=false BACKUP_DIR=backups; do
        key="${pair%%=*}"
        if [ -z "${!key}" ]; then export "$key=${pair#*=}"; fi
    done
}

# Replaces the first KEY= line of .env, or appends one. Values go through the environment so awk never interprets them.
set_env_value() {
    local tmp="$REPO_ROOT/.env.tmp.$$"
    KEY="$1" VAL="$2" awk '
        BEGIN { k = ENVIRON["KEY"]; v = ENVIRON["VAL"] }
        index($0, k "=") == 1 && !done { print k "=" v; done = 1; next }
        { print }
        END { if (!done) print k "=" v }' "$REPO_ROOT/.env" > "$tmp" && mv "$tmp" "$REPO_ROOT/.env"
}

is_loopback() {
    case "$1" in localhost|::1|127.*|'[::1]') return 0 ;; *) return 1 ;; esac
}

tcp_open() { (exec 3<>"/dev/tcp/$1/$2") 2>/dev/null; }

# One "port address pid" line per TCP listener on the given ports. An address of * or 0.0.0.0 means every interface.
listeners_on() {
    lsof -nP -iTCP -sTCP:LISTEN -Fpn 2>/dev/null | awk -v ports=" $* " '
        /^p/ { pid = substr($0, 2) }
        /^n/ { n = substr($0, 2); i = match(n, /:[0-9]+$/); addr = substr(n, 1, i - 1); port = substr(n, i + 1)
               if (index(ports, " " port " ")) print port, addr, pid }' | sort -u
}

kill_tree() {
    local p="$1" c
    for c in $(pgrep -P "$p" 2>/dev/null); do kill_tree "$c"; done
    kill "$p" 2>/dev/null || true
}

# Evaluates a JS expression over `tailscale status --json` (the object is j); prints nothing when it cannot be read.
tailscale_query() {
    tailscale status --json 2>/dev/null | node -e '
        let s = ""; process.stdin.on("data", d => s += d).on("end", () => {
            try { const j = JSON.parse(s); const v = new Function("j", "return (" + process.argv[1] + ")")(j); console.log(v === undefined ? "" : v); } catch (e) {}
        });' "$1"
}

# gateway_healthy [port [path]]: with no arguments, the student gateway's /api/health.
gateway_healthy() {
    node -e 'fetch(process.argv[1]).then(r => process.exit(r.ok ? 0 : 1)).catch(() => process.exit(1))' "http://127.0.0.1:${1:-$GATEWAY_PORT}${2:-/api/health}"
}
