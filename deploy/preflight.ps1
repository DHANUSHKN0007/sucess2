# Checks everything an exam sitting depends on. One line per check; every failure says what is wrong and how to fix it.
# Exit code 0 = safe to start. Run it alone any time:  .\deploy\preflight.ps1
# start-exam.ps1 runs it first and refuses to start when it fails.
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\env.ps1"

$script:failures = 0
function Write-Ok([string]$Msg) { Write-Host "  [ OK ] $Msg" -ForegroundColor Green }
function Write-Caution([string]$Msg) { Write-Host "  [WARN] $Msg" -ForegroundColor DarkYellow }
function Write-Problem([string]$Problem, [string]$Fix) {
    $script:failures++
    Write-Host "  [FAIL] $Problem" -ForegroundColor Red
    Write-Host "         Fix: $Fix" -ForegroundColor Yellow
}

Write-Host 'CampusExam preflight' -ForegroundColor Cyan

# --- .env -------------------------------------------------------------------------------------------------------------
if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot '.env'))) {
    Write-Problem '.env does not exist.' 'Run .\deploy\setup.ps1; it creates .env from .env.example.'
    Write-Host "`nPreflight FAILED. Nothing else can be checked without .env." -ForegroundColor Red
    exit 1
}
$cfg = Get-ExamEnv

$required = 'JWT_SECRET', 'LAB_INSTRUCTOR_USERNAME', 'LAB_INSTRUCTOR_PASSWORD_HASH', 'DB_URL', 'DB_USER', 'DB_PASSWORD', 'DB_NAME'
$missing = @($required | Where-Object { -not $cfg.Contains($_) -or [string]::IsNullOrWhiteSpace($cfg[$_]) })
if ($missing.Count -gt 0) {
    Write-Problem ".env has no value for: $($missing -join ', ')." 'Run .\deploy\setup.ps1 (it fills JWT_SECRET and the instructor login), or set them in .env.'
} else {
    Write-Ok '.env has every required value.'
}

# The admin and COE portals are public, and these accounts have no password except the one in .env.
foreach ($staff in 'ADMIN', 'COE') {
    $key = "STAFF_PASSWORD_HASH_$staff"
    if (-not $cfg.Contains($key) -or [string]::IsNullOrWhiteSpace($cfg[$key])) {
        Write-Problem "$key is not set, so the $($staff.ToLower()) account cannot sign in." 'Run .\deploy\set-staff-password.ps1.'
    } elseif ($cfg[$key] -notmatch '^[0-9a-fA-F]{32,}:[0-9a-fA-F]{64}$') {
        Write-Problem "$key is not in the expected <salt>:<hash> form." 'Run .\deploy\set-staff-password.ps1 to write a new one.'
    } else {
        Write-Ok "$key is set."
    }
}

if ($cfg.Contains('JWT_SECRET') -and $cfg['JWT_SECRET'].Length -gt 0) {
    if ($cfg['JWT_SECRET'].Length -lt 32) {
        Write-Problem "JWT_SECRET is only $($cfg['JWT_SECRET'].Length) characters; at least 32 are required." 'Delete the JWT_SECRET line in .env and run .\deploy\setup.ps1 to generate a strong one.'
    } else {
        Write-Ok 'JWT_SECRET is set and long enough.'
    }
}

if ($cfg.Contains('LAB_INSTRUCTOR_PASSWORD_HASH') -and $cfg['LAB_INSTRUCTOR_PASSWORD_HASH'].Length -gt 0) {
    if ($cfg['LAB_INSTRUCTOR_PASSWORD_HASH'] -notmatch '^[0-9a-fA-F]{32}:[0-9a-fA-F]{64}$') {
        Write-Problem 'LAB_INSTRUCTOR_PASSWORD_HASH is not in the expected <salt>:<hash> form, so instructor login would be disabled.' 'Delete both LAB_INSTRUCTOR_* lines in .env and run .\deploy\setup.ps1 to create a new login.'
    }
}

# --- switches that must be off ----------------------------------------------------------------------------------------
foreach ($flag in 'LAB_TEST_MODE', 'LAB_STAFF_ALLOW_REMOTE', 'ALLOW_SAMPLE_EXAM') {
    if ($cfg[$flag].Trim().ToLower() -eq 'true') {
        Write-Problem "$flag is true." "Set $flag=false in .env."
    } else {
        Write-Ok "$flag is off."
    }
}

# --- ports and bind addresses -----------------------------------------------------------------------------------------
$portsOk = $true
foreach ($name in 'PORT', 'LAB_PORT', 'GATEWAY_PORT', 'ADMIN_GATEWAY_PORT', 'COE_GATEWAY_PORT') {
    if ($cfg[$name] -notmatch '^\d{1,5}$' -or [int]$cfg[$name] -lt 1 -or [int]$cfg[$name] -gt 65535) {
        Write-Problem "$name is '$($cfg[$name])', not a port number." "Set $name in .env to a number from 1 to 65535."
        $portsOk = $false
    }
}
foreach ($pair in @(@('BIND', 'The central backend'), @('LAB_BIND', 'The lab server'))) {
    if (Test-Loopback ($cfg[$pair[0]])) {
        Write-Ok "$($pair[1]) is set to listen on $($cfg[$pair[0]]) only."
    } else {
        Write-Problem "$($pair[0])=$($cfg[$pair[0]]): $($pair[1]) would listen beyond this PC." "Set $($pair[0])=127.0.0.1 in .env. Students reach the exam through Tailscale, never directly."
    }
}

