#!/usr/bin/env bash
# Wipes the exam data between sittings. Keeps .env, the RSA keys and every account.
# Usage: ./deploy/reset-data.sh [-h|--help] [-f|--force]
#   WIPES  CampusExam/lab_storage/{packages,submissions,results,credentials} (packages, sessions, answers, submissions, lock
#          state, recovery history, suspicious events, PC recovery events, result exports, sitting unlock verifiers),
#          CampusExam/audit_storage/results, and the exam, sitting, schedule, package, result and student-response tables in
#          PostgreSQL (deploy/reset-data-db.js lists them).
#   KEEPS  .env, the RSA keys (CampusExam/keys, CampusExam/lab_server_keys), staff and student account rows, rosters,
#          institution data, question banks, the audit log and the service logs.
#   Refuses while any exam service is listening. Prints what it will clear and asks you to type WIPE (--force skips that).
#   Copies lab_storage and the result exports to <BACKUP_DIR>/<timestamp> and checks the copy, then clears the database in
#   one transaction (all or nothing) and finally the files. The database rows are NOT in the backup: run pg_dump first.
DEPLOY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORCE=0
for arg in "$@"; do
    case "$arg" in
        -h|--help|-\?) sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        -f|--force) FORCE=1 ;;
        *) echo "Unknown option: $arg (see --help)" >&2; exit 1 ;;
    esac
done
. "$DEPLOY_DIR/env.sh"

stop_reset() { echo "Not wiping: $1 Nothing was changed."; exit 1; }
tree_files() { if [ -d "$1" ]; then find "$1" -type f 2>/dev/null | wc -l | tr -d ' '; else echo 0; fi; }
tree_kb()    { if [ -d "$1" ]; then du -sk "$1" 2>/dev/null | cut -f1; else echo 0; fi; }

[ -f "$REPO_ROOT/.env" ] || stop_reset ".env does not exist."
load_exam_env

# The lab server keeps the packages where LAB_STORAGE_DIR says; a different value would leave them behind unnoticed.
storage_setting="$(printf '%s' "${LAB_STORAGE_DIR:-}" | tr '\\' '/' | sed 's#/*$##')"
if [ -n "$storage_setting" ] && [ "$storage_setting" != "lab_storage/packages" ]; then
    stop_reset "LAB_STORAGE_DIR is '$storage_setting', not the default lab_storage/packages, so this script cannot tell where the packages are."
fi

busy=""
for p in "$PORT" "$LAB_PORT" "$GATEWAY_PORT" "$ADMIN_GATEWAY_PORT" "$COE_GATEWAY_PORT" 3000 3001; do
    if tcp_open 127.0.0.1 "$p"; then busy="$busy $p"; fi
done
[ -z "$busy" ] || stop_reset "exam services are still listening on port(s):$busy. Run ./deploy/stop-exam.sh first."

command -v node >/dev/null 2>&1 || stop_reset "Node.js was not found, which is needed to reach the database."
HELPER="$DEPLOY_DIR/reset-data-db.js"

# Reading the database first also proves it is reachable: a files-only wipe would leave the two out of step.
count_out="$(node "$HELPER" --count)" || stop_reset "the database could not be read (the message above says why)."
missing="$(printf '%s\n' "$count_out" | awk -F'\t' '$1=="MISSING"{printf "%s%s", sep, $2; sep=", "}')"
table_count="$(printf '%s\n' "$count_out" | awk -F'\t' '$1=="ROWS"{n++} END{print n+0}')"
row_total="$(printf '%s\n' "$count_out" | awk -F'\t' '$1=="ROWS"{n+=$3} END{print n+0}')"

