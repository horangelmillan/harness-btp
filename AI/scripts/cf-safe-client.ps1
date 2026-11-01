<#
.SYNOPSIS
  Cliente del broker cf-safe.ps1 para scripts de provision.
  Sin tildes (PS5.1 + UTF8). Cero secretos: solo nombres.

.DESCRIPTION
  Invoke-SapCfSeguro llama al broker y devuelve .output (redactado);
  lanza excepcion si exit != 0. Acepta -AllowWrite / -NeedValues /
  -ExpectedApi / -ExpectedOrg y los pasa al broker.
  New-TempServiceKey es SOLO esqueleto en este turno: no ejecuta
  create/delete real (bloqueado por diseno hasta orden explicita).
#>
$ErrorActionPreference = 'Stop'
$CfSafeBroker = Join-Path $PSScriptRoot 'cf-safe.ps1'

function Invoke-SapCfSeguro {
  param(
    [Parameter(Mandatory = $true)][string[]]$CfArgs,
    [string]$ExpectedApi = 'https://api.cf.us10-001.hana.ondemand.com',
    [string]$ExpectedOrg = '',
    [switch]$AllowWrite,
    [switch]$NeedValues
  )
  $args = @('-ExecutionPolicy', 'Bypass', '-File', $CfSafeBroker, '-CfArgs') + $CfArgs
  if ($ExpectedApi -ne '') { $args += @('-ExpectedApi', $ExpectedApi) }
  if ($ExpectedOrg -ne '') { $args += @('-ExpectedOrg', $ExpectedOrg) }
  if ($AllowWrite) { $args += '-AllowWrite' }
  if ($NeedValues) { $args += '-NeedValues' }
  $jsonLine = & powershell.exe @args 2>&1 | Select-Object -First 1 | Out-String
  $jsonLine = $jsonLine.Trim()
  $res = $null
  try {
    $res = $jsonLine | ConvertFrom-Json
  } catch {
    throw "cf-safe: respuesta no JSON del broker: $jsonLine"
  }
  if ($null -eq $res -or $res.exit -ne 0) {
    $msg = if ($res -and $res.output) { $res.output } else { $jsonLine }
    throw "cf-safe: bloqueado o fallo (exit=$($res.exit), verb=$($res.verb)): $msg"
  }
  return $res.output
}

function New-TempServiceKey {
  # ESQUELETO (sin efecto en este turno): crea una service-key temporal,
  # ejecuta $UseKey, y la borra en finally. BLOQUEADO hasta diseno final
  # de placeholders/keys temporales (requiere orden explicita).
  param(
    [Parameter(Mandatory = $true)][string]$Instance,
    [Parameter(Mandatory = $true)][string]$KeyName,
    [Parameter(Mandatory = $true)][scriptblock]$UseKey
  )
  throw 'BLOQUEADO: New-TempServiceKey es esqueleto sin efecto en este turno (no ejecuta create/delete real).'
  # Diseno previsto (no ejecutar aun):
  # try {
  #   Invoke-SapCfSeguro -CfArgs @('create-service-key', $Instance, $KeyName) -AllowWrite
  #   & $UseKey $KeyName
  # } finally {
  #   Invoke-SapCfSeguro -CfArgs @('delete-service-key', $Instance, $KeyName, '-f') -AllowWrite
  # }
}