if ($portsOk) {
    $managed = Get-ExamPorts $cfg
    # 8080 is the Node backend (backend/server.js). start-exam does not start it; if it is running it must not face the network.
    $rows = @(Get-ListenersOn ($managed + 8080))
    $clean = $true
    foreach ($group in ($rows | Group-Object LocalPort)) {
        $port = [int]$group.Name
        $first = $group.Group[0]
        $exposed = @($group.Group | Where-Object { -not (Test-Loopback ([string]$_.LocalAddress)) })
        if ($exposed.Count -gt 0) {
            Write-Problem "Port $port (process id $($first.OwningProcess)) is listening on $($exposed[0].LocalAddress), not on 127.0.0.1 only." 'Stop that process (.\deploy\stop-exam.ps1, or end it in Task Manager). Every exam service must bind 127.0.0.1.'
            $clean = $false
        } elseif ($managed -contains $port) {
            Write-Problem "Port $port is already in use (process id $($first.OwningProcess))." 'Run .\deploy\stop-exam.ps1, or end that process in Task Manager.'
            $clean = $false
        }
    }
    if ($clean) { Write-Ok "Ports $($managed -join ', ') are free and nothing is exposed on port 8080." }
}

# --- built artefacts ---------------------------------------------------------------------------------------------------
foreach ($portal in @(@('student', 'student-portal (Final)\student-portal (Final)\student-portal'), @('admin', 'admin-portal (7)'), @('COE', 'coe-portal (7)'))) {
    $dist = Join-Path $RepoRoot "$($portal[1])\dist"
    if (-not (Test-Path -LiteralPath (Join-Path $dist 'index.html'))) {
        Write-Problem "The $($portal[0]) portal has not been built (dist\index.html is missing)." 'Run .\deploy\setup.ps1.'
    } else {
        $maps = @(Get-ChildItem -LiteralPath $dist -Recurse -Filter '*.map' -File)
        if ($maps.Count -gt 0) {
            Write-Problem "The $($portal[0]) portal build contains $($maps.Count) .map file(s), which expose its source code." 'Delete them, or rebuild with .\deploy\setup.ps1.'
        } else {
            Write-Ok "The $($portal[0]) portal is built and has no .map files."
        }
    }
}

foreach ($cls in 'CampusExam', 'LabServer') {
    if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot "CampusExam\build_dev\$cls.class"))) {
        Write-Problem "$cls has not been compiled." 'Run .\deploy\setup.ps1.'
    }
}

# --- PostgreSQL --------------------------------------------------------------------------------------------------------
$dbHost = $null; $dbPort = 5432
if ($cfg.Contains('DB_URL') -and $cfg['DB_URL'] -match '^jdbc:postgresql://([^:/]+)(?::(\d+))?/') {
    $dbHost = $Matches[1]
    if ($Matches[2]) { $dbPort = [int]$Matches[2] }
} elseif ($cfg.Contains('DB_HOST')) {
    $dbHost = $cfg['DB_HOST']
    if ($cfg.Contains('DB_PORT') -and $cfg['DB_PORT'] -match '^\d+$') { $dbPort = [int]$cfg['DB_PORT'] }
}
if (-not $dbHost) {
    Write-Problem 'DB_URL in .env is missing or not a jdbc:postgresql:// URL.' 'Set DB_URL, e.g. jdbc:postgresql://127.0.0.1:5432/campusexam_test.'
} elseif (Test-TcpPort $dbHost $dbPort) {
    Write-Ok "PostgreSQL answers on ${dbHost}:$dbPort."
    # The staff portals are public, so a password published in the README or the SQL dump must not open any account.
    $nodeCmd = Get-Command node -ErrorAction SilentlyContinue
    if (-not $nodeCmd) {
        Write-Problem 'Node.js was not found, so the demo staff passwords cannot be checked.' 'Install Node.js 18 or newer.'
    } else {
        $global:LASTEXITCODE = 0
        $demoOut = @(& $nodeCmd.Source (Join-Path $PSScriptRoot 'check-demo-credentials.js'))
        if ($LASTEXITCODE -eq 0) {
            Write-Ok 'No demo staff password from the README or database_dump.sql signs in.'
        } elseif ($LASTEXITCODE -eq 1) {
            $names = @($demoOut | ForEach-Object { (($_ -replace '^DEMO ', '') -split ' ')[0] })
            Write-Problem "A demo staff password still signs in: $($names -join ', ')." "Run .\deploy\set-staff-password.ps1 -User $($names -join ','), write down the passwords it shows, then run this again."
        } else {
            Write-Problem 'The demo staff passwords could not be checked (the message above says why).' 'Fix what it names, then run this again.'
        }
    }
} else {
    Write-Problem "PostgreSQL does not answer on ${dbHost}:$dbPort." 'Start the PostgreSQL service (Services > postgresql-x64-NN > Start), then run this again.'
}

