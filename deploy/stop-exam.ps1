# Ends the sitting: turns Funnel off, stops every exam service and confirms nothing is still listening.
#   .\deploy\stop-exam.ps1
$ErrorActionPreference = 'Continue'
. "$PSScriptRoot\env.ps1"
$cfg = Get-ExamEnv
$ports = Get-ExamPorts $cfg

# Funnel first, so nothing public points at a service that is going away.
Write-Host 'Turning Funnel off...' -ForegroundColor Yellow
$ts = Get-TailscaleExe
if ($ts) {
    & $ts funnel reset
} else {
    Write-Host '  Tailscale was not found. If you turned Funnel on, turn it off by hand: tailscale funnel reset' -ForegroundColor DarkYellow
}

Write-Host 'Stopping exam services...' -ForegroundColor Yellow
$pidFile = Join-Path $RepoRoot 'CampusExam\lab_storage\exam_pids.json'
if (Test-Path -LiteralPath $pidFile) {
    try {
        $recorded = Get-Content -LiteralPath $pidFile -Raw | ConvertFrom-Json
        foreach ($entry in $recorded.PSObject.Properties) { Stop-ProcessTree ([int]$entry.Value) }
    } catch { }
    Remove-Item -LiteralPath $pidFile -Force -ErrorAction SilentlyContinue
}
# Anything still holding one of the exam ports (a child that outlived its parent, or a service started by hand).
foreach ($l in @(Get-ListenersOn $ports)) {
    if ($l.OwningProcess -gt 4) {
        Write-Host "  Stopping process $($l.OwningProcess) listening on port $($l.LocalPort)" -ForegroundColor DarkYellow
        Stop-ProcessTree ([int]$l.OwningProcess)
    }
}
Start-Sleep -Seconds 1

$left = @(Get-ListenersOn $ports)
if ($left.Count -gt 0) {
    Write-Host "Still listening on port(s) $((($left | ForEach-Object { $_.LocalPort }) | Sort-Object -Unique) -join ', ') (process id $($left[0].OwningProcess))." -ForegroundColor Red
    Write-Host '  Fix: end that process in Task Manager, then run this again.' -ForegroundColor Yellow
    exit 1
}
Write-Host '[ OK ] Funnel is off and nothing is listening on the exam ports.' -ForegroundColor Green

$backup = $cfg['BACKUP_DIR']
if (-not [System.IO.Path]::IsPathRooted($backup)) { $backup = Join-Path $RepoRoot $backup }
Write-Host "`nBefore you close up:" -ForegroundColor Cyan
Write-Host '  1. Finalise and export the results from the COE portal. If you have not yet, run .\deploy\start-exam.ps1 again'
Write-Host '     (do NOT run its tailscale command) and export them; the lab server and COE portal were just stopped.'
Write-Host '  2. Copy the answers and results off this PC. For example:'
Write-Host "       Copy-Item -Recurse '$RepoRoot\CampusExam\lab_storage' '$backup\lab_storage_$(Get-Date -Format 'yyyyMMdd-HHmm')'"
Write-Host '  Keep lab_storage until the results are approved; it is the only copy of the students'' answers.'
