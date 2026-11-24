# Starts every exam service bound to 127.0.0.1 and PRINTS the three Tailscale commands that publish the student, admin and COE gateways.
# It never runs them: you run them yourself when you are ready to let people in.
#   .\deploy\start-exam.ps1
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\env.ps1"

if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot '.env'))) {
    Write-Host 'Not starting: .env does not exist. Run .\deploy\setup.ps1 first.' -ForegroundColor Red
    exit 1
}
$cfg = Get-ExamEnv

# Without the first two there is no instructor login, so a crashed student PC could not be recovered. Without the last two
# the admin and COE accounts have no password at all.
foreach ($k in 'LAB_INSTRUCTOR_USERNAME', 'LAB_INSTRUCTOR_PASSWORD_HASH', 'STAFF_PASSWORD_HASH_ADMIN', 'STAFF_PASSWORD_HASH_COE') {
    if (-not $cfg.Contains($k) -or [string]::IsNullOrWhiteSpace($cfg[$k])) {
        Write-Host "Not starting: $k is missing from .env." -ForegroundColor Red
        if ($k -like 'STAFF_PASSWORD_HASH_*') {
            Write-Host '  Fix: run .\deploy\set-staff-password.ps1; it sets the admin and COE passwords and shows them once.' -ForegroundColor Yellow
        } else {
            Write-Host '  Fix: run .\deploy\setup.ps1; it creates the instructor login and shows its password once.' -ForegroundColor Yellow
        }
        exit 1
    }
}

$global:LASTEXITCODE = 0
& "$PSScriptRoot\preflight.ps1"
if ($LASTEXITCODE -ne 0) {
    Write-Host 'Not starting: fix the problems above, then run this again.' -ForegroundColor Red
    exit 1
}

# Every .env value goes into this process; each service started below inherits all of them.
foreach ($k in $cfg.Keys) { Set-Item -Path "Env:$k" -Value $cfg[$k] }

$campusDir = Join-Path $RepoRoot 'CampusExam'
$logDir = Join-Path $campusDir 'lab_storage\logs'
$pidFile = Join-Path $campusDir 'lab_storage\exam_pids.json'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$started = [ordered]@{}

