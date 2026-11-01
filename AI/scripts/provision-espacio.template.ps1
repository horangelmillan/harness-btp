<# Plantilla de pre-provisión idempotente por paisaje (espacio).
   Copiar a scripts/provision-<espacio>.ps1 y rellenar los TODO.
   Reglas (AGENTS.md § Paisajes): preflight de target (endpoint+org, aborta
   si no coinciden) -> crea espacio si falta -> guardia de marketplace
   (aborta antes de crear si falta un offering) -> crea instancias solo si
   faltan -> asigna rol solo si falta. Emite SKIP: si existe, CREATE: si crea.
   Allowlist cerrada: target, spaces, space-users, services, marketplace,
   create-space, create-service, set-space-role.
   PROHIBIDO: delete-*, unbind-*, purge-*, restage-*. Usa cf.
   Cero secretos en repo: solo nombres. #>
param(
  [string]$Space = "TODO(<paisaje>)",
  [string]$ExpectedApi = "TODO([TU_ENDPOINT_CF])",
  [string]$ExpectedOrg = "TODO(<org>)"
)

$ErrorActionPreference = "Stop"

function Target-Ok {
  $t = & cf target 2>&1 | Out-String
  if ($t -notmatch [regex]::Escape($ExpectedApi)) { Write-Output "ABORT: endpoint no coincide (esperado $ExpectedApi)"; return $false }
  if ($t -notmatch [regex]::Escape($ExpectedOrg)) { Write-Output "ABORT: org no coincide (esperada $ExpectedOrg)"; return $false }
  return $true
}

if (-not (Target-Ok)) { exit 1 }

# 1. Espacio: crear solo si falta
$spaces = & cf spaces 2>&1 | Out-String
if ($spaces -match "(?m)^\s*$([regex]::Escape($Space))\s*$") {
  Write-Output "SKIP: space $Space ya existe"
} else {
  & cf create-space $Space
  Write-Output "CREATE: space $Space"
}
& cf target -s $Space | Out-Null

# 2. Guardia de marketplace: aborta antes de crear si falta un offering
# TODO: lista los offerings requeridos, p. ej. @("xsuaa", "destination")
$RequiredOfferings = @()
$market = & cf marketplace 2>&1 | Out-String
foreach ($o in $RequiredOfferings) {
  if ($market -notmatch [regex]::Escape($o)) {
    Write-Output "ABORT: offering $o no disponible en marketplace"
    exit 1
  }
}

# 3. Instancias: crear solo si faltan
# TODO: anadir una entrada por instancia: @{ Name="TODO"; Offering="TODO"; Plan="TODO" }
$Instances = @()
$services = & cf services 2>&1 | Out-String
foreach ($i in $Instances) {
  if ($services -match [regex]::Escape($i.Name)) {
    Write-Output ("SKIP: service {0} ya existe" -f $i.Name)
  } else {
    & cf create-service $i.Offering $i.Plan $i.Name
    Write-Output ("CREATE: service {0}" -f $i.Name)
  }
}

# 4. Rol: asignar solo si falta
# TODO: fijar usuario, p. ej. $User = "TODO"
$User = "TODO"
$users = & cf space-users $ExpectedOrg $Space 2>&1 | Out-String
if ($users -match [regex]::Escape($User)) {
  Write-Output "SKIP: rol de $User ya asignado"
} else {
  & cf set-space-role $User $ExpectedOrg $Space SpaceDeveloper
  Write-Output "CREATE: rol SpaceDeveloper para $User"
}

Write-Output "OK: provision $Space"