CAMPUS="$REPO_ROOT/CampusExam"
TARGETS=(
    "packages|$CAMPUS/lab_storage/packages"
    "sessions, answers, submissions, lock state, recovery history, suspicious events, PC recovery events|$CAMPUS/lab_storage/submissions"
    "result exports|$CAMPUS/lab_storage/results"
    "sitting unlock verifiers|$CAMPUS/lab_storage/credentials"
    "audit result exports|$CAMPUS/audit_storage/results"
)
declare -a BEFORE
echo
echo "This will permanently delete:"
i=0
for t in "${TARGETS[@]}"; do
    label="${t%%|*}"; dir="${t#*|}"
    BEFORE[$i]="$(tree_files "$dir")"
    printf '  %5s file(s) %8s MB  %s  (%s)\n' "${BEFORE[$i]}" "$(awk -v kb="$(tree_kb "$dir")" 'BEGIN{printf "%.2f", kb/1024}')" "$label" "${dir#"$REPO_ROOT"/}"
    i=$((i + 1))
done
echo "  $row_total database row(s) in $table_count table(s):"
printf '%s\n' "$count_out" | awk -F'\t' '$1=="ROWS" && $3>0 {printf "  %10s  %s\n", $3, $2}'
[ "$row_total" -gt 0 ] || echo "            (every one of those tables is already empty)"
[ -z "$missing" ] || echo "  Not in this database, skipped: $missing"
echo "It keeps: .env, the RSA keys, staff and student accounts, rosters, institution data, question banks, the audit log and the service logs."
echo "The database rows are not in the backup; run pg_dump first if you may want them back."

if [ "$FORCE" = 0 ]; then
    [ -t 0 ] || stop_reset "there is no terminal to ask for confirmation. Run it in a terminal, or add --force."
    echo
    read -r -p "Type WIPE to delete all of the above (anything else cancels): " typed
    [ "$typed" = "WIPE" ] || stop_reset "confirmation was not given."
fi

# 1. Back up. Nothing is deleted until the copy has been checked.
stamp="$(date +%Y%m%d-%H%M%S)"
case "$BACKUP_DIR" in /*) backup_root="$BACKUP_DIR" ;; *) backup_root="$REPO_ROOT/$BACKUP_DIR" ;; esac
backup_dir="$backup_root/$stamp"
for pair in "lab_storage|lab_storage" "audit_storage/results|audit_storage/results"; do
    from="$CAMPUS/${pair%%|*}"; to="$backup_dir/${pair#*|}"
    [ -d "$from" ] || continue
    mkdir -p "$(dirname "$to")" && cp -R "$from" "$to" || stop_reset "could not copy $from to $to."
    [ "$(tree_files "$from")" = "$(tree_files "$to")" ] && [ "$(tree_kb "$from")" = "$(tree_kb "$to")" ] \
        || stop_reset "the backup of $from does not match the original (copied to $backup_dir)."
done
echo
echo "Backed up lab_storage and the result exports to $backup_dir"

# 2. The database goes first: it is all-or-nothing, so a failure leaves the files untouched.
if ! wipe_out="$(node "$HELPER" --wipe)"; then
    echo "The database wipe failed (message above) and was rolled back. The files were not touched; the backup is at $backup_dir."
    exit 1
fi

# 3. Files. The folders stay; only what is inside goes. exam_pids, logs, .env and the keys are never in these folders.
failed=0
for t in "${TARGETS[@]}"; do
    dir="${t#*|}"
    [ -d "$dir" ] || continue
    find "$dir" -mindepth 1 -delete 2>/dev/null || { echo "Could not clear $dir"; failed=1; }
done

echo
echo "Cleared:"
i=0
for t in "${TARGETS[@]}"; do
    dir="${t#*|}"; left="$(tree_files "$dir")"
    printf '  %5s file(s) removed from %s%s\n' "$((BEFORE[$i] - left))" "${dir#"$REPO_ROOT"/}" "$([ "$left" -gt 0 ] && echo " ($left left)")"
    i=$((i + 1))
done
printf '%s\n' "$wipe_out" | awk -F'\t' '$1=="CLEARED" && $3>0 {printf "  %5s row(s) removed from table %s\n", $3, $2}'
echo "Kept untouched: .env, CampusExam/keys, CampusExam/lab_server_keys, account rows, logs."
echo "Backup: $backup_dir"
[ "$failed" = 0 ] || exit 1