# $Extra holds the per-service values (port, bind address) that differ from the shared .env, because one .env key such as
# PORT cannot be right for the central backend, the lab server and the portals at once.
function Start-ExamService([string]$Name, [string]$File, [string[]]$Arguments, [string]$WorkDir, [hashtable]$Extra) {
    foreach ($k in $Extra.Keys) { Set-Item -Path "Env:$k" -Value $Extra[$k] }
    $p = Start-Process -FilePath $File -ArgumentList $Arguments -WorkingDirectory $WorkDir -WindowStyle Hidden -PassThru `
        -RedirectStandardOutput (Join-Path $logDir "$Name.out.log") -RedirectStandardError (Join-Path $logDir "$Name.err.log")
    $script:started[$Name] = $p.Id
    Write-Host "  [ OK ] $Name started (process id $($p.Id))" -ForegroundColor Green
}

function Stop-Started {
    foreach ($id in $started.Values) { Stop-ProcessTree ([int]$id) }
}

function Wait-Until([scriptblock]$Test, [int]$Seconds) {
    $deadline = (Get-Date).AddSeconds($Seconds)
    while ((Get-Date) -lt $deadline) {
        try { if (& $Test) { return $true } } catch { }
        Start-Sleep -Seconds 1
    }
    return $false
}

function Stop-WithMessage([string]$Message) {
    Stop-Started
    Write-Host "Not running: $Message" -ForegroundColor Red
    Write-Host "  Service logs are in $logDir" -ForegroundColor Yellow
    exit 1
}

$java = (Get-Command java | Select-Object -First 1).Source
$node = (Get-Command node | Select-Object -First 1).Source
$npm = (Get-Command npm.cmd | Select-Object -First 1).Source
$centralPort = [int]$cfg['PORT']
$gatewayPort = [int]$cfg['GATEWAY_PORT']
$adminGatewayPort = [int]$cfg['ADMIN_GATEWAY_PORT']
$coeGatewayPort = [int]$cfg['COE_GATEWAY_PORT']

Write-Host "`nStarting services (all on 127.0.0.1)..." -ForegroundColor Cyan
Start-ExamService 'central' $java @('-cp', 'build_dev;lib/postgresql.jar', 'CampusExam') $campusDir @{ PORT = $cfg['PORT']; BIND = $cfg['BIND'] }
Start-ExamService 'lab-server' $java @('-cp', 'build_dev', 'LabServer') $campusDir @{ PORT = $cfg['LAB_PORT']; BIND = $cfg['LAB_BIND'] }
# One gateway per portal. Each is given every value it reads, because the overrides above leak into the services started after them.
$gatewayJs = '"' + (Join-Path $RepoRoot 'deploy\gateway\server.js') + '"'
Start-ExamService 'gateway' $node @($gatewayJs) $RepoRoot @{ GATEWAY_PROFILE = 'student'; GATEWAY_PORT = $cfg['GATEWAY_PORT']; LAB_PORT = $cfg['LAB_PORT'] }
Start-ExamService 'gateway-admin' $node @($gatewayJs) $RepoRoot @{ GATEWAY_PROFILE = 'admin'; GATEWAY_PORT = $cfg['ADMIN_GATEWAY_PORT']; CENTRAL_PORT = $cfg['PORT'] }
Start-ExamService 'gateway-coe' $node @($gatewayJs) $RepoRoot @{ GATEWAY_PROFILE = 'coe'; GATEWAY_PORT = $cfg['COE_GATEWAY_PORT']; CENTRAL_PORT = $cfg['PORT'] }
Start-ExamService 'coe-portal' $npm @('run', 'dev', '--', '--port', '3001', '--host', '127.0.0.1') (Join-Path $RepoRoot 'coe-portal (7)') @{ PORT = '3001' }
Start-ExamService 'admin-portal' $npm @('run', 'dev', '--', '--port', '3000', '--host', '127.0.0.1') (Join-Path $RepoRoot 'admin-portal (7)') @{ PORT = '3000' }
$started | ConvertTo-Json | Set-Content -LiteralPath $pidFile -Encoding UTF8

Write-Host "`nWaiting for the services to answer..." -ForegroundColor Cyan
if (-not (Wait-Until { Test-TcpPort '127.0.0.1' $centralPort } 90)) {
    Stop-WithMessage "the central backend did not open port $centralPort within 90 seconds (is PostgreSQL up and DB_* in .env correct?)."
}
if (-not (Wait-Until { (Invoke-WebRequest -Uri "http://127.0.0.1:$gatewayPort/api/health" -UseBasicParsing -TimeoutSec 3).StatusCode -eq 200 } 90)) {
    Stop-WithMessage "http://127.0.0.1:$gatewayPort/api/health did not answer within 90 seconds, so the gateway or the lab server is not working."
}
Write-Host '  [ OK ] The gateway reaches the lab server (/api/health).' -ForegroundColor Green
foreach ($g in @(@('admin', $adminGatewayPort), @('COE', $coeGatewayPort))) {
    $gp = $g[1]
    if (-not (Wait-Until { (Invoke-WebRequest -Uri "http://127.0.0.1:$gp/api/v1/health" -UseBasicParsing -TimeoutSec 3).StatusCode -eq 200 } 60)) {
        Stop-WithMessage "http://127.0.0.1:$gp/api/v1/health did not answer within 60 seconds, so the $($g[0]) gateway or the central backend is not working."
    }
    Write-Host "  [ OK ] The $($g[0]) gateway reaches the central backend (/api/v1/health)." -ForegroundColor Green
}
if (-not (Wait-Until { Test-TcpPort '127.0.0.1' 3001 } 120)) {
    Write-Host '  [WARN] The COE portal is not up yet (the first start compiles it). Exam delivery is unaffected; see coe-portal.err.log.' -ForegroundColor DarkYellow
}

# Proof, not configuration: ask the OS what is actually listening and where.
$exposed = @(Get-ListenersOn (Get-ExamPorts $cfg) | Where-Object { -not (Test-Loopback ([string]$_.LocalAddress)) })
if ($exposed.Count -gt 0) {
    Stop-WithMessage "port $($exposed[0].LocalPort) is listening on $($exposed[0].LocalAddress), beyond this PC. Everything has been stopped."
}
Write-Host '  [ OK ] Every service listens on 127.0.0.1 only.' -ForegroundColor Green

$st = Get-TailscaleStatus
$publicName = '<this PC''s Tailscale name>'
if ($st -and $st.Self -and $st.Self.DNSName) { $publicName = $st.Self.DNSName.TrimEnd('.') }
$ts = 'tailscale'
if (-not (Get-Command tailscale -ErrorAction SilentlyContinue)) { $ts = "& `"$(Get-TailscaleExe)`"" }

Write-Host "`n====================================================================" -ForegroundColor Green
Write-Host '  EXAM SERVICES ARE RUNNING (reachable from this PC only)' -ForegroundColor Green
Write-Host '====================================================================' -ForegroundColor Green
Write-Host '  Nothing is public yet. These commands are never run for you. When you are ready, run all three yourself.'
Write-Host '  Funnel keeps them across restarts, so on a permanent host this is needed once, not per exam:'
Write-Host "`n      $ts funnel --bg $gatewayPort"
Write-Host "      $ts funnel --bg --https=8443 $adminGatewayPort"
Write-Host "      $ts funnel --bg --https=10000 $coeGatewayPort`n" -ForegroundColor Yellow
Write-Host "  Students open:   https://$publicName/"
Write-Host "  Admin portal:    https://${publicName}:8443/"
Write-Host "  COE portal:      https://${publicName}:10000/"
Write-Host '  Staff, on this PC, with every feature (document converter, lab-server screens):'
Write-Host '                   COE portal  http://127.0.0.1:3001     Admin portal  http://127.0.0.1:3000'
Write-Host '  Those addresses are public and appear in certificate transparency logs: discoverable, not secret.'
Write-Host '  Access control is the logins, never the secrecy of the URL.'
Write-Host '  When the sitting ends:  .\deploy\stop-exam.ps1   (it leaves Funnel as it is)' -ForegroundColor Cyan
Write-Host '====================================================================' -ForegroundColor Green
