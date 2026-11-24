<#
.SYNOPSIS
Wipes the exam data between sittings. Keeps .env, the RSA keys and every account.

.DESCRIPTION
WIPES
  CampusExam\lab_storage\packages, submissions, results, credentials  (packages, sessions, answers, submissions, lock state,
      recovery history, suspicious events, PC recovery events, result exports, sitting unlock verifiers)
  CampusExam\audit_storage\results                                     (generated result exports)
  PostgreSQL: the exam, sitting, schedule, package, result and student-response tables (deploy\reset-data-db.js lists them)
KEEPS, untouched
  .env (secrets, DB login, instructor and staff hashes), the RSA keys (CampusExam\keys, CampusExam\lab_server_keys),
  staff and student account rows, rosters, departments, subjects, laboratories, question banks, the audit log, service logs.

It refuses to run while any exam service is listening, prints what it will clear, asks you to type WIPE (-Force skips that),
copies lab_storage and the result exports to <BACKUP_DIR>\<timestamp> and checks the copy, then clears the database in one
transaction (all or nothing) and finally the files.
The database rows are NOT in the backup. To keep them, run pg_dump first.

.PARAMETER Force
Skip the typed confirmation (for scripts). Every other check still applies.

.EXAMPLE
.\deploy\stop-exam.ps1
.\deploy\reset-data.ps1
#>
param([switch]$Force)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\env.ps1"

function Stop-Reset([string]$Message) {
    Write-Host "Not wiping: $Message Nothing was changed." -ForegroundColor Red
    exit 1
}
function Get-TreeFiles([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return @() }
    return @(Get-ChildItem -LiteralPath $Path -Recurse -File -Force -ErrorAction SilentlyContinue)
}

if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot '.env'))) { Stop-Reset '.env does not exist.' }
$cfg = Get-ExamEnv

