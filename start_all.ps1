# MIT Mysore EMS - Unified System Launcher (Development)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " MAHARAJA INSTITUTE OF TECHNOLOGY MYSORE - EMS" -ForegroundColor Cyan
Write-Host " Development Services Launcher (Central, Lab & 3 Portals)" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$root = $PSScriptRoot
$backendRoot = if (Test-Path "$root\CampusExam") { "$root\CampusExam" } else { Resolve-Path "$root\..\TRANSFER-main\TRANSFER-main\CampusExam" }

function Test-PortListening {
    param([int]$Port)
    $conns = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
    return ($null -ne $conns -and $conns.Count -gt 0)
}

# 1. Central Java Backend (Port 8081, campusexam_test)
if (Test-PortListening 8081) {
    Write-Host "[OK] Central Java Backend is already running on port 8081" -ForegroundColor Green
} else {
    Write-Host "Starting Central Java Backend on port 8081..." -ForegroundColor Yellow
    $centralCmd = "`$env:DB_URL='jdbc:postgresql://localhost:5432/campusexam_test'; `$env:DB_USER='campusexam'; `$env:DB_PASSWORD='password'; `$env:PORT='8081'; `$env:LAB_SERVER_URL='http://127.0.0.1:8082'; cd '$backendRoot'; Write-Host '=== CENTRAL BACKEND (Port 8081) ===' -ForegroundColor Cyan; java -cp 'build_dev;lib/postgresql.jar' CampusExam"
    Start-Process powershell -ArgumentList "-ExecutionPolicy", "Bypass", "-NoExit", "-Command", $centralCmd
    Start-Sleep -Seconds 2
}

# 2. Independent Lab Server (Port 8082, LAB-CSE-01)
if (Test-PortListening 8082) {
    Write-Host "[OK] Independent Lab Server is already running on port 8082" -ForegroundColor Green
} else {
    Write-Host "Starting Independent Lab Server on port 8082..." -ForegroundColor Yellow
    $labCmd = "`$env:PORT='8082'; `$env:BIND='127.0.0.1'; `$env:LAB_ID='LAB-CSE-01'; `$env:CENTRAL_URL='http://127.0.0.1:8081'; cd '$backendRoot'; Write-Host '=== INDEPENDENT LAB SERVER (Port 8082) ===' -ForegroundColor Cyan; java -cp 'build_dev' LabServer"
    Start-Process powershell -ArgumentList "-ExecutionPolicy", "Bypass", "-NoExit", "-Command", $labCmd
    Start-Sleep -Seconds 2
}

# 3. Admin / HOD / Principal Portal (Port 3000)
if (Test-PortListening 3000) {
    Write-Host "[OK] Admin/HOD Portal is already running on port 3000" -ForegroundColor Green
} else {
    Write-Host "Starting Admin/HOD Portal on port 3000..." -ForegroundColor Yellow
    $adminCmd = "`$env:VITE_API_BASE_URL='http://127.0.0.1:8081/api/v1'; cd '$root\admin-portal (7)'; Write-Host '=== ADMIN/HOD PORTAL (Port 3000) ===' -ForegroundColor Green; npm.cmd run dev"
    Start-Process powershell -ArgumentList "-ExecutionPolicy", "Bypass", "-NoExit", "-Command", $adminCmd
}

# 4. COE Portal (Port 3001)
if (Test-PortListening 3001) {
    Write-Host "[OK] COE Portal is already running on port 3001" -ForegroundColor Green
} else {
    Write-Host "Starting COE Portal on port 3001..." -ForegroundColor Yellow
    $coeCmd = "`$env:VITE_API_BASE_URL='http://127.0.0.1:8081/api/v1'; `$env:VITE_LAB_API_BASE_URL='http://127.0.0.1:8082/lab-api'; cd '$root\coe-portal (7)'; Write-Host '=== COE PORTAL (Port 3001) ===' -ForegroundColor Yellow; npm.cmd run dev -- --port 3001 --host 127.0.0.1"
    Start-Process powershell -ArgumentList "-ExecutionPolicy", "Bypass", "-NoExit", "-Command", $coeCmd
}

# 5. Student Portal (Port 3002)
if (Test-PortListening 3002) {
    Write-Host "[OK] Student Portal is already running on port 3002" -ForegroundColor Green
} else {
    Write-Host "Starting Student Portal on port 3002..." -ForegroundColor Yellow
    $studentCmd = "`$env:VITE_API_URL='http://localhost:8082'; `$env:VITE_LAB_API_BASE_URL='http://localhost:8082'; cd '$root\student-portal (Final)\student-portal (Final)\student-portal'; Write-Host '=== STUDENT PORTAL (Port 3002) ===' -ForegroundColor Magenta; npm.cmd run dev -- --port 3002 --host 127.0.0.1"
    Start-Process powershell -ArgumentList "-ExecutionPolicy", "Bypass", "-NoExit", "-Command", $studentCmd
}

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Green
Write-Host " ALL FIVE SERVICES CONFIGURED ON DEDICATED PORTS:" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "  1. Central Backend (Java): http://127.0.0.1:8081  (campusexam_test)" -ForegroundColor Cyan
Write-Host "  2. Lab Server (Offline):   http://127.0.0.1:8082  (LAB-CSE-01)" -ForegroundColor Cyan
Write-Host "  3. Admin/HOD Portal:       http://localhost:3000  (Principal & HOD)" -ForegroundColor Green
Write-Host "  4. COE Portal:             http://localhost:3001  (Controller of Examinations)" -ForegroundColor Yellow
Write-Host "  5. Student Portal:         http://localhost:3002  (Student Examination Runtime)" -ForegroundColor Magenta
Write-Host "==========================================================" -ForegroundColor Green
