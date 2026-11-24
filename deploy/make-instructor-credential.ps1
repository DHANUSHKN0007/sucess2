# Prints the LAB_INSTRUCTOR_PASSWORD_HASH line for the lab server's instructor login.
# Usage: .\make-instructor-credential.ps1 [-Password <password>]
# With no password, generates a strong one and shows it once.
# Format: <saltHex>:<hashHex>, PBKDF2-HMAC-SHA256, 600000 iterations, 32-byte hash (matches LabServer.derive).
param([string]$Password)
$ErrorActionPreference = 'Stop'

function ConvertTo-HexString([byte[]]$Bytes) { -join ($Bytes | ForEach-Object { $_.ToString('x2') }) }

$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
$generated = [string]::IsNullOrEmpty($Password)
if ($generated) {
    $raw = New-Object byte[] 18
    $rng.GetBytes($raw)
    $Password = [Convert]::ToBase64String($raw).Replace('+', '-').Replace('/', '_')
}
$salt = New-Object byte[] 16
$rng.GetBytes($salt)
$kdf = New-Object System.Security.Cryptography.Rfc2898DeriveBytes($Password, $salt, 600000, [System.Security.Cryptography.HashAlgorithmName]::SHA256)
$hash = $kdf.GetBytes(32)

if ($generated) {
    Write-Host "Generated instructor password (shown once - store it now): $Password"
}
"LAB_INSTRUCTOR_PASSWORD_HASH=$(ConvertTo-HexString $salt):$(ConvertTo-HexString $hash)"
