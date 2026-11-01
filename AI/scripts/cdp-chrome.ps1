<#
.SYNOPSIS
  Gestiona el host CDP (Chrome headless) para pruebas con navegador.
  El MCP `playwright` solo se CONECTA a http://localhost:9222: no lanza
  ningun navegador. Este script es el unico medio autorizado para
  levantar ese endpoint en este proyecto.

.DESCRIPTION
  Modos:
    status  - informa si el puerto responde y si hay procesos propios vivos.
    ensure  - garantiza un endpoint CDP operativo (reutiliza el existente
              si responde; si el puerto lo ocupa un proceso AJENO, se detiene
              sin matarlo e informa; si esta libre, lanza Chrome propio).
    cleanup - mata SOLO los procesos Chrome lanzados por este script
              (verificados por PID + linea de comandos con el perfil propio),
              borra el perfil temporal y verifica que el puerto quede libre.

  Regla irrestricta (AGENTS.md, Higiene obligatoria de navegador y CDP):
  `ensure` antes de cada sesion de pruebas con navegador, `cleanup` al
  terminarla. Sin limpieza verificada no se cierra la tarea.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File scripts/cdp-chrome.ps1 ensure
  powershell -ExecutionPolicy Bypass -File scripts/cdp-chrome.ps1 cleanup
#>
[CmdletBinding()]
param(
  [Parameter(Position = 0)]
  [ValidateSet("status", "ensure", "cleanup")]
  [string]$Mode = "status",
  [int]$Port = 9222
)

$ErrorActionPreference = "Stop"
$ProfileDir = Join-Path $env:TEMP "mvp-cdp-$Port"
$PidFile = Join-Path $ProfileDir "owner.json"
$Endpoint = "http://localhost:$Port/json/version"

function Get-Listener {
  Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue |
    Select-Object -First 1
}

function Test-Endpoint {
  try {
    $r = curl.exe -s -m 5 $Endpoint 2>$null
    return ($LASTEXITCODE -eq 0 -and $r -match "webSocketDebuggerUrl")
  } catch { return $false }
}

function Get-OwnPids {
  $list = @()
  if (Test-Path $PidFile) {
    try {
      $json = Get-Content $PidFile -Raw | ConvertFrom-Json
      foreach ($x in @($json)) { $list += [int]$x }
    } catch {}
  }
  return $list
}

function Test-OwnProcess([int]$ProcId) {
  $p = Get-Process -Id $ProcId -ErrorAction SilentlyContinue
  if (-not $p -or $p.ProcessName -ne "chrome") { return $false }
  $cmd = (Get-CimInstance Win32_Process -Filter "ProcessId = $ProcId" -ErrorAction SilentlyContinue).CommandLine
  return ($cmd -and $cmd.Contains($ProfileDir))
}

function Get-OwnAlive {
  $alive = @()
  foreach ($id in Get-OwnPids) {
    if (Test-OwnProcess $id) { $alive += $id }
  }
  return $alive
}

if ($Mode -eq "status") {
  $listener = Get-Listener
  if ($listener) {
    $proc = Get-Process -Id $listener.OwningProcess -ErrorAction SilentlyContinue
    Write-Output "PUERTO ${Port}: ocupado por PID $($listener.OwningProcess) ($($proc.ProcessName))"
  } else {
    Write-Output "PUERTO ${Port}: libre"
  }
  Write-Output "ENDPOINT: $(if (Test-Endpoint) { 'responde' } else { 'sin respuesta' })"
  $alive = @(Get-OwnAlive)
  Write-Output "PROPIOS VIVOS: $($alive.Count)"
  exit 0
}

if ($Mode -eq "ensure") {
  if (Test-Endpoint) {
    Write-Output "ENDPOINT operativo en ${Endpoint}; no se lanza nada (reutilizacion)."
    exit 0
  }
  $listener = Get-Listener
  if ($listener) {
    $proc = Get-Process -Id $listener.OwningProcess -ErrorAction SilentlyContinue
    Write-Output "DETENIDO: el puerto $Port lo ocupa un proceso ajeno (PID $($listener.OwningProcess), $($proc.ProcessName)). No se mata. Libera el puerto o avisa al usuario."
    exit 1
  }
  $chrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
  if (-not (Test-Path $chrome)) {
    $alt = Join-Path ${env:ProgramFiles(x86)} "Google\Chrome\Application\chrome.exe"
    if (Test-Path $alt) { $chrome = $alt }
    else { Write-Output "DETENIDO: chrome.exe no encontrado."; exit 1 }
  }
  New-Item -ItemType Directory -Force -Path $ProfileDir | Out-Null
  $before = @(Get-Process -Name "chrome" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Id)
  Start-Process -FilePath $chrome -ArgumentList "--headless=new", "--no-first-run",
    "--no-default-browser-check", "--remote-debugging-port=$Port",
    "--user-data-dir=$ProfileDir", "about:blank" -WindowStyle Hidden
  $ok = $false
  foreach ($wait in @(1, 2, 4)) {
    Start-Sleep -Seconds $wait
    if (Test-Endpoint) { $ok = $true; break }
  }
  if (-not $ok) { Write-Output "DETENIDO: Chrome no respondio en ${Endpoint} tras 3 intentos."; exit 1 }
  $after = @(Get-Process -Name "chrome" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Id)
  $mine = @($after | Where-Object { $_ -notin $before })
  $mine | ConvertTo-Json | Set-Content $PidFile
  Write-Output "ENDPOINT operativo en ${Endpoint} (PIDs propios: $($mine -join ','), perfil temporal)."
  exit 0
}

if ($Mode -eq "cleanup") {
  $killed = 0; $skipped = 0
  foreach ($id in Get-OwnPids) {
    if (Test-OwnProcess $id) {
      Stop-Process -Id $id -Force -ErrorAction SilentlyContinue
      $killed++
    } else { $skipped++ }
  }
  Start-Sleep -Seconds 2
  $remaining = @(Get-OwnAlive)
  if ($remaining.Count -eq 0 -and (Test-Path $ProfileDir)) {
    Remove-Item -Recurse -Force $ProfileDir -ErrorAction SilentlyContinue
  }
  $listener = Get-Listener
  if ($remaining.Count -eq 0 -and -not $listener -and -not (Test-Endpoint)) {
    Write-Output "LIMPIEZA OK: $killed proceso(s) propio(s) detenido(s), $skipped ya ausente(s)/ajeno(s) intacto(s), puerto $Port libre."
    exit 0
  }
  Write-Output "LIMPIEZA INCOMPLETA: propios vivos=$($remaining.Count) (PIDs: $($remaining -join ',')), puerto libre=$( -not $listener). Revisar manual."
  exit 1
}
