<#
.SYNOPSIS
  Broker determinista para Cloud Foundry: unico punto de salida hacia cf.
  Fail-closed: denylist primero, luego allowlist, luego validacion de target.

.DESCRIPTION
  Orden de evaluacion (nada ejecuta antes de pasarla):
    1. Binario: `cf` (CLI estandar de Cloud Foundry, resuelto en PATH).
    2. Denylist -> exit 1: delete-*, unbind-*, purge-*, restage-*, set-env sin
       -AllowWrite, create-service-key directo, service-key con valores sin
       -NeedValues (y sin -AllowWrite), inyeccion (| > ; ` $()).
    3. Allowlist -> exit 2 si el verbo no esta listado.
       Lectura (sin flags): target, apps, app, services, service, marketplace,
       spaces, space-users, service-keys (solo nombres), env (redactado),
       logs --recent (redactado, 200 lineas), plugins.
       Escritura (SOLO con -AllowWrite): create-space, create-service,
       set-space-role, target -o/-s, set-env, service-key con valores
       (ademas exige -NeedValues).
    4. Validacion de target -> exit 3 si endpoint/org no coinciden
       (ExpectedOrg vacio = no valida org). Se omite con -WhatIf.
    5. Ejecucion -> exit 4 si falla el proceso.

  Salida: UNA linea JSON:
    {ok,exit,verb,redacted,rawLog,names,output}
  output va redactado y truncado a 4000 caracteres. El crudo SOLO se escribe
  en temp/cf-safe/*.raw.log, nunca a stdout.

  Codigos: 0 ok / 1 deny-denylist / 2 fuera-de-allowlist /
             3 validacion-target / 4 error-ejecucion.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File scripts/cf-safe.ps1 -CfArgs @('services')
  powershell -ExecutionPolicy Bypass -File scripts/cf-safe.ps1 -CfArgs @('services') -WhatIf
  powershell -ExecutionPolicy Bypass -File scripts/cf-safe.ps1 -CfArgs services
  powershell -ExecutionPolicy Bypass -File scripts/cf-safe.ps1 services
  # `--` solo via -Command (-File lo rechaza a nivel de motor):
  powershell -ExecutionPolicy Bypass -Command "& scripts/cf-safe.ps1 -- delete-service X"
#>
[CmdletBinding()]
param(
  # CfArgs recoge el verbo+args. CfRest existe porque -File (PowerShell 5.1)
  # ignora ValueFromRemainingArguments: `-CfArgs delete-service X` dejaria
  # 'X' sin enlazar (PositionalParameterNotFound). Con Position=1, 'X' cae
  # en CfRest y se fusiona. `--` inicial se descarta (separador end-of-params).
  [Parameter(Position = 0)][string[]]$CfArgs = @(),
  [Parameter(Position = 1)][string[]]$CfRest = @(),
  [string]$ExpectedApi = 'https://api.cf.us10-001.hana.ondemand.com',
  [string]$ExpectedOrg = '',
  [switch]$AllowWrite,
  [switch]$PassThru,
  [switch]$WhatIf,
  [string]$CfBinary = 'cf',
  [switch]$NeedValues
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'cf-safe-patterns.ps1')

# Fusion -File: named (-CfArgs a) + posicionales sueltos (b c) o todo
# posicional (script.ps1 a b c). Descarta `--` inicial si lo hay.
$CfArgs = @($CfArgs) + @($CfRest)
if ($CfArgs.Count -gt 0 -and $CfArgs[0] -eq '--') {
  $CfArgs = @($CfArgs | Select-Object -Skip 1)
}

$CfCmd = (Get-Command cf -ErrorAction SilentlyContinue).Source
$TempDir = Join-Path (Split-Path $PSScriptRoot -Parent) 'temp\cf-safe'
$MaxOutput = 4000
$MaxLogLines = 200

function Emit-Result {
  param([bool]$Ok, [int]$Code, [string]$Verb, [bool]$WasRedacted, [string]$RawLog, [array]$Names, [string]$Text)
  $t = if ($null -eq $Text) { '' } else { $Text }
  if ($t.Length -gt $MaxOutput) { $t = $t.Substring(0, $MaxOutput) }
  $obj = [ordered]@{
    ok       = $Ok
    exit     = $Code
    verb     = $Verb
    redacted = $WasRedacted
    rawLog   = $RawLog
    names    = @(if ($null -eq $Names) { @() } else { $Names })
    output   = $t
  }
  $line = ($obj | ConvertTo-Json -Compress -Depth 4)
  Write-Output $line
  if ($PassThru -and $t) { Write-Output $t }
}

$verb = if ($CfArgs.Count -gt 0) { [string]$CfArgs[0] } else { '' }
$verbNorm = $verb.ToLowerInvariant()
$joined = ($CfArgs -join ' ')

# 1. Binario: solo `cf` (resuelto en PATH).
$binNorm = ([string]$CfBinary).ToLowerInvariant()
$binOk = ($binNorm -eq 'cf' -or $binNorm -eq 'cf.exe')
if (-not $binOk) {
  Emit-Result -Ok $false -Code 1 -Verb $verb -WasRedacted $false -RawLog '' -Names @() -Text "DENY: binario no autorizado [$CfBinary]. Solo cf."
  exit 1
}
if (-not $CfCmd) {
  Emit-Result -Ok $false -Code 4 -Verb $verb -WasRedacted $false -RawLog '' -Names @() -Text 'ERROR: cf no encontrado en PATH.'
  exit 4
}

# 2. Denylist primero (fail-closed). Ninguna de estas ramas ejecuta nada.
$hasValues = ($joined -match '(?i)(?:-p\s+|--parameters\s+|\{[^{}]*"[^{}]*\})')
$denyReason = $null
if ($verbNorm -match '^(delete|unbind|purge|restage)(-|$)') {
  $denyReason = "DENY: verbo destructivo [$verb] fuera de allowlist cerrada."
} elseif ($verbNorm -eq 'set-env' -and -not $AllowWrite) {
  $denyReason = 'DENY: set-env exige -AllowWrite explicito (confirmado).'
} elseif ($verbNorm -eq 'create-service-key' -or $verbNorm -eq 'create-key') {
  $denyReason = 'DENY: create-service-key directo prohibido; usa New-TempServiceKey (cf-safe-client).'
} elseif (($verbNorm -eq 'service-key' -or $verbNorm -eq 'service-keys') -and $hasValues -and (-not $AllowWrite -or -not $NeedValues)) {
  $denyReason = 'DENY: service-key con valores exige -AllowWrite y -NeedValues.'
} elseif ($joined -match '\||>|;|`|\$\(') {
  $denyReason = 'DENY: posible inyeccion en argumentos (| > ; ` $()).'
}
if ($denyReason) {
  Emit-Result -Ok $false -Code 1 -Verb $verb -WasRedacted $false -RawLog '' -Names @() -Text $denyReason
  exit 1
}

# 3. Allowlist.
$readVerbs = @('target', 'apps', 'app', 'services', 'service', 'marketplace', 'spaces', 'space-users', 'service-keys', 'service-key', 'env', 'logs', 'plugins')
$writeVerbs = @('create-space', 'create-service', 'set-space-role', 'set-env')
$isWrite = $writeVerbs -contains $verbNorm
$isTargetSwitch = ($verbNorm -eq 'target' -and $joined -match '(?i)\s-(o|s)\s')
if ($isTargetSwitch) { $isWrite = $true }
if ($verbNorm -eq 'service-key' -and $hasValues) { $isWrite = $true }
$allowed = ($readVerbs -contains $verbNorm) -or ($isWrite -and $AllowWrite)
if (-not $allowed) {
  if ($isWrite) {
    Emit-Result -Ok $false -Code 2 -Verb $verb -WasRedacted $false -RawLog '' -Names @() -Text "FUERA DE ALLOWLIST: [$verb] es escritura y falta -AllowWrite."
  } else {
    Emit-Result -Ok $false -Code 2 -Verb $verb -WasRedacted $false -RawLog '' -Names @() -Text "FUERA DE ALLOWLIST: [$verb] no listado."
  }
  exit 2
}
# Reglas finas de allowlist.
if ($verbNorm -eq 'logs' -and $joined -notmatch '(?i)--recent') {
  Emit-Result -Ok $false -Code 2 -Verb $verb -WasRedacted $false -RawLog '' -Names @() -Text 'FUERA DE ALLOWLIST: logs solo con --recent.'
  exit 2
}

# Modo WhatIf: no toca red ni ejecuta; util para tests offline.
if ($WhatIf) {
  $preview = Redact-Secrets ("WHATIF: cf " + $joined)
  Emit-Result -Ok $true -Code 0 -Verb $verb -WasRedacted ($preview -ne ("WHATIF: cf " + $joined)) -RawLog '' -Names @() -Text $preview
  exit 0
}
if ($CfArgs.Count -eq 0) {
  Emit-Result -Ok $false -Code 2 -Verb '' -WasRedacted $false -RawLog '' -Names @() -Text 'FUERA DE ALLOWLIST: sin argumentos.'
  exit 2
}

# 4. Validacion de target (endpoint siempre; org solo si ExpectedOrg no vacio).
try {
  $tRaw = & $CfCmd target 2>&1 | Out-String
  if ($tRaw -notmatch [regex]::Escape($ExpectedApi)) {
    Emit-Result -Ok $false -Code 3 -Verb $verb -WasRedacted $true -RawLog '' -Names @() -Text (Redact-Secrets ('TARGET MISMATCH: endpoint no coincide con ' + $ExpectedApi))
    exit 3
  }
  if ($ExpectedOrg -ne '' -and ($tRaw -notmatch [regex]::Escape($ExpectedOrg))) {
    Emit-Result -Ok $false -Code 3 -Verb $verb -WasRedacted $true -RawLog '' -Names @() -Text (Redact-Secrets ('TARGET MISMATCH: org no coincide con ' + $ExpectedOrg))
    exit 3
  }
} catch {
  Emit-Result -Ok $false -Code 4 -Verb $verb -WasRedacted $false -RawLog '' -Names @() -Text 'ERROR: no se pudo verificar target.'
  exit 4
}

# 5. Ejecucion. El crudo va a temp/cf-safe/*.raw.log; a stdout solo redactado.
New-Item -ItemType Directory -Force -Path $TempDir | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$rawLog = Join-Path $TempDir ("cf-" + $stamp + "-PID" + $PID + ".raw.log")
try {
  $raw = & $CfCmd @CfArgs 2>&1 | Out-String
  $code = $LASTEXITCODE
} catch {
  Emit-Result -Ok $false -Code 4 -Verb $verb -WasRedacted $false -RawLog '' -Names @() -Text 'ERROR: fallo al invocar cf.'
  exit 4
}
try { Set-Content -Path $rawLog -Value $raw -Encoding UTF8 } catch { $rawLog = '' }

if ($code -ne 0) {
  Emit-Result -Ok $false -Code 4 -Verb $verb -WasRedacted $true -RawLog $rawLog -Names @() -Text (Redact-Secrets $raw)
  exit 4
}

$redactedOut = Redact-Secrets $raw
$wasRedacted = ($redactedOut -ne $raw)
$names = @()
if ($verbNorm -eq 'service-keys' -or $verbNorm -eq 'service-key') {
  # Solo nombres: primera columna de lineas de tabla (sin cabeceras).
  $lines = $redactedOut -split "`r?`n" | Where-Object { $_.Trim() -ne '' }
  $lines = $lines | Where-Object { $_ -notmatch '(?i)^name\s' -and $_ -notmatch '(?i)^getting|^\s*$|FAILED|OK' }
  foreach ($ln in $lines) {
    $tok = ($ln.Trim() -split '\s+')[0]
    if ($tok -and $tok -ne $RedactMarker) { $names += $tok }
  }
  if ($names.Count -gt 0) { $redactedOut = ($names -join [Environment]::NewLine); $wasRedacted = $true }
}
if ($verbNorm -eq 'logs') {
  $ll = $redactedOut -split "`r?`n"
  if ($ll.Count -gt $MaxLogLines) { $redactedOut = ($ll | Select-Object -Last $MaxLogLines) -join [Environment]::NewLine; $wasRedacted = $true }
}
Emit-Result -Ok $true -Code 0 -Verb $verb -WasRedacted $wasRedacted -RawLog $rawLog -Names $names -Text $redactedOut
exit 0
