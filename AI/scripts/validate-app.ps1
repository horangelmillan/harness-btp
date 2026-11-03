<# Validador solo-lectura de apps CAP/UI5/MTA (PowerShell 5.1).
   Uso: powershell -ExecutionPolicy Bypass -File AI/scripts/validate-app.ps1 [-Path .]
   Solo lee archivos y escribe en stdout. Nunca escribe fuera de stdout.
   Exit 0 si ningun FAIL; exit 1 si hay al menos un FAIL.
   Sin secretos, sin Graphify, sin dependencias npm nuevas.
   Formato por check: RESULTADO|ambito|archivo|problema|impacto|fix|auto-fix|evidencia #>
param(
  [string]$Path = "."
)

$ErrorActionPreference = "Continue"
$Target = $Path
if (-not (Test-Path $Target)) {
  Write-Output "FAIL|param|$Target|ruta inexistente|no se puede validar|usa una ruta existente|NO|LOCAL"
  exit 1
}
$Target = (Resolve-Path $Target).Path

$script:HasFail = $false
function Emit($r, $ambito, $archivo, $problema, $impacto, $fix, $auto, $ev) {
  if ($r -eq "FAIL") { $script:HasFail = $true }
  Write-Output ("{0}|{1}|{2}|{3}|{4}|{5}|{6}|{7}" -f $r, $ambito, $archivo, $problema, $impacto, $fix, $auto, $ev)
}
function Read-Text($p) {
  try { return [System.IO.File]::ReadAllText($p) } catch { return "" }
}
function Test-JsonValid($text) {
  # Valida sintaxis JSON sin depender solo de ConvertFrom-Json (PS 5.1 no
  # puede bindear nombres de propiedad vacios, p.ej. "models":{"":...} en
  # manifest.json UI5 -> falso "JSON invalido"). BOM U+FEFF se ignora.
  if ([string]::IsNullOrEmpty($text)) { return $false }
  $s = $text
  if ($s[0] -eq [char]0xFEFF) { $s = $s.Substring(1) }
  try { $null = $s | ConvertFrom-Json -ErrorAction Stop; return $true } catch { }
  try {
    Add-Type -AssemblyName System.Web.Extensions -ErrorAction Stop
    $ser = New-Object System.Web.Script.Serialization.JavaScriptSerializer -ErrorAction Stop
    $ser.MaxJsonLength = 10485760
    $null = $ser.DeserializeObject($s)
    return $true
  } catch { return $false }
}
function Find-Files($rel, $pattern) {
  try { return @(Get-ChildItem -Path (Join-Path $Target $rel) -Filter $pattern -File -Recurse -ErrorAction SilentlyContinue) } catch { return @() }
}

# --- Deteccion de tipo por archivos presentes ---
$pkgPath = Join-Path $Target "package.json"
$pkgText = ""
if (Test-Path $pkgPath) { $pkgText = Read-Text $pkgPath }
$isCap = (Test-Path (Join-Path $Target "srv")) -or ((Find-Files "db" "*.cds").Count -gt 0) -or ($pkgText -match "@sap/cds")
$hdbFiles = @()
$hdbFiles += Find-Files "db" "*.hdb*"
$hdbFiles += Find-Files "." "*.hdbtabledata"
$isHana = ($hdbFiles.Count -gt 0)
$manifestHits = Find-Files "." "manifest.json"
$isUi5 = $false
foreach ($m in $manifestHits) { $t = Read-Text $m.FullName; if ($t -match "sap\.app") { $isUi5 = $true; break } }
$isMta = Test-Path (Join-Path $Target "mta.yaml")
$isApprouter = Test-Path (Join-Path $Target "xs-app.json")
$isXsuaa = Test-Path (Join-Path $Target "xs-security.json")
$typeDesc = @()
if ($isCap) { $typeDesc += "CAP" }
if ($isHana) { $typeDesc += "HANA" }
if ($isUi5) { $typeDesc += "UI5" }
if ($isMta) { $typeDesc += "MTA" }
if ($isApprouter) { $typeDesc += "approuter" }
if ($isXsuaa) { $typeDesc += "xsuaa" }
if ($typeDesc.Count -eq 0) { $typeDesc += "desconocido" }
$isFullstack = ($isCap -and $isUi5)
if ($isFullstack) { $typeDesc += "fullstack" }
Emit "PASS" "tipo" "." ("tipo detectado: " + ($typeDesc -join "+")) "alcance de checks" "ninguno" "NO" "LOCAL"

