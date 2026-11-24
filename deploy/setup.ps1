# One-time setup on a new machine. Safe to run again: it never replaces a value already in .env, and the database step
# only ever creates what is missing.
#   .\deploy\setup.ps1              asks before touching the database
#   .\deploy\setup.ps1 -Yes         no questions
#   .\deploy\setup.ps1 -SkipDatabase
[CmdletBinding()]
param([switch]$Yes, [switch]$SkipDatabase)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\env.ps1"

function Write-Step([string]$Text) { Write-Host "`n$Text" -ForegroundColor Yellow }
function Write-Done([string]$Text) { Write-Host "  [ OK ] $Text" -ForegroundColor Green }

function Find-Psql {
    $c = Get-Command psql -ErrorAction SilentlyContinue
    if ($c) { return ($c | Select-Object -First 1).Source }
    $f = Get-ChildItem 'C:\Program Files\PostgreSQL\*\bin\psql.exe' -ErrorAction SilentlyContinue | Sort-Object FullName | Select-Object -Last 1
    if ($f) { return $f.FullName }
    return $null
}

function Invoke-NpmInstall([string]$Dir) {
    Push-Location -LiteralPath $Dir
    try {
        npm.cmd ci --legacy-peer-deps --no-audit --prefer-offline
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  [WARN] npm ci failed in $Dir; trying npm install instead." -ForegroundColor DarkYellow
            npm.cmd install --legacy-peer-deps --no-audit
            if ($LASTEXITCODE -ne 0) { throw "npm could not install the packages in '$Dir'. Check the internet connection, then run setup again." }
        }
    } finally {
        Pop-Location
    }
}

Write-Host 'CampusExam setup' -ForegroundColor Cyan

# 1. Prerequisites: say exactly what is missing and where to get it, before changing anything.
Write-Step '[1/7] Checking what is installed...'
$missing = @()
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    $missing += 'Node.js 18 or newer (LTS)  ->  https://nodejs.org'
} elseif ([int]((node -v).TrimStart('v').Split('.')[0]) -lt 18) {
    $missing += "Node.js 18 or newer (this PC has $(node -v))  ->  https://nodejs.org"
}
if (-not (Get-Command javac -ErrorAction SilentlyContinue)) { $missing += 'A JDK 17 or newer (a JRE cannot compile)  ->  https://adoptium.net  (Temurin)' }
if (-not (Find-Psql)) { $missing += 'PostgreSQL 14 or newer  ->  https://www.postgresql.org/download/windows/' }
if (-not (Get-TailscaleExe)) { $missing += 'Tailscale  ->  https://tailscale.com/download' }
if ($missing.Count -gt 0) {
    Write-Host '  Missing:' -ForegroundColor Red
    $missing | ForEach-Object { Write-Host "    - $_" -ForegroundColor Red }
    Write-Host '  Install them, open a NEW PowerShell window, and run this again.' -ForegroundColor Yellow
    exit 1
}
Write-Done 'Node.js, JDK, PostgreSQL and Tailscale are installed.'

# 2. .env: created once from the template, never overwritten.
Write-Step '[2/7] Preparing .env...'
$envPath = Join-Path $RepoRoot '.env'
if (-not (Test-Path -LiteralPath $envPath)) {
    Copy-Item -LiteralPath (Join-Path $RepoRoot '.env.example') -Destination $envPath
    Write-Done 'Created .env from .env.example.'
} else {
    Write-Done '.env already exists; keeping your values.'
}
$cfg = Read-DotEnv $envPath
if ([string]::IsNullOrWhiteSpace($cfg['JWT_SECRET'])) {
    $bytes = New-Object byte[] 48
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $rng.GetBytes($bytes)
    Set-DotEnvValue $envPath 'JWT_SECRET' (-join ($bytes | ForEach-Object { $_.ToString('x2') }))
    Write-Done 'Generated JWT_SECRET (96 hex characters).'
}

# The instructor (invigilator) login: its hash goes into .env for both the lab server and the central backend, and the
# password is shown once here because nothing stores it.
$cfg = Read-DotEnv $envPath
if ([string]::IsNullOrWhiteSpace($cfg['LAB_INSTRUCTOR_USERNAME']) -or [string]::IsNullOrWhiteSpace($cfg['LAB_INSTRUCTOR_PASSWORD_HASH'])) {
    $instructorId = 'invigilator'
    Write-Host '  Creating the instructor login. The password below is shown ONCE and stored nowhere: write it down now.' -ForegroundColor Cyan
    $made = & (Join-Path $PSScriptRoot 'make-instructor-credential.ps1')
    $hashLine = @($made) | Where-Object { $_ -is [string] -and $_.StartsWith('LAB_INSTRUCTOR_PASSWORD_HASH=') } | Select-Object -First 1
    if (-not $hashLine) { throw 'make-instructor-credential.ps1 did not return a password hash.' }
    Set-DotEnvValue $envPath 'LAB_INSTRUCTOR_USERNAME' $instructorId
    Set-DotEnvValue $envPath 'LAB_INSTRUCTOR_PASSWORD_HASH' $hashLine.Substring('LAB_INSTRUCTOR_PASSWORD_HASH='.Length)
    Write-Host "  Instructor ID: $instructorId   (change LAB_INSTRUCTOR_USERNAME in .env if you prefer another name)" -ForegroundColor Cyan
    Write-Done 'Instructor login saved to .env.'
} else {
    Write-Done 'Instructor login is already in .env. To replace it, delete both LAB_INSTRUCTOR_* lines and run setup again.'
}

