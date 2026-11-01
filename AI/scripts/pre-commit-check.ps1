<#
.SYNOPSIS
  Chequeo pre-commit: bloquea secretos fuera de temp/.
  Sin tildes (PS5.1 + UTF8). Falla (exit 1) si encuentra senales de secreto
  en archivos staged que no esten bajo temp/ y sin marcador ***REDACTED***.

.DESCRIPTION
  Patrones: clientsecret, password, BEGIN PRIVATE, JWT (eyJ...).
  Whitelist: lineas con ***REDACTED*** se ignoran. Todo bajo temp/ se ignora
  (artefactos transitorios, incluyendo *.raw.log del broker cf-safe).

  Uso manual:
    powershell -ExecutionPolicy Bypass -File scripts/pre-commit-check.ps1
  Uso como hook (una vez, manual):
    git config core.hooksPath .githooks
    (copiar este archivo a .githooks/pre-commit sin extension)
#>
$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path $PSScriptRoot -Parent
Set-Location $RepoRoot

$staged = @()
try {
  $staged = @(git diff --cached --name-only --diff-filter=ACM 2>$null | Where-Object { $_ -and $_.Trim() -ne '' })
} catch {
  Write-Output 'pre-commit-check: sin repo git o sin staged; nada que revisar.'
  exit 0
}
if ($staged.Count -eq 0) { Write-Output 'pre-commit-check: sin cambios staged; OK.'; exit 0 }

$patterns = @('clientsecret', 'password', 'BEGIN PRIVATE', 'eyJ[A-Za-z0-9_-]+\.eyJ')
$fail = 0
foreach ($f in $staged) {
  if ($f -match '(?i)^temp/') { continue }
  $full = Join-Path $RepoRoot $f
  if (-not (Test-Path $full -PathType Leaf)) { continue }
  $hits = Select-String -Path $full -Pattern $patterns -CaseSensitive:$false -ErrorAction SilentlyContinue |
    Where-Object { $_.Line -notmatch '\*\*\*REDACTED\*\*\*' }
  foreach ($h in $hits) {
    Write-Output ("BLOQUEADO: posible secreto en {0}:{1} [{2}]" -f $f, $h.LineNumber, ($h.Line.Trim()))
    $fail++
  }
}
if ($fail -gt 0) {
  Write-Output "pre-commit-check: $fail hallazgo(s). Redacta con ***REDACTED*** o mueve a temp/."
  exit 1
}
Write-Output 'pre-commit-check: OK, sin secretos detectados.'
exit 0
