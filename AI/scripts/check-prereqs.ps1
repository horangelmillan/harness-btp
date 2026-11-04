<# Verificación de prerrequisitos del harness BTP (PowerShell 5.1).
   Uso:
     powershell -ExecutionPolicy Bypass -File AI/scripts/check-prereqs.ps1 [-WarnOnly] [-NeedMtar] [-NeedJava] [-NeedCds] [-NeedUi5] [-NeedGh] [-NeedOp]
   - Sin parámetros: comprueba REQUERIDO siempre + OPCIONAL como aviso.
   - -NeedMtar/-NeedJava/-NeedCds/-NeedUi5/-NeedGh/-NeedOp: promocionan ese opcional a
     REQUERIDO (usar cuando la spec del MVP lo exija; -NeedCds no promociona ui5).
   - -WarnOnly: nunca falla (exit 0); lo usan install.ps1/install.sh al final.
   NUNCA imprime secretos: solo ejecuta "<comando> --version" y cuenta archivos.
   REQUERIDO faltante -> exit 1 (salvo -WarnOnly). Solo opcionales -> exit 0. #>
param(
  [switch]$WarnOnly,
  [switch]$NeedMtar,
  [switch]$NeedJava,
  [switch]$NeedCds,
  [switch]$NeedUi5,
  [switch]$NeedGh,
  [switch]$NeedOp
)

$ErrorActionPreference = "Continue"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$HarnessRoot = Split-Path -Parent (Split-Path -Parent $ScriptDir)

$rows = New-Object System.Collections.ArrayList
function Add-Row($tool, $need, $level, $state, $detail, $url) {
  [void]$rows.Add([pscustomobject]@{
    Herramienta = $tool; NecesariaPara = $need; Nivel = $level
    Estado = $state; Detalle = $detail; Instalacion = $url
  })
}

function Test-Tool($name, $versionArgs) {
  try {
    $cmd = Get-Command $name -ErrorAction Stop
    try {
      $out = & $cmd.Source @versionArgs 2>&1 | Select-Object -First 1
      if ($out) { $out = "$out".Trim() } else { $out = "instalado" }
    } catch { $out = "instalado (version no legible)" }
    return @{ Found = $true; Detail = $out }
  } catch { return @{ Found = $false; Detail = "no encontrado en PATH" } }
}

# --- REQUERIDO siempre ---
$r = Test-Tool "git" @("--version")
Add-Row "git" "control de versiones del MVP" "REQ" $(if ($r.Found) { "OK" } else { "FALTA" }) $r.Detail "https://git-scm.com/downloads"

$node = Test-Tool "node" @("--version")
$nodeOk = $false
if ($node.Found) {
  try {
    $m = [regex]::Match($node.Detail, "v?(\d+)\.")
    if ($m.Success -and [int]$m.Groups[1].Value -ge 18) { $nodeOk = $true }
    else { $node.Detail = "$($node.Detail) (se requiere Node 18+)" }
  } catch { $node.Detail = "$($node.Detail) (no se pudo verificar major >= 18)" }
}
Add-Row "node 18+" "CAP, UI5, mbt, scripts del harness" "REQ" $(if ($nodeOk) { "OK" } else { "FALTA" }) $node.Detail "https://nodejs.org/"

$cfName = "cf"
if ($env:CF_BIN) {
  $cfBase = [System.IO.Path]::GetFileNameWithoutExtension($env:CF_BIN)
  if (@('cf', 'sap_cf') -contains $cfBase.ToLowerInvariant()) { $cfName = $env:CF_BIN }
}
$r = Test-Tool $cfName @("--version")
$cfState = if ($r.Found) { "OK" } else { "FALTA" }
if ($r.Found -and ($r.Detail -notmatch "(?i)cf(\.exe)? version|cloudfoundry")) {
  $r.Detail = "$($r.Detail) (AVISO: no parece el CLI de Cloud Foundry; si 'cf' es otra herramienta, define `$env:CF_BIN al CLI real (mapeo en ~/.harness/local.ps1, ver skill cf-cli))"
  $cfState = "FALTA"
}
Add-Row "cf" "despliegues y lecturas Cloud Foundry" "REQ" $cfState $r.Detail "https://docs.cloudfoundry.org/cf-cli/install-go-cli.html"

$agentsOk = (Test-Path (Join-Path $HarnessRoot "AI\AGENTS.md")) -and ((Test-Path (Join-Path $HarnessRoot "AGENTS.md")) -or (Test-Path (Join-Path $HarnessRoot "templates\AGENTS.pointer.md")))
Add-Row "cliente agentico" "leer AGENTS.md y orquestar el flujo" "REQ" $(if ($agentsOk) { "OK" } else { "FALTA" }) $(if ($agentsOk) { "AGENTS.md + AI/AGENTS.md presentes; verifica que tu cliente los lea" } else { "falta AGENTS.md o AI/AGENTS.md (reinstala con install.ps1)" }) "https://docs.opencode.ai/ (o tu cliente agéntico)"

# --- OPCIONAL según MVP (promocionable con -Need*) ---
function Opt-Level($flag) { if ($flag) { "REQ" } else { "OPT" } }

$r = Test-Tool "mbt" @("--version")
Add-Row "mbt" "construir MTAR (solo si el MVP lo exige)" (Opt-Level $NeedMtar) $(if ($r.Found) { "OK" } else { "FALTA" }) $r.Detail "https://github.com/SAP/cloud-mta-build-tool"

