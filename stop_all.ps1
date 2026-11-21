# MIT Mysore EMS - Unified System Stopper
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

Write-Host "Stopping all MIT Mysore EMS services..." -ForegroundColor Yellow

$ports = @(8080, 3000, 3001, 3002)
foreach ($p in $ports) {
    $conns = Get-NetTCPConnection -LocalPort $p -State Listen -ErrorAction SilentlyContinue
    foreach ($c in $conns) {
        if ($c.OwningProcess -gt 0) {
            Write-Host "Terminating process on port $p (PID $($c.OwningProcess))..." -ForegroundColor Red
            Stop-Process -Id $c.OwningProcess -Force -ErrorAction SilentlyContinue
        }
    }
}

Write-Host "All portal and backend ports (8080, 3000, 3001, 3002) are now free." -ForegroundColor Green
