#!/usr/bin/env bash
# One-time setup on a new machine. Safe to run again: it never replaces a value already in .env.
#   ./deploy/setup.sh
set -e
DEPLOY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DEPLOY_DIR/env.sh"

step() { printf '\n%s\n' "$1"; }
done_() { printf '  [ OK ] %s\n' "$1"; }

echo "CampusExam setup"

# 1. Prerequisites: say exactly what is missing and where to get it, before changing anything.
step "[1/7] Checking what is installed..."
missing=()
if ! command -v node >/dev/null 2>&1; then missing+=("Node.js 18 or newer (LTS)  ->  https://nodejs.org")
elif [ "$(node -v | sed 's/^v//' | cut -d. -f1)" -lt 18 ]; then missing+=("Node.js 18 or newer (this machine has $(node -v))  ->  https://nodejs.org"); fi
command -v javac >/dev/null 2>&1 || missing+=("A JDK 17 or newer (a JRE cannot compile)  ->  https://adoptium.net  (Temurin)")
command -v psql >/dev/null 2>&1 || missing+=("PostgreSQL 14 or newer (psql)  ->  https://www.postgresql.org/download/")
command -v tailscale >/dev/null 2>&1 || missing+=("Tailscale  ->  https://tailscale.com/download")
command -v lsof >/dev/null 2>&1 || missing+=("lsof (used to check open ports)  ->  your package manager, e.g. sudo apt install lsof")
command -v python3 >/dev/null 2>&1 || command -v python >/dev/null 2>&1 || missing+=("Python 3 (creates the instructor password hash)  ->  https://www.python.org/downloads/")
if [ "${#missing[@]}" -gt 0 ]; then
    echo "  Missing:"
    for m in "${missing[@]}"; do echo "    - $m"; done
    echo "  Install them, open a NEW terminal, and run this again."
    exit 1
fi
done_ "Node.js, JDK, PostgreSQL, Tailscale, lsof and Python are installed."

# 2. .env: created once from the template, never overwritten.
step "[2/7] Preparing .env..."
if [ ! -f "$REPO_ROOT/.env" ]; then
    cp "$REPO_ROOT/.env.example" "$REPO_ROOT/.env"
    done_ "Created .env from .env.example."
else
    done_ ".env already exists; keeping your values."
fi
load_exam_env
if [ -z "$JWT_SECRET" ]; then
    set_env_value JWT_SECRET "$(head -c 48 /dev/urandom | od -An -tx1 | tr -d ' \n')"
    done_ "Generated JWT_SECRET (96 hex characters)."
fi

# The instructor (invigilator) login: its hash goes into .env for both the lab server and the central backend, and the
# password is shown once here because nothing stores it.
load_exam_env
if [ -z "$LAB_INSTRUCTOR_USERNAME" ] || [ -z "$LAB_INSTRUCTOR_PASSWORD_HASH" ]; then
    echo "  Creating the instructor login. The password below is shown ONCE and stored nowhere: write it down now."
    hash_line="$("$DEPLOY_DIR/make-instructor-credential.sh")"
    case "$hash_line" in LAB_INSTRUCTOR_PASSWORD_HASH=*) ;; *) echo "make-instructor-credential.sh did not return a password hash."; exit 1 ;; esac
    set_env_value LAB_INSTRUCTOR_USERNAME invigilator
    set_env_value LAB_INSTRUCTOR_PASSWORD_HASH "${hash_line#LAB_INSTRUCTOR_PASSWORD_HASH=}"
    echo "  Instructor ID: invigilator   (change LAB_INSTRUCTOR_USERNAME in .env if you prefer another name)"
    done_ "Instructor login saved to .env."
else
    done_ "Instructor login is already in .env. To replace it, delete both LAB_INSTRUCTOR_* lines and run setup again."
fi

# 3. Folders the services write into.
step "[3/7] Creating storage folders..."
mkdir -p "$REPO_ROOT/CampusExam/build_dev" "$REPO_ROOT/CampusExam/keys" "$REPO_ROOT/CampusExam/lab_server_keys" \
         "$REPO_ROOT/CampusExam/lab_storage/packages" "$REPO_ROOT/CampusExam/lab_storage/submissions" \
         "$REPO_ROOT/CampusExam/lab_storage/results" "$REPO_ROOT/CampusExam/lab_storage/credentials" \
         "$REPO_ROOT/CampusExam/lab_storage/logs" "$REPO_ROOT/CampusExam/audit_storage/results"
done_ "Folders ready."

# 4. Packages.
step "[4/7] Installing packages (a few minutes the first time)..."
STUDENT_DIR="$REPO_ROOT/student-portal (Final)/student-portal (Final)/student-portal"
for dir in "$REPO_ROOT/admin-portal (7)" "$REPO_ROOT/coe-portal (7)" "$STUDENT_DIR"; do
    if ! (cd "$dir" && npm ci --legacy-peer-deps --no-audit --prefer-offline); then
        echo "  [WARN] npm ci failed in $dir; trying npm install instead."
        (cd "$dir" && npm install --legacy-peer-deps --no-audit) || { echo "npm could not install the packages in '$dir'. Check the internet connection, then run setup again."; exit 1; }
    fi
done
done_ "Packages installed."

# 5. The portal students use, built for production (same-origin, no source maps).
step "[5/7] Building the student portal..."
(cd "$STUDENT_DIR" && npm run build) || { echo "The student portal build failed. Read the error above."; exit 1; }
done_ "Student portal built."

# 6. Java services and their key pairs.
step "[6/7] Compiling the Java services..."
(
    cd "$REPO_ROOT/CampusExam"
    javac -d build_dev -cp lib/postgresql.jar -sourcepath src CampusExam.java LabServer.java
    java -cp "build_dev:lib/postgresql.jar" CampusExam --init-keys
    java -cp build_dev LabServer --init-keys
) || { echo "javac failed. Read the error above; a JDK 17 or newer is required."; exit 1; }
done_ "Compiled, and the RSA key pairs exist."

# 7. Database. The dump contains DROP statements, so this script never loads it; it only checks and tells you what to run.
step "[7/7] Database..."
load_exam_env
if [[ "$DB_URL" =~ ^jdbc:postgresql://([^:/]+)(:([0-9]+))?/ ]]; then
    db_host="${BASH_REMATCH[1]}"; db_port="${BASH_REMATCH[3]:-5432}"
else
    db_host=127.0.0.1; db_port=5432
fi
if PGPASSWORD="$DB_PASSWORD" psql -h "$db_host" -p "$db_port" -U "$DB_USER" -d "$DB_NAME" -tAc 'SELECT count(*) FROM account' >/dev/null 2>&1; then
    done_ "Database $DB_NAME is already initialised."
else
    echo "  Database $DB_NAME is not ready. Create it once, as the PostgreSQL administrator:"
    echo "    sudo -u postgres psql -c \"CREATE ROLE $DB_USER LOGIN SUPERUSER PASSWORD '<DB_PASSWORD from .env>'\""
    echo "    sudo -u postgres createdb -O $DB_USER $DB_NAME"
    echo "    PGPASSWORD='<DB_PASSWORD from .env>' psql -h $db_host -p $db_port -U $DB_USER -d $DB_NAME -f CampusExam/database_dump.sql"
    echo "  (database_dump.sql contains DROP statements: run it only against the empty database above.)"
fi

echo
echo "===================================================================="
echo "  SETUP COMPLETE"
echo "===================================================================="
echo "  Next:  ./deploy/start-exam.sh"
echo "  One-time Tailscale admin-console steps are in DEPLOYMENT.md."
