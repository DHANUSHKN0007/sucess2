<#
.SYNOPSIS
Sets a staff password as a PBKDF2 hash in .env. The password itself is never stored.

.DESCRIPTION
Writes STAFF_PASSWORD_HASH_<USER> into .env (admin -> STAFF_PASSWORD_HASH_ADMIN, hod.cse -> STAFF_PASSWORD_HASH_HOD_CSE).
The central backend reads it at start and makes it that account's only password, so restart the exam services after a change.
Format: <saltHex>:<hashHex>, PBKDF2-HMAC-SHA256, 600000 iterations, 32-byte hash (same as make-instructor-credential).
With no -Password a strong one is generated and shown once; nothing else keeps it, so write it down.

.PARAMETER User
Staff usernames to set. Default: admin and coe, the two accounts the public portals depend on.

.PARAMETER Password
The password (8 to 128 characters). Only with a single -User; leave it out to have one generated.

.EXAMPLE
.\deploy\set-staff-password.ps1
.\deploy\set-staff-password.ps1 -User coe -Password 'a long passphrase'
.\deploy\set-staff-password.ps1 -User hod.cse,hod.ise
#>
param([string[]]$User = @('admin', 'coe'), [string]$Password)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\env.ps1"

$envFile = Join-Path $RepoRoot '.env'
if (-not (Test-Path -LiteralPath $envFile)) {
    Write-Host 'No .env yet. Run .\deploy\setup.ps1 first.' -ForegroundColor Red
    exit 1
}
if ($Password -and $User.Count -ne 1) {
    Write-Host '-Password can only be used with one -User. Leave it out to have a password generated for each.' -ForegroundColor Red
    exit 1
}
if ($Password -and ($Password.Length -lt 8 -or $Password.Length -gt 128)) {
    Write-Host 'The password must have 8 to 128 characters.' -ForegroundColor Red
    exit 1
}

function ConvertTo-HexString([byte[]]$Bytes) { -join ($Bytes | ForEach-Object { $_.ToString('x2') }) }

$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
foreach ($name in $User) {
    $name = $name.Trim().ToLower()
    if ($name -eq '') { continue }
    $pw = $Password
    $generated = [string]::IsNullOrEmpty($pw)
    if ($generated) {
        $raw = New-Object byte[] 18
        $rng.GetBytes($raw)
        $pw = [Convert]::ToBase64String($raw).Replace('+', '-').Replace('/', '_')
    }
    $salt = New-Object byte[] 16
    $rng.GetBytes($salt)
    $hash = (New-Object System.Security.Cryptography.Rfc2898DeriveBytes($pw, $salt, 600000, [System.Security.Cryptography.HashAlgorithmName]::SHA256)).GetBytes(32)
    $key = 'STAFF_PASSWORD_HASH_' + ($name.ToUpper() -replace '[^A-Z0-9]', '_')
    Set-DotEnvValue $envFile $key "$(ConvertTo-HexString $salt):$(ConvertTo-HexString $hash)"
    Write-Host "Set $key in .env for '$name'." -ForegroundColor Green
    if ($generated) { Write-Host "  Generated password for '$name' (shown once - store it now): $pw" }
}
Write-Host 'Restart the exam services (.\deploy\stop-exam.ps1, then .\deploy\start-exam.ps1) for the change to take effect.' -ForegroundColor Cyan
