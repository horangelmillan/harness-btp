<#
.SYNOPSIS
  Runner único de app-ui5-qunit-opa: HTTP backend + QUnit unit + OPA5 journey.
.DESCRIPTION
  Orden: ensure CDP → arranca CAP propio (4022) → npm test (HTTP) →
  QUnit unit (title vía CDP) → OPA5 journey (title vía CDP) → cleanup en
  finally (CAP por identidad propia + cdp cleanup + puertos libres
  verificados por connect).
  R2.2: nunca Stop-Process -Name chrome; PS 5.1 (sin ver|head|tail|grep).
.EXAMPLE
  powershell -ExecutionPolicy Bypass -File scripts/run-ui5-tests.ps1
  powershell -ExecutionPolicy Bypass -File scripts/run-ui5-tests.ps1 -Port 4022 -CdpPort 9222
#>
param(
  [int]$Port = 4022,
  [int]$CdpPort = 9222
)

$ErrorActionPreference = "Stop"
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
$Fixture = Split-Path -Parent $Here
$RunStart = Get-Date

$candidates = @(
  (Join-Path $Fixture "..\..\..\scripts\cdp-chrome.ps1"),
  (Join-Path (Get-Location) "AI\scripts\cdp-chrome.ps1")
)
$Cdp = $null
foreach ($c in $candidates) {
  if (Test-Path $c) { $Cdp = (Resolve-Path $c).Path; break }
}
if (-not $Cdp) { Write-Output "DETENIDO: cdp-chrome.ps1 no encontrado (probado: $($candidates -join '; '))"; exit 1 }

$CapPid = $null
$fail = 0

function Wait-Cap {
  $t0 = Get-Date
  while (((Get-Date) - $t0).TotalSeconds -lt 90) {
    try {
      $r = curl.exe -s -m 5 "http://localhost:$Port/odata/v4/catalog/Books" 2>$null
      if ($LASTEXITCODE -eq 0 -and $r -match '"value"') { return $true }
    } catch {}
    Start-Sleep -Milliseconds 500
  }
  return $false
}

function Invoke-CdpTitle([string]$Url, [string]$Scope, [int]$TimeoutMs) {
  # Lee document.title vía CDP (node stdlib, sin stdout de chrome).
  # La página escribe "QUNIT <scope>: <n> passed, <m> failed" en <title>.
  & node (Join-Path $Here "cdp-eval.js") $CdpPort $Url $Scope $TimeoutMs 2>&1
  return $LASTEXITCODE
}

function Test-PortFree([int]$p) {
  # Ground truth: connect TCP. 7 = refused = libre. Los TimeWait del
  # kernel (PID 0) rechazan conexión aunque figuren en Get-NetTCPConnection;
  # se reintenta porque node/chrome tardan segundos en soltar el puerto.
  for ($i = 0; $i -lt 8; $i++) {
    curl.exe -s -m 2 -o NUL "http://localhost:$p/" 2>$null
    if ($LASTEXITCODE -eq 7) { return $true }
    Start-Sleep -Seconds 2
  }
  return $false
}

try {
  Write-Output "== ensure CDP =="
  powershell -ExecutionPolicy Bypass -File $Cdp ensure -Port $CdpPort
  if ($LASTEXITCODE -ne 0) { Write-Output "DETENIDO: sin endpoint CDP verificado no hay prueba con navegador."; $fail = 1 }

  if ($fail -eq 0) {
    Write-Output "== arranca CAP (puerto $Port) =="
    $p = Start-Process -FilePath "cmd.exe" -ArgumentList "/d", "/s", "/c", "npx -p @sap/cds-dk cds serve --port $Port --in-memory" `
      -WorkingDirectory $Fixture -WindowStyle Hidden -PassThru
    $CapPid = $p.Id
    if (-not (Wait-Cap)) { Write-Output "DETENIDO: CAP no respondió GET /Books 200 en 90 s."; $fail = 1 }
  }

  if ($fail -eq 0) {
    Write-Output "== HTTP backend (node --test) =="
    $env:PORT = "$Port"
    Push-Location $Fixture
    try {
      & npm test 2>&1 | ForEach-Object { $_ }
      if ($LASTEXITCODE -ne 0) { Write-Output "FALLO: suite HTTP backend en rojo."; $fail = 1 }
    } finally { Pop-Location }
  }

  if ($fail -eq 0) {
    Write-Output "== QUnit unit puro =="
    Invoke-CdpTitle "http://localhost:$Port/test/unit/unitTests.qunit.html" "unit" 120000
    if ($LASTEXITCODE -ne 0) { Write-Output "FALLO: QUnit unit sin 0 failed (¿CDN UI5 bloqueado? ver salida)."; $fail = 1 }
  }

  if ($fail -eq 0) {
    Write-Output "== OPA5 journey CRUD =="
    Invoke-CdpTitle "http://localhost:$Port/test/integration/opaTests.qunit.html" "opa" 240000
    if ($LASTEXITCODE -ne 0) { Write-Output "FALLO: OPA5 sin 0 failed (¿CDN UI5 bloqueado? ver salida)."; $fail = 1 }
  }
}
finally {
  Write-Output "== cleanup =="
  # El PID guardado puede haber muerto dejando huérfanos (cmd→npx→node):
  # se mata por identidad — cmdline con NUESTRO puerto + creación
  # posterior al arranque del runner. Nunca por nombre desnudo.
  $own = @()
  foreach ($proc in @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object {
    ($_.Name -eq "node.exe" -or $_.Name -eq "cmd.exe") -and
    $_.CommandLine -like "*cds serve*--port $Port*"
  })) {
    try {
      $born = [Management.ManagementDateTimeConverter]::ToDateTime($proc.CreationDate)
      if ($born -gt $RunStart) { $own += $proc.ProcessId }
    } catch {}
  }
  if ($CapPid -and ($own -notcontains $CapPid)) { $own += @($CapPid) }
  foreach ($id in $own) {
    if (Get-Process -Id $id -ErrorAction SilentlyContinue) {
      Start-Process -FilePath "taskkill" -ArgumentList "/pid", $id, "/t", "/f" -WindowStyle Hidden -Wait
      Write-Output "CAP propio PID $id detenido (por identidad)."
    }
  }
  if ($own.Count -eq 0) { Write-Output "CAP propio ya ausente (nada que matar)." }
  powershell -ExecutionPolicy Bypass -File $Cdp cleanup -Port $CdpPort
  # El veredicto del script CDP puede ser INCOMPLETA por TimeWaits propios
  # (PID 0, rechazan conexión): la verificación que manda es el connect.
  if (Test-PortFree $CdpPort) { Write-Output "Puerto CDP $CdpPort libre verificado." }
  else { Write-Output "AVISO: puerto CDP $CdpPort aún ocupado tras cleanup."; $fail = 1 }
  if (Test-PortFree $Port) { Write-Output "Puerto $Port libre verificado." }
  else { Write-Output "AVISO: puerto $Port aún ocupado tras cleanup."; $fail = 1 }
}

if ($fail -eq 0) { Write-Output "VERDE: HTTP + QUnit unit + OPA5 journey." }
else { Write-Output "ROJO: ver fallos arriba." }
exit $fail
