<# Instalador del harness BTP (idempotente, PowerShell 5.1).
   Uso: .\install.ps1 [-Dest "."] [-Force]
   - Copia AI/ al proyecto destino (SKIP si ya existe; con -Force hace backup a AI.bak).
   - Crea AGENTS.md raíz desde la plantilla solo si no existe.
   - Fusiona .gitignore con las líneas del fragmento (solo agrega faltantes).
   - NO toca package.json ni mta.yaml del proyecto. Sin secretos. #>
param(
  [string]$Dest = ".",
  [switch]$Force
)

$ErrorActionPreference = "Stop"
$Src = Split-Path -Parent $MyInvocation.MyCommand.Path
$AiSrc = Join-Path $Src "AI"
$TplPointer = Join-Path $Src "templates\AGENTS.pointer.md"

if (-not (Test-Path $AiSrc)) { Write-Output "ABORT: no se encontró AI/ junto a install.ps1"; exit 1 }

$AiDst = Join-Path $Dest "AI"
if (Test-Path $AiDst) {
  if ($Force) {
    $Bak = Join-Path $Dest "AI.bak"
    if (Test-Path $Bak) { Remove-Item $Bak -Recurse -Force }
    Rename-Item $AiDst "AI.bak"
    Write-Output "BACKUP: AI/ -> AI.bak"
    Copy-Item $AiSrc $AiDst -Recurse -Force
    Write-Output "CREATE: AI/ (reinstalado con -Force)"
  } else {
    Write-Output "SKIP: AI/ ya existe (usa -Force para reinstalar con backup .bak)"
  }
} else {
  Copy-Item $AiSrc $AiDst -Recurse -Force
  Write-Output "CREATE: AI/"
}

$AgentsDst = Join-Path $Dest "AGENTS.md"
if (Test-Path $AgentsDst) {
  Write-Output "SKIP: AGENTS.md ya existe"
} else {
  Copy-Item $TplPointer $AgentsDst -Force
  Write-Output "CREATE: AGENTS.md (puntero a AI/AGENTS.md)"
}

$Frag = Join-Path $AiSrc ".gitignore.fragment"
$GiDst = Join-Path $Dest ".gitignore"
$lines = Get-Content $Frag | Where-Object { $_.Trim() -ne "" -and -not $_.Trim().StartsWith("#") }
if (Test-Path $GiDst) {
  $cur = Get-Content $GiDst
  $added = 0
  foreach ($l in $lines) {
    if ($cur -notcontains $l) { Add-Content $GiDst $l; $added++ }
  }
  if ($added -eq 0) { Write-Output "SKIP: .gitignore ya contiene el fragmento" }
  else { Write-Output ("CREATE: .gitignore (+{0} líneas)" -f $added) }
} else {
  $lines | Set-Content $GiDst
  Write-Output "CREATE: .gitignore"
}

Write-Output "OK: harness instalado en $Dest (package.json y mta.yaml intactos)"