# --- storage -----------------------------------------------------------------------------------------------------------
function Test-FolderWritable([string]$Folder) {
    try {
        New-Item -ItemType Directory -Force -Path $Folder | Out-Null
        $probe = Join-Path $Folder '.preflight_probe'
        Set-Content -LiteralPath $probe -Value 'x' -ErrorAction Stop
        Remove-Item -LiteralPath $probe -Force
        return $true
    } catch {
        return $false
    }
}

$labStorage = Join-Path $RepoRoot 'CampusExam\lab_storage'
if (Test-FolderWritable $labStorage) {
    $free = ''
    try { $free = ", $([math]::Round((Get-PSDrive -Name $labStorage.Substring(0, 1)).Free / 1GB, 1)) GB free on that drive" } catch { }
    Write-Ok "lab_storage is writable$free."
} else {
    Write-Problem "CampusExam\lab_storage is not writable; answers could not be saved." 'Check the folder permissions and that the disk is not full or read-only.'
}

$backup = $cfg['BACKUP_DIR']
if (-not [System.IO.Path]::IsPathRooted($backup)) { $backup = Join-Path $RepoRoot $backup }
if (Test-FolderWritable $backup) {
    Write-Ok "Backup folder $backup is writable."
} else {
    Write-Problem "Backup folder $backup is not writable." 'Set BACKUP_DIR in .env to a folder you can write to (ideally on another drive).'
}

# --- host must not sleep -----------------------------------------------------------------------------------------------
# powercfg prints the AC setting second to last and the battery setting last, each as 0x<seconds>; 0 means never.
function Get-AcTimeoutSeconds([string]$SettingGuid) {
    try {
        $text = (powercfg /query SCHEME_CURRENT 238c9fa8-0aad-41ed-83f4-97be242c8f20 $SettingGuid) -join "`n"
        $hex = [regex]::Matches($text, '0x[0-9a-fA-F]{8}')
        if ($hex.Count -lt 2) { return $null }
        return [Convert]::ToInt64($hex[$hex.Count - 2].Value.Substring(2), 16)
    } catch {
        return $null
    }
}
$sleepAfter = Get-AcTimeoutSeconds '29f6c1db-86da-48c5-9fdb-f2b67b1f44da'
$hibernateAfter = Get-AcTimeoutSeconds '9d7815a6-7ee4-497e-8888-515a05f02364'
if ($null -eq $sleepAfter -or $null -eq $hibernateAfter) {
    Write-Caution 'Could not read the power plan. Make sure this PC never sleeps or hibernates while plugged in.'
} elseif ($sleepAfter -ne 0 -or $hibernateAfter -ne 0) {
    Write-Problem 'This PC is set to sleep or hibernate while plugged in; it would drop every student mid-exam.' 'Run:  powercfg /change standby-timeout-ac 0   and   powercfg /change hibernate-timeout-ac 0'
} else {
    Write-Ok 'Sleep and hibernate are off while plugged in.'
}

# --- Tailscale ---------------------------------------------------------------------------------------------------------
if (-not (Get-TailscaleExe)) {
    Write-Problem 'Tailscale is not installed.' 'Install it from https://tailscale.com/download and sign in.'
} else {
    $st = Get-TailscaleStatus
    if (-not $st) {
        Write-Problem 'Tailscale did not return a status.' 'Open the Tailscale app and sign in, then run this again.'
    } elseif ($st.BackendState -ne 'Running') {
        Write-Problem "Tailscale is not connected (state: $($st.BackendState))." 'Open the Tailscale app, sign in and click Connect.'
    } else {
        Write-Ok 'Tailscale is signed in and running.'
        if ($st.CurrentTailnet -and $st.CurrentTailnet.MagicDNSEnabled) {
            Write-Ok 'MagicDNS is on.'
        } else {
            Write-Problem 'MagicDNS is off for this tailnet.' 'Tailscale admin console > DNS > turn on MagicDNS.'
        }
        $caps = @()
        if ($st.Self -and $st.Self.CapMap) { $caps = @($st.Self.CapMap.PSObject.Properties.Name) }
        if ($caps -contains 'https') {
            Write-Ok 'HTTPS certificates are on.'
        } else {
            Write-Problem 'HTTPS certificates are not enabled for this tailnet.' 'Tailscale admin console > DNS > Enable HTTPS.'
        }
        if ($caps -contains 'funnel') {
            Write-Ok 'This PC is allowed to use Funnel.'
        } else {
            Write-Problem 'This PC is not allowed to use Funnel.' 'Add the funnel node attribute in the tailnet policy file (Tailscale admin console > Access controls). See DEPLOYMENT.md.'
        }
    }
}

Write-Host ''
if ($script:failures -gt 0) {
    Write-Host "Preflight FAILED: $($script:failures) problem(s). Do not start the exam until they are fixed." -ForegroundColor Red
    exit 1
}
Write-Host 'Preflight passed.' -ForegroundColor Green
exit 0