# --- mta.yaml: modules[], resources[], requires con destino ---
$mtaPath = Join-Path $Target "mta.yaml"
if (-not (Test-Path $mtaPath)) {
  Emit "N-A" "mta" "mta.yaml" "sin mta.yaml" "deploy MTA no aplica" "crea mta.yaml si el MVP exige MTA" "NO" "LOCAL"
} else {
  $t = Read-Text $mtaPath
  if ($t -match "(?m)^\s*modules\s*:") { Emit "PASS" "mta" "mta.yaml" "modules[] presente" "ninguno" "ninguno" "NO" "LOCAL" }
  else { Emit "FAIL" "mta" "mta.yaml" "falta modules[]" "mbt/cf deploy falla" "declara modules: con al menos un modulo" "NO" "LOCAL" }
  if ($t -match "(?m)^\s*resources\s*:") { Emit "PASS" "mta" "mta.yaml" "resources[] presente" "ninguno" "ninguno" "NO" "LOCAL" }
  else { Emit "WARNING" "mta" "mta.yaml" "falta resources[]" "servicios sin declarar" "declara resources: (xsuaa/destination) si aplica" "NO" "LOCAL" }
  $reqs = ([regex]::Matches($t, "(?m)^\s*-\s*name\s*:\s*(\S+)"))
  if ($reqs.Count -eq 0) {
    Emit "N-A" "mta" "mta.yaml" "sin requires con nombre" "nada que resolver" "ninguno" "NO" "LOCAL"
  } else {
    $missing = @()
    $blocks = $t -split "(?m)^\s*requires\s*:"
    if ($blocks.Count -gt 1) {
      for ($i = 1; $i -lt $blocks.Count; $i++) {
        $blk = $blocks[$i]
        $next = $blk
        $m2 = [regex]::Match($blk, "(?ms)^(.*?)(?=^\s{0,4}\w[\w-]*\s*:)")
        if ($m2.Success) { $next = $m2.Groups[1].Value }
        if ($next -notmatch "name\s*:") { $missing += "requires-sin-nombre" }
      }
    }
    if ($missing.Count -eq 0) { Emit "PASS" "mta" "mta.yaml" "todo requires tiene destino/nombre" "ninguno" "ninguno" "NO" "LOCAL" }
    else { Emit "FAIL" "mta" "mta.yaml" "requires sin destino" "binding roto en deploy" "anade name: al requires" "NO" "LOCAL" }
  }
}

# --- xs-security.json: xsappname+scopes+role-templates, scope-references existen, cero secretos ---
$xsPath = Join-Path $Target "xs-security.json"
if (-not (Test-Path $xsPath)) {
  Emit "N-A" "xsuaa" "xs-security.json" "sin xs-security.json" "auth XSUAA no aplica" "crealo si el MVP exige xsuaa" "NO" "LOCAL"
} else {
  $t = Read-Text $xsPath
  $okJson = Test-JsonValid $t
  if (-not $okJson) { Emit "FAIL" "xsuaa" "xs-security.json" "JSON invalido" "deploy xsuaa falla" "valida el JSON" "NO" "LOCAL" }
  else { Emit "PASS" "xsuaa" "xs-security.json" "JSON valido" "ninguno" "ninguno" "NO" "LOCAL" }
  if ($t -match '"xsappname"\s*:') { Emit "PASS" "xsuaa" "xs-security.json" "xsappname presente" "ninguno" "ninguno" "NO" "LOCAL" }
  else { Emit "FAIL" "xsuaa" "xs-security.json" "falta xsappname" "instancia xsuaa invalida" "anade xsappname" "NO" "LOCAL" }
  if (($t -match '"scopes"\s*:') -and ($t -match '"role-templates"\s*:')) { Emit "PASS" "xsuaa" "xs-security.json" "scopes+role-templates presentes" "ninguno" "ninguno" "NO" "LOCAL" }
  else { Emit "FAIL" "xsuaa" "xs-security.json" "faltan scopes o role-templates" "autorizacion incompleta" "declara scopes y role-templates" "NO" "LOCAL" }
  $scopeNames = @()
  foreach ($m in [regex]::Matches($t, '"name"\s*:\s*"\$XSAPPNAME\.([^"]+)"')) { $scopeNames += $m.Groups[1].Value }
  $refs = @()
  foreach ($m in [regex]::Matches($t, '\$XSAPPNAME\.([A-Za-z0-9_-]+)')) { $refs += $m.Groups[1].Value }
  $orphan = @($refs | Where-Object { $scopeNames -notcontains $_ })
  if ($orphan.Count -eq 0) { Emit "PASS" "xsuaa" "xs-security.json" "scope-references existen" "ninguno" "ninguno" "NO" "LOCAL" }
  else { Emit "FAIL" "xsuaa" "xs-security.json" ("scope-references sin scope: " + ($orphan -join ",")) "rol roto en runtime" "declara el scope o corrige la referencia" "NO" "LOCAL" }
  if ($t -match "(?i)clientsecret|password|BEGIN PRIVATE") { Emit "FAIL" "xsuaa" "xs-security.json" "posible secreto literal" "fuga de credencial" "mueve el secreto fuera del repo" "NO" "LOCAL" }
  elseif ($t -match "eyJ[A-Za-z0-9_-]{8,}") { Emit "FAIL" "xsuaa" "xs-security.json" "posible token JWT literal" "fuga de credencial" "elimina el token del repo" "NO" "LOCAL" }
  else { Emit "PASS" "xsuaa" "xs-security.json" "cero secretos literales" "ninguno" "ninguno" "NO" "LOCAL" }
}