# The lab server keeps the packages where LAB_STORAGE_DIR says; a different value would leave them behind unnoticed.
$storageSetting = ([string]$cfg['LAB_STORAGE_DIR']).Trim().Replace('\', '/').TrimEnd('/')
if ($storageSetting -and $storageSetting -ne 'lab_storage/packages') {
    Stop-Reset "LAB_STORAGE_DIR is '$storageSetting', not the default lab_storage/packages, so this script cannot tell where the packages are."
}

$busy = @(Get-ListenersOn (Get-ExamPorts $cfg))
if ($busy.Count -gt 0) {
    $list = ($busy | ForEach-Object { "port $($_.LocalPort) (process id $($_.OwningProcess))" } | Sort-Object -Unique) -join ', '
    Stop-Reset "exam services are still listening: $list. Run .\deploy\stop-exam.ps1 first."
}

$node = Get-Command node -ErrorAction SilentlyContinue
if (-not $node) { Stop-Reset 'Node.js was not found, which is needed to reach the database.' }
$helper = Join-Path $PSScriptRoot 'reset-data-db.js'

# Reading the database first also proves it is reachable: a files-only wipe would leave the two out of step.
$global:LASTEXITCODE = 0
$countLines = @(& $node.Source $helper --count)
if ($LASTEXITCODE -ne 0) { Stop-Reset 'the database could not be read (the message above says why).' }
$tables = @($countLines | Where-Object { $_ -like 'ROWS*' } | ForEach-Object { $f = $_ -split "`t"; [pscustomobject]@{ Name = $f[1]; Rows = [int64]$f[2] } })
$missing = @($countLines | Where-Object { $_ -like 'MISSING*' } | ForEach-Object { ($_ -split "`t")[1] })

$campus = Join-Path $RepoRoot 'CampusExam'
$targets = @(
    @{ Label = 'packages';                                                   Path = Join-Path $campus 'lab_storage\packages' },
    @{ Label = 'sessions, answers, submissions, lock state, recovery history, suspicious events, PC recovery events'; Path = Join-Path $campus 'lab_storage\submissions' },
    @{ Label = 'result exports';                                             Path = Join-Path $campus 'lab_storage\results' },
    @{ Label = 'sitting unlock verifiers';                                   Path = Join-Path $campus 'lab_storage\credentials' },
    @{ Label = 'audit result exports';                                       Path = Join-Path $campus 'audit_storage\results' }
)
foreach ($t in $targets) { $t.Files = Get-TreeFiles $t.Path }

Write-Host "`nThis will permanently delete:" -ForegroundColor Yellow
foreach ($t in $targets) {
    $mb = [math]::Round((($t.Files | Measure-Object Length -Sum).Sum / 1MB), 2)
    Write-Host ("  {0,5} file(s) {1,8} MB  {2}  ({3})" -f $t.Files.Count, $mb, $t.Label, ($t.Path.Substring($RepoRoot.Length + 1)))
}
$rowTotal = ($tables | Measure-Object Rows -Sum).Sum
Write-Host "  $rowTotal database row(s) in $($tables.Count) table(s):"
foreach ($row in ($tables | Where-Object { $_.Rows -gt 0 })) { Write-Host ("  {0,10}  {1}" -f $row.Rows, $row.Name) }
if (($tables | Where-Object { $_.Rows -gt 0 }).Count -eq 0) { Write-Host '            (every one of those tables is already empty)' }
if ($missing.Count -gt 0) { Write-Host "  Not in this database, skipped: $($missing -join ', ')" -ForegroundColor DarkYellow }
Write-Host 'It keeps: .env, the RSA keys, staff and student accounts, rosters, institution data, question banks, the audit log and the service logs.' -ForegroundColor Green
Write-Host 'The database rows are not in the backup; run pg_dump first if you may want them back.' -ForegroundColor DarkYellow

if (-not $Force) {
    try {
        $typed = Read-Host "`nType WIPE to delete all of the above (anything else cancels)"
    } catch {
        Stop-Reset 'this window cannot ask for confirmation. Run it in an interactive PowerShell window, or add -Force.'
    }
    if ($typed -cne 'WIPE') { Stop-Reset 'confirmation was not given.' }
}

# 1. Back up. Nothing is deleted until the copy has been checked.
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupRoot = if ([System.IO.Path]::IsPathRooted([string]$cfg['BACKUP_DIR'])) { [string]$cfg['BACKUP_DIR'] } else { Join-Path $RepoRoot ([string]$cfg['BACKUP_DIR']) }
$backupDir = Join-Path $backupRoot $stamp
$copies = @(@{ From = Join-Path $campus 'lab_storage'; To = Join-Path $backupDir 'lab_storage' },
            @{ From = Join-Path $campus 'audit_storage\results'; To = Join-Path $backupDir 'audit_storage\results' })
foreach ($c in $copies) {
    if (-not (Test-Path -LiteralPath $c.From)) { continue }
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $c.To) | Out-Null
    Copy-Item -LiteralPath $c.From -Destination $c.To -Recurse -Force
    $a = Get-TreeFiles $c.From
    $b = Get-TreeFiles $c.To
    if ($a.Count -ne $b.Count -or ($a | Measure-Object Length -Sum).Sum -ne ($b | Measure-Object Length -Sum).Sum) {
        Stop-Reset "the backup of $($c.From) does not match the original (copied to $backupDir)."
    }
}
Write-Host "`nBacked up lab_storage and the result exports to $backupDir" -ForegroundColor Green

# 2. The database goes first: it is all-or-nothing, so a failure leaves the files untouched.
$global:LASTEXITCODE = 0
$wipeLines = @(& $node.Source $helper --wipe)
if ($LASTEXITCODE -ne 0) {
    Write-Host "The database wipe failed (message above) and was rolled back. The files were not touched; the backup is at $backupDir." -ForegroundColor Red
    exit 1
}

# 3. Files. The folders stay; only what is inside goes. exam_pids.json, logs, .env and the keys are never in these folders.
$failed = $false
foreach ($t in $targets) {
    if (-not (Test-Path -LiteralPath $t.Path)) { continue }
    try {
        Get-ChildItem -LiteralPath $t.Path -Force | Remove-Item -Recurse -Force
    } catch {
        Write-Host "Could not clear $($t.Path): $($_.Exception.Message)" -ForegroundColor Red
        $failed = $true
    }
}

Write-Host "`nCleared:" -ForegroundColor Cyan
foreach ($t in $targets) {
    $left = (Get-TreeFiles $t.Path).Count
    Write-Host ("  {0,5} file(s) removed from {1}{2}" -f ($t.Files.Count - $left), $t.Path.Substring($RepoRoot.Length + 1), $(if ($left -gt 0) { " ($left left)" } else { '' }))
}
foreach ($line in $wipeLines) {
    if ($line -like 'CLEARED*') { $f = $line -split "`t"; if ([int64]$f[2] -gt 0) { Write-Host ("  {0,5} row(s) removed from table {1}" -f $f[2], $f[1]) } }
}
Write-Host "Kept untouched: .env, CampusExam\keys, CampusExam\lab_server_keys, account rows, logs." -ForegroundColor Green
Write-Host "Backup: $backupDir" -ForegroundColor Green
if ($failed) { exit 1 }
