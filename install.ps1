<# Instalador del harness BTP (idempotente, PowerShell 5.1).
   Uso: .\install.ps1 [-Dest "."] [-Force] [-Client auto]
   - Copia AI/ al proyecto destino (SKIP si ya existe; con -Force hace backup a AI.bak).
   - Fusiona el árbol del cliente agéntico desde AI/clients/<cliente>/ en la raíz
     (solo faltantes; con -Force hace backup a <dir>.bak):
     -Client auto (defecto): detecta por huellas (CLAUDE.md|.claude→claude,
     .cursor→cursor, .github→copilot, opencode.json*|.opencode→opencode;
     sin huellas→opencode) | all: todos | lista explícita (p. ej. claude,copilot).
   - Crea AGENTS.md raíz desde la plantilla solo si no existe.
   - Fusiona .gitignore con las líneas del fragmento (solo agrega faltantes).
   - NO toca package.json ni mta.yaml del proyecto. Sin secretos. #>
param(
  [string]$Dest = ".",
  [switch]$Force,
  $Client = "auto"
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

$ClientsSrc = Join-Path $AiSrc "clients"

function Get-ClientList($Spec, $DestDir) {
  $s = (($Spec -join ",") + "").Trim().ToLower()
  if ($s -eq "auto") {
    $d = @()
    if ((Test-Path (Join-Path $DestDir "CLAUDE.md")) -or (Test-Path (Join-Path $DestDir ".claude"))) { $d += "claude" }
    if (Test-Path (Join-Path $DestDir ".cursor")) { $d += "cursor" }
    if (Test-Path (Join-Path $DestDir ".github")) { $d += "copilot" }
    $opHints = @(Get-ChildItem $DestDir -Filter "opencode.json*" -File -ErrorAction SilentlyContinue)
    if (($opHints.Count -gt 0) -or (Test-Path (Join-Path $DestDir ".opencode"))) { $d += "opencode" }
    if ($d.Count -eq 0) { $d = @("opencode") }
    return $d
  }
  if ($s -eq "all") { return @("opencode", "claude", "cursor", "copilot") }
  $list = @($s -split "," | ForEach-Object { $_.Trim().ToLower() } | Where-Object { $_ -ne "" })
  $known = @("opencode", "claude", "cursor", "copilot", "aider")
  foreach ($c in $list) {
    if ($known -notcontains $c) { Write-Host "ABORT: cliente desconocido '$c' (usa auto|all|opencode,claude,cursor,copilot,aider)"; exit 1 }
  }
  if ($list.Count -eq 0) { Write-Host "ABORT: -Client vacío (usa auto|all|opencode,claude,cursor,copilot,aider)"; exit 1 }
  return $list
}

function Merge-Tree($TreeSrc, $TreeDst, $Label) {
  if (-not (Test-Path $TreeSrc)) { Write-Output "AVISO: no existe $TreeSrc (regenera con node scripts/render-clients.js)"; return }
  $BakLabel = $Label.TrimEnd("/") + ".bak"
  if ($Force) {
    if (Test-Path $TreeDst) {
      $Bak = "$TreeDst.bak"
      if (Test-Path $Bak) { Remove-Item $Bak -Recurse -Force }
      Rename-Item $TreeDst ([IO.Path]::GetFileName($Bak))
      Write-Output "BACKUP: $Label -> $BakLabel"
    }
    Copy-Item $TreeSrc $TreeDst -Recurse -Force
    $TreeCount = @(Get-ChildItem $TreeDst -Recurse -File).Count
    Write-Output ("CREATE: {0} (+{1} archivos)" -f $Label, $TreeCount)
  } else {
    $TreeCount = 0
    $TreeFiles = @(Get-ChildItem $TreeSrc -Recurse -File)
    foreach ($f in $TreeFiles) {
      $rel = $f.FullName.Substring($TreeSrc.Length + 1)
      $tgt = Join-Path $TreeDst $rel
      if (Test-Path $tgt) {
        Write-Output ("SKIP: {0}{1} ya existe" -f $Label, ($rel -replace "\\","/"))
      } else {
        $tgtDir = Split-Path -Parent $tgt
        if (-not (Test-Path $tgtDir)) { New-Item $tgtDir -ItemType Directory -Force | Out-Null }
        Copy-Item $f.FullName $tgt -Force
        $TreeCount++
      }
    }
    Write-Output ("CREATE: {0} (+{1} archivos)" -f $Label, $TreeCount)
  }
}

$SelectedClients = @(Get-ClientList $Client $Dest)
if ((($Client -join ",") + "").Trim().ToLower() -eq "auto") {
  Write-Output ("CLIENT: auto -> {0}" -f ($SelectedClients -join ","))
}
foreach ($c in $SelectedClients) {
  if ($c -eq "opencode") {
    Merge-Tree (Join-Path $ClientsSrc "opencode") (Join-Path $Dest ".opencode") ".opencode/"
  } elseif ($c -eq "claude") {
    Merge-Tree (Join-Path $ClientsSrc "claude") (Join-Path $Dest ".claude") ".claude/"
  } elseif ($c -eq "cursor") {
    Merge-Tree (Join-Path $ClientsSrc "cursor\commands") (Join-Path $Dest ".cursor\commands") ".cursor/commands/"
    Merge-Tree (Join-Path $ClientsSrc "cursor\skills") (Join-Path $Dest ".agents\skills") ".agents/skills/"
  } elseif ($c -eq "copilot") {
    Merge-Tree (Join-Path $ClientsSrc "copilot\agents") (Join-Path $Dest ".github\agents") ".github/agents/"
    Merge-Tree (Join-Path $ClientsSrc "copilot\skills") (Join-Path $Dest ".github\skills") ".github/skills/"
    Merge-Tree (Join-Path $ClientsSrc "copilot\prompts") (Join-Path $Dest ".github\prompts") ".github/prompts/"
  } elseif ($c -eq "aider") {
    Write-Output "SKIP: aider usa AGENTS.md raiz (nada que fusionar)"
  }
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