# --- xs-app.json: routes[] con source y (destination|localDir), authenticationMethod ---
$xaPath = Join-Path $Target "xs-app.json"
if (-not (Test-Path $xaPath)) {
  Emit "N-A" "approuter" "xs-app.json" "sin xs-app.json" "approuter no aplica" "crealo si el MVP exige approuter" "NO" "LOCAL"
} else {
  $t = Read-Text $xaPath
  $okJson = Test-JsonValid $t; $routes = $null
  if ($okJson) { try { $routes = ($t | ConvertFrom-Json -ErrorAction Stop).routes } catch { $routes = $null } }
  if (-not $okJson) { Emit "FAIL" "approuter" "xs-app.json" "JSON invalido" "approuter no arranca" "valida el JSON" "NO" "LOCAL" }
  elseif (-not $routes -or $routes.Count -eq 0) {
    # ConvertFrom-Json PS5.1 puede fallar al bindear (p.ej. claves "") aunque
    # el JSON sea valido (ya verificado arriba): fallback por conteo como .sh.
    $nSrc = ([regex]::Matches($t, '"source"\s*:')).Count
    $nDst = ([regex]::Matches($t, '"(destination|localDir)"\s*:')).Count
    if (($t -match '"routes"\s*:') -and ($nSrc -gt 0) -and ($nDst -ge $nSrc)) {
      Emit "PASS" "approuter" "xs-app.json" "routes[] presente" "ninguno" "ninguno" "NO" "LOCAL"
      Emit "WARNING" "approuter" "xs-app.json" "rutas con source y destination|localDir (conteo sin bindeo PS5.1)" "chequeo por objeto no verificable" "valida cada ruta o renombra claves '' para bindeo" "NO" "LOCAL"
    } else {
      Emit "FAIL" "approuter" "xs-app.json" "routes[] vacio o ausente" "sin rutas" "declara al menos una ruta" "NO" "LOCAL"
    }
  }
  else {
    Emit "PASS" "approuter" "xs-app.json" "routes[] presente" "ninguno" "ninguno" "NO" "LOCAL"
    $bad = 0
    foreach ($r in $routes) {
      $hasSrc = ($null -ne $r.source) -and ("$($r.source)" -ne "")
      $hasDst = ((($null -ne $r.destination) -and ("$($r.destination)" -ne "")) -or (($null -ne $r.localDir) -and ("$($r.localDir)" -ne "")))
      if ((-not $hasSrc) -or (-not $hasDst)) { $bad++ }
    }
    if ($bad -eq 0) { Emit "PASS" "approuter" "xs-app.json" "rutas con source y destination|localDir" "ninguno" "ninguno" "NO" "LOCAL" }
    else { Emit "FAIL" "approuter" "xs-app.json" "$bad ruta(s) sin source o destino" "ruta 404/500" "anade source y destination|localDir" "NO" "LOCAL" }
  }
  if ($t -match '"authenticationMethod"\s*:') { Emit "PASS" "approuter" "xs-app.json" "authenticationMethod presente" "ninguno" "ninguno" "NO" "LOCAL" }
  else { Emit "FAIL" "approuter" "xs-app.json" "falta authenticationMethod" "auth ambigua" "declara authenticationMethod (route)" "NO" "LOCAL" }
}