$r = Test-Tool "make" @("--version")
Add-Row "make" "requerido por mbt en el SO" $(if ($NeedMtar) { "REQ" } else { "OPT" }) $(if ($r.Found) { "OK" } else { "FALTA" }) $r.Detail "https://www.gnu.org/software/make/"

$r = Test-Tool "java" @("-version")
Add-Row "java" "builds MTA Java (solo si la spec los pide)" (Opt-Level $NeedJava) $(if ($r.Found) { "OK" } else { "FALTA" }) $r.Detail "https://adoptium.net/"

$r = Test-Tool "cds" @("--version")
if ($r.Found) {
  $r.Detail = "$($r.Detail) (global; el harness usa npx -p @sap/cds-dk cds)"
} elseif ((Test-Tool "npx" @("--version")).Found) {
  $r = @{ Found = $true; Detail = "valido via npx -p @sap/cds-dk cds (sin instalacion global)" }
} else {
  $r.Detail = "no global ni npx; valido via npx -p @sap/cds-dk (solo si la spec exige CAP)"
}
Add-Row "cds" "proyectos CAP (solo si la spec lo exige)" (Opt-Level $NeedCds) $(if ($r.Found) { "OK" } else { "FALTA" }) $r.Detail "https://cap.cloud.sap/docs/get-started/"

$r = Test-Tool "ui5" @("--version")
Add-Row "ui5" "proyectos UI5/Fiori (solo si la spec lo exige)" (Opt-Level $NeedUi5) $(if ($r.Found) { "OK" } else { "FALTA" }) $r.Detail "https://ui5.github.io/cli/"

$r = Test-Tool "gh" @("--version")
Add-Row "gh" "repo remoto/PR (solo si la spec pide remoto)" (Opt-Level $NeedGh) $(if ($r.Found) { "OK" } else { "FALTA" }) $r.Detail "https://cli.github.com/"

$r = Test-Tool "op" @("--version")
Add-Row "op (1Password)" "secretos de equipo (solo si el equipo lo adopta)" (Opt-Level $NeedOp) $(if ($r.Found) { "OK" } else { "FALTA" }) $r.Detail "https://developer.1password.com/docs/cli/get-started/"

# --- Harness: skills, agentes, fragmento MCP (presencia de archivos) ---
$skills = @()
$skillsDir = Join-Path $HarnessRoot "AI\.opencode\skills"
if (Test-Path $skillsDir) { $skills = Get-ChildItem $skillsDir -Directory | Where-Object { Test-Path (Join-Path $_.FullName "SKILL.md") } }
Add-Row "skills" "capacidades del harness (cf-cli, mta-build, ...)" "OPT" $(if ($skills.Count -gt 0) { "OK" } else { "FALTA" }) "$($skills.Count) skills con SKILL.md" "(vienen con AI/; reinstala con install.ps1 si FALTA)"

$agents = @()
$agentsDir = Join-Path $HarnessRoot "AI\.opencode\agents"
if (Test-Path $agentsDir) { $agents = Get-ChildItem $agentsDir -Filter "*.md" }
Add-Row "agents" "orquestador y especialistas" "OPT" $(if ($agents.Count -gt 0) { "OK" } else { "FALTA" }) "$($agents.Count) agentes .md" "(vienen con AI/; reinstala con install.ps1 si FALTA)"

$frag = Test-Path (Join-Path $HarnessRoot "AI\opencode.fragment.jsonc")
Add-Row "fragmento MCP" "plantilla MCP del proyecto destino" "OPT" $(if ($frag) { "OK" } else { "FALTA" }) $(if ($frag) { "AI/opencode.fragment.jsonc presente" } else { "no encontrado" }) "(viene con AI/; reinstala con install.ps1 si FALTA)"

# --- Tabla ---
Write-Output ""
Write-Output "Prerrequisitos del harness BTP (harness: $HarnessRoot)"
Write-Output ("{0,-14} | {1,-42} | {2,-5} | {3,-6} | {4}" -f "Herramienta", "Necesaria para", "Nivel", "Estado", "Detalle / Instalacion")
$rows | ForEach-Object {
  Write-Output ("{0,-14} | {1,-42} | {2,-5} | {3,-6} | {4} [{5}]" -f $_.Herramienta, $_.NecesariaPara, $_.Nivel, $_.Estado, $_.Detalle, $_.Instalacion)
}
Write-Output ""
Write-Output "NOTA MCPs (no detectables desde shell): tu cliente agentico debe tener configurados"
Write-Output "sus propios MCPs: context7, codebase-memory, github, playwright, eslint, chrome-devtools."
Write-Output "Detalle y docs oficiales: AI/docs/prerequisitos.md"

$reqMissing = @($rows | Where-Object { $_.Nivel -eq "REQ" -and $_.Estado -eq "FALTA" })
$optMissing = @($rows | Where-Object { $_.Nivel -eq "OPT" -and $_.Estado -eq "FALTA" })
if ($reqMissing.Count -gt 0) {
  Write-Output ("RESULTADO: FALTAN {0} REQUERIDOS ({1}). Instala y re-ejecuta este script." -f $reqMissing.Count, (($reqMissing | ForEach-Object { $_.Herramienta }) -join ", "))
  if ($WarnOnly) { exit 0 } else { exit 1 }
} else {
  if ($optMissing.Count -gt 0) {
    Write-Output ("RESULTADO: OK en requeridos. Avisos opcionales ({0}): {1}." -f $optMissing.Count, (($optMissing | ForEach-Object { $_.Herramienta }) -join ", "))
  } else { Write-Output "RESULTADO: todo OK (requeridos + opcionales presentes)." }
  exit 0
}
