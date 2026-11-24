# Shared helpers for the deploy scripts. Dot-source it:  . "$PSScriptRoot\env.ps1"
$RepoRoot = Split-Path -Parent $PSScriptRoot

# Reads KEY=VALUE lines from a .env file. Blank lines and lines starting with # are skipped; one pair of
# surrounding quotes is removed. A value is taken literally (no $ expansion, no inline comments).
function Read-DotEnv([string]$Path) {
    $map = [ordered]@{}
    if (-not (Test-Path -LiteralPath $Path)) { return $map }
    foreach ($line in Get-Content -LiteralPath $Path) {
        $t = $line.Trim()
        if ($t -eq '' -or $t.StartsWith('#')) { continue }
        $i = $t.IndexOf('=')
        if ($i -lt 1) { continue }
        $k = $t.Substring(0, $i).Trim()
        $v = $t.Substring($i + 1).Trim()
        if ($v.Length -ge 2 -and (($v.StartsWith('"') -and $v.EndsWith('"')) -or ($v.StartsWith("'") -and $v.EndsWith("'")))) {
            $v = $v.Substring(1, $v.Length - 2)
        }
        $map[$k] = $v
    }
    return $map
}

# The environment every exam service is started with: .env, with a safe default filled in for any switch it leaves out,
# so a stray value in the deployer's shell can never reach a service.
function Get-ExamEnv {
    $cfg = Read-DotEnv (Join-Path $RepoRoot '.env')
    $defaults = [ordered]@{
        PORT = '8081'; BIND = '127.0.0.1'; LAB_PORT = '8082'; LAB_BIND = '127.0.0.1'; GATEWAY_PORT = '3002'
        ADMIN_GATEWAY_PORT = '3003'; COE_GATEWAY_PORT = '3004'
        LAB_TEST_MODE = 'false'; LAB_STAFF_ALLOW_REMOTE = 'false'; ALLOW_SAMPLE_EXAM = 'false'; BACKUP_DIR = 'backups'
    }
    foreach ($k in $defaults.Keys) {
        if (-not $cfg.Contains($k) -or [string]::IsNullOrWhiteSpace($cfg[$k])) { $cfg[$k] = $defaults[$k] }
    }
    return $cfg
}

# Writes KEY=VALUE into a .env file: replaces the first KEY= line, or appends one. Keeps the file's other lines as they are.
function Set-DotEnvValue([string]$Path, [string]$Key, [string]$Value) {
    $text = [System.IO.File]::ReadAllText($Path)
    $pattern = '(?m)^' + [regex]::Escape($Key) + '=[^\r\n]*'
    $line = "$Key=$Value"
    if ([regex]::IsMatch($text, $pattern)) {
        $text = [regex]::Replace($text, $pattern, { param($m) $line })
    } else {
        if ($text.Length -gt 0 -and -not $text.EndsWith("`n")) { $text += "`r`n" }
        $text += $line + "`r`n"
    }
    # No BOM: dotenv would read it as part of the first key.
    [System.IO.File]::WriteAllText($Path, $text, (New-Object System.Text.UTF8Encoding($false)))
}

function Test-Loopback([string]$Address) {
    $a = $Address.Trim().ToLower()
    return ($a -eq 'localhost' -or $a -eq '::1' -or $a -like '127.*')
}

function Test-TcpPort([string]$HostName, [int]$Port) {
    $c = New-Object System.Net.Sockets.TcpClient
    try {
        $iar = $c.BeginConnect($HostName, $Port, $null, $null)
        return ($iar.AsyncWaitHandle.WaitOne(3000) -and $c.Connected)
    } catch {
        return $false
    } finally {
        $c.Close()
    }
}

# Listening TCP sockets on any of the given ports (one row per bound address).
function Get-ListenersOn([int[]]$Ports) {
    Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Where-Object { $Ports -contains $_.LocalPort }
}

function Stop-ProcessTree([int]$ProcessId) {
    Get-CimInstance Win32_Process -Filter "ParentProcessId=$ProcessId" -ErrorAction SilentlyContinue |
        ForEach-Object { Stop-ProcessTree $_.ProcessId }
    Stop-Process -Id $ProcessId -Force -ErrorAction SilentlyContinue
}

function Get-TailscaleExe {
    $c = Get-Command tailscale -ErrorAction SilentlyContinue
    if ($c) { return $c.Source }
    $p = Join-Path $env:ProgramFiles 'Tailscale\tailscale.exe'
    if (Test-Path -LiteralPath $p) { return $p }
    return $null
}

# `tailscale status --json` as an object, or $null when it cannot be read (not signed in, not running).
function Get-TailscaleStatus {
    $ts = Get-TailscaleExe
    if (-not $ts) { return $null }
    try { return ((& $ts status --json) -join "`n") | ConvertFrom-Json } catch { return $null }
}

# Where the managed services listen, from the effective config. Central, lab server, the student, admin and COE gateways,
# then the admin and COE portals' own dev servers (host PC only).
function Get-ExamPorts($Cfg) {
    return @([int]$Cfg['PORT'], [int]$Cfg['LAB_PORT'], [int]$Cfg['GATEWAY_PORT'], [int]$Cfg['ADMIN_GATEWAY_PORT'], [int]$Cfg['COE_GATEWAY_PORT'], 3000, 3001)
}