# --- package.json CAP: @sap/cds ^10, scripts test/build si es CAP ---
if (-not (Test-Path $pkgPath)) {
  Emit "N-A" "cap" "package.json" "sin package.json" "CAP no aplica" "crealo si el MVP exige CAP" "NO" "LOCAL"
} else {
  $t = Read-Text $pkgPath
  $okJson = Test-JsonValid $t
  if (-not $okJson) { Emit "FAIL" "cap" "package.json" "JSON invalido" "npm install falla" "valida el JSON" "NO" "LOCAL" }
  else { Emit "PASS" "cap" "package.json" "JSON valido" "ninguno" "ninguno" "NO" "LOCAL" }
  if ($isCap) {
    if ($t -match '"@sap/cds"\s*:\s*"\^?10') { Emit "PASS" "cap" "package.json" "@sap/cds ^10 presente" "ninguno" "ninguno" "NO" "LOCAL" }
    else { Emit "FAIL" "cap" "package.json" "falta @sap/cds ^10" "modelo CAP no compila" "anade @sap/cds ^10" "NO" "LOCAL" }
    if ($t -match '"@cap-js/sqlite"') { Emit "PASS" "cap" "package.json" "@cap-js/sqlite presente (dev local)" "ninguno" "ninguno" "NO" "LOCAL" }
    else { Emit "WARNING" "cap" "package.json" "falta @cap-js/sqlite" "sin BD local para dev/test" "anade @cap-js/sqlite (solo dev local, nunca en MTA)" "NO" "LOCAL" }
    $hasTest = ($t -match '"test"\s*:'); $hasBuild = ($t -match '"build"\s*:')
    if ($hasTest -and $hasBuild) { Emit "PASS" "cap" "package.json" "scripts test+build presentes" "ninguno" "ninguno" "NO" "LOCAL" }
    else { Emit "WARNING" "cap" "package.json" "faltan scripts test/build" "CI/E2E incompleto" "anade scripts test y build" "NO" "LOCAL" }
  } else {
    Emit "N-A" "cap" "package.json" "no es proyecto CAP" "nada que exigir" "ninguno" "NO" "LOCAL"
  }
}

