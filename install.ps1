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

$HarnessVersion = "desconocida"
$VersionFile = Join-Path $AiSrc "VERSION"
if (Test-Path $VersionFile) { $HarnessVersion = ((Get-Content $VersionFile | Select-Object -First 1) + "").Trim() }
if (-not $HarnessVersion) { $HarnessVersion = "desconocida" }

$AiDst = Join-Path $Dest "AI"
if (Test-Path $AiDst) {
  if ($Force) {
    $OldVersion = "desconocida"
    $DstVersionFile = Join-Path $AiDst "VERSION"
    if (Test-Path $DstVersionFile) { $OldVersion = ((Get-Content $DstVersionFile | Select-Object -First 1) + "").Trim() }
    if (-not $OldVersion) { $OldVersion = "desconocida" }
    $Bak = Join-Path $Dest "AI.bak"
    if (Test-Path $Bak) { Remove-Item $Bak -Recurse -Force }
    Rename-Item $AiDst "AI.bak"
    Copy-Item $AiSrc $AiDst -Recurse -Force
    Write-Output "BACKUP: AI/ (v$OldVersion) -> AI.bak; CREATE: AI/ (v$HarnessVersion)"
  } else {
    Write-Output "SKIP: AI/ ya existe (usa -Force para reinstalar con backup .bak)"
  }
} else {
  Copy-Item $AiSrc $AiDst -Recurse -Force
  Write-Output "CREATE: AI/ (v$HarnessVersion)"
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

Write-Output "OK: harness v$HarnessVersion instalado en $Dest (package.json y mta.yaml intactos)"

# Verificación de prerrequisitos en modo aviso (no bloquea la instalación).
try {
  $Check = Join-Path $AiSrc "scripts\check-prereqs.ps1"
  if (Test-Path $Check) { & $Check -WarnOnly }
} catch { Write-Output "AVISO: no se pudo ejecutar check-prereqs.ps1 (ver AI/docs/prerequisitos.md)" }