# 3. Folders the services write into.
Write-Step '[3/7] Creating storage folders...'
foreach ($d in 'CampusExam\build_dev', 'CampusExam\keys', 'CampusExam\lab_server_keys', 'CampusExam\lab_storage\packages',
               'CampusExam\lab_storage\submissions', 'CampusExam\lab_storage\results', 'CampusExam\lab_storage\credentials',
               'CampusExam\lab_storage\logs', 'CampusExam\audit_storage\results') {
    New-Item -ItemType Directory -Force -Path (Join-Path $RepoRoot $d) | Out-Null
}
Write-Done 'Folders ready.'

# 4. Packages.
Write-Step '[4/7] Installing packages (a few minutes the first time)...'
$studentDir = Join-Path $RepoRoot 'student-portal (Final)\student-portal (Final)\student-portal'
foreach ($app in 'admin-portal (7)', 'coe-portal (7)') { Invoke-NpmInstall (Join-Path $RepoRoot $app) }
Invoke-NpmInstall $studentDir
Write-Done 'Packages installed.'

# 5. The portal students use, built for production (same-origin, no source maps).
Write-Step '[5/7] Building the student portal...'
Push-Location -LiteralPath $studentDir
try {
    npm.cmd run build
    if ($LASTEXITCODE -ne 0) { throw 'The student portal build failed. Read the error above.' }
} finally {
    Pop-Location
}
Write-Done 'Student portal built.'

# 6. Java services and their key pairs.
Write-Step '[6/7] Compiling the Java services...'
Push-Location -LiteralPath (Join-Path $RepoRoot 'CampusExam')
try {
    javac -d build_dev -cp lib/postgresql.jar -sourcepath src CampusExam.java LabServer.java
    if ($LASTEXITCODE -ne 0) { throw 'javac failed. Read the error above; a JDK 17 or newer is required.' }
    java -cp 'build_dev;lib/postgresql.jar' CampusExam --init-keys
    java -cp build_dev LabServer --init-keys
} finally {
    Pop-Location
}
Write-Done 'Compiled, and the RSA key pairs exist.'

# 7. Database. init_database.ps1 creates the role and database if missing and loads CampusExam\database_dump.sql only
# into a database that has no `account` table. That dump contains DROP statements, hence the question.
Write-Step '[7/7] Database...'
if ($SkipDatabase) {
    Write-Host '  Skipped (-SkipDatabase).' -ForegroundColor DarkYellow
} else {
    $cfg = Read-DotEnv $envPath
    $go = $Yes.IsPresent
    if (-not $go) {
        Write-Host '  This creates the PostgreSQL role and database from .env if they are missing. Only if the database has no'
        Write-Host '  "account" table does it load CampusExam\database_dump.sql, which contains DROP statements.'
        $go = (Read-Host '  Initialise the database now? [y/N]') -match '^(y|yes)$'
    }
    if ($go) {
        $initArgs = @{}
        if ($cfg['DB_USER']) { $initArgs.AppUser = $cfg['DB_USER'] }
        if ($cfg['DB_PASSWORD']) { $initArgs.AppPassword = $cfg['DB_PASSWORD'] }
        if ($cfg['DB_NAME']) { $initArgs.Database = $cfg['DB_NAME'] }
        if ($cfg['DB_URL'] -match '^jdbc:postgresql://([^:/]+)(?::(\d+))?/') {
            $initArgs.DbHost = $Matches[1]
            if ($Matches[2]) { $initArgs.Port = [int]$Matches[2] }
        }
        $global:LASTEXITCODE = 0
        & (Join-Path $RepoRoot 'init_database.ps1') @initArgs
        if ($LASTEXITCODE -ne 0) { throw 'The database could not be initialised. Read the message above, fix it, and run setup again.' }
        Write-Done 'Database ready.'
    } else {
        Write-Host '  Skipped. Run .\init_database.ps1 yourself before the first start.' -ForegroundColor DarkYellow
    }
}

Write-Host "`n====================================================================" -ForegroundColor Green
Write-Host '  SETUP COMPLETE' -ForegroundColor Green
Write-Host '====================================================================' -ForegroundColor Green
Write-Host '  Next:  .\deploy\start-exam.ps1'
Write-Host '  One-time Tailscale admin-console steps are in DEPLOYMENT.md.'