# --- manifest.json con sap.app/id y type ---
if ($manifestHits.Count -eq 0) {
  Emit "N-A" "ui5" "manifest.json" "sin manifest.json" "UI5 no aplica" "crealo si el MVP exige UI5" "NO" "LOCAL"
} else {
  foreach ($m in $manifestHits) {
    $rel = $m.FullName.Substring($Target.Length).TrimStart("\","/")
    $t = Read-Text $m.FullName
    $okJson = Test-JsonValid $t
    if (-not $okJson) { Emit "FAIL" "ui5" $rel "JSON invalido" "app UI5 no carga" "valida el JSON" "NO" "LOCAL"; continue }
    if ($t -match '"sap\.app"') { Emit "PASS" "ui5" $rel "sap.app presente" "ninguno" "ninguno" "NO" "LOCAL" }
    else { Emit "FAIL" "ui5" $rel "falta sap.app" "descriptor UI5 invalido" "anade sap.app" "NO" "LOCAL" }
    if ($t -match '"id"\s*:') { Emit "PASS" "ui5" $rel "sap.app/id presente" "ninguno" "ninguno" "NO" "LOCAL" }
    else { Emit "FAIL" "ui5" $rel "falta sap.app/id" "id de app desconocido" "anade sap.app.id" "NO" "LOCAL" }
    if ($t -match '"type"\s*:') { Emit "PASS" "ui5" $rel "type presente" "ninguno" "ninguno" "NO" "LOCAL" }
    else { Emit "WARNING" "ui5" $rel "falta type" "tooling incompleto" "anade sap.app.type=application" "NO" "LOCAL" }
  }
}

# --- db/*.cds no vacio ---
$dbFiles = Find-Files "db" "*.cds"
$srvFiles = Find-Files "srv" "*.cds"
$allCds = @($dbFiles) + @($srvFiles)
if ($allCds.Count -eq 0) {
  Emit "N-A" "db" "db/*.cds" "sin modelos CDS" "CAP/HANA no aplica" "crea db/schema.cds si el MVP exige CAP" "NO" "LOCAL"
} else {
  foreach ($f in $allCds) {
    $rel = $f.FullName.Substring($Target.Length).TrimStart("\","/")
    $t = Read-Text $f.FullName
    if ($t.Trim().Length -eq 0) { Emit "FAIL" "db" $rel "CDS vacio" "modelo sin entidades" "declara entidades" "NO" "LOCAL" }
    else { Emit "PASS" "db" $rel "CDS no vacio" "ninguno" "ninguno" "NO" "LOCAL" }
  }
}

# --- test-aislamiento: 3 WARNING solo-lectura (regex, nunca FAIL) ---
$testFiles = @()
$testFiles += Find-Files "." "*.test.js"
$testFiles += Find-Files "." "*.spec.js"
if ($testFiles.Count -eq 0) {
  Emit "N-A" "test" "test/*.test.js" "sin suites de test" "aislamiento no aplica" "crea suites con fixtures propias si el MVP exige matriz" "NO" "LOCAL"
} else {
  $allT = ""
  foreach ($f in $testFiles) { $allT += [Environment]::NewLine + (Read-Text $f.FullName) }
  if (($allT -match 'localhost:\d+|127\.0\.0\.1:\d+|PORT\s*=\s*\d+') -and ($allT -notmatch 'process\.env\.PORT|process\.env\[')) {
    Emit "WARNING" "test" "test/*.test.js" "puerto fijo sin process.env.PORT" "suites colisionan en paralelo/CI" "usa const PORT = Number(process.env.PORT || 4011)" "NO" "LOCAL"
  } else { Emit "PASS" "test" "test/*.test.js" "puerto via env o sin literal" "ninguno" "ninguno" "NO" "LOCAL" }
  if (($allT -match 'try') -and ($allT -match 'finally') -and ($allT -match 'cleanup')) {
    Emit "PASS" "test" "test/*.test.js" "try/finally+cleanup presentes" "ninguno" "ninguno" "NO" "LOCAL"
  } else { Emit "WARNING" "test" "test/*.test.js" "falta try/finally+cleanup" "estado compartido entre casos" "envuelve cada it en try/finally con cleanup(DELETE)" "NO" "LOCAL" }
  if (($allT -match 'serialNumber') -and ($allT -notmatch 'randomUUID|randomBytes|Date\.now\(\)|uuid')) {
    Emit "WARNING" "test" "test/*.test.js" "serial hardcodeado sin unicidad" "colision unique en rerun/paralelo" "genera seriales unicos por caso (randomUUID)" "NO" "LOCAL"
  } else { Emit "PASS" "test" "test/*.test.js" "seriales unicos o sin serial" "ninguno" "ninguno" "NO" "LOCAL" }
}

# --- LOCAL-BUILD: cds/mbt solo BLOCKED si falta herramienta (no falla) ---
if ($isCap) {
  try {
    $null = Get-Command "cds" -ErrorAction Stop
    Emit "PASS" "build" "cds" "CLI cds disponible" "ninguno" "ninguno" "NO" "LOCAL"
  } catch {
    Emit "BLOCKED" "build" "cds" "CLI cds no disponible" "compilacion CAP no verificable" "npx -p @sap/cds-dk cds compile --to edmx" "NO" "LOCAL"
  }
}
if ($isMta) {
  try {
    $null = Get-Command "mbt" -ErrorAction Stop
    Emit "PASS" "build" "mbt" "CLI mbt disponible" "ninguno" "ninguno" "NO" "LOCAL"
  } catch {
    Emit "BLOCKED" "build" "mbt" "CLI mbt no disponible" "MTAR no verificable" "npx -p @sap/cloud-mta-build-tool mbt build" "NO" "LOCAL"
  }
}

if ($script:HasFail) { exit 1 } else { exit 0 }
