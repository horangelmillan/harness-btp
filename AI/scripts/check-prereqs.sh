#!/bin/sh
# Verificación de prerrequisitos del harness BTP (POSIX sh).
# Uso: ./check-prereqs.sh [--warn-only] [--need-mtar] [--need-java] [--need-cds] [--need-ui5] [--need-gh] [--need-op]
# --need-*: promociona ese opcional a REQUERIDO (cuando la spec del MVP lo exija; --need-cds no promociona ui5).
# --warn-only: nunca falla (exit 0); lo usan install.ps1/install.sh al final.
# NUNCA imprime secretos: solo ejecuta "<comando> --version" y cuenta archivos.
# REQUERIDO faltante -> exit 1 (salvo --warn-only). Solo opcionales -> exit 0.
WARN_ONLY=0; NEED_MTAR=0; NEED_JAVA=0; NEED_CDS=0; NEED_UI5=0; NEED_GH=0; NEED_OP=0
for a in "$@"; do
  case "$a" in
    --warn-only) WARN_ONLY=1 ;;
    --need-mtar) NEED_MTAR=1 ;;
    --need-java) NEED_JAVA=1 ;;
    --need-cds) NEED_CDS=1 ;;
    --need-ui5) NEED_UI5=1 ;;
    --need-gh) NEED_GH=1 ;;
    --need-op) NEED_OP=1 ;;
    *) echo "ABORT: opción desconocida $a"; exit 1 ;;
  esac
done
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HARNESS_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

N_REQ_MISSING=""; N_OPT_MISSING=0; OPT_NAMES=""
row() { printf '%-14s | %-42s | %-5s | %-6s | %s [%s]\n' "$1" "$2" "$3" "$4" "$5" "$6"; }
record() {
  # record <nivel> <estado> <nombre>
  if [ "$1" = "REQ" ] && [ "$2" = "FALTA" ]; then
    if [ -z "$N_REQ_MISSING" ]; then N_REQ_MISSING="$3"; else N_REQ_MISSING="$N_REQ_MISSING, $3"; fi
  elif [ "$1" = "OPT" ] && [ "$2" = "FALTA" ]; then
    N_OPT_MISSING=$((N_OPT_MISSING + 1))
    if [ -z "$OPT_NAMES" ]; then OPT_NAMES="$3"; else OPT_NAMES="$OPT_NAMES, $3"; fi
  fi
}
check_cmd() {
  # check_cmd <nombre> <args...>: imprime "versión" o "no encontrado en PATH"
  name="$1"; shift
  if command -v "$name" >/dev/null 2>&1; then
    v=$("$name" "$@" 2>&1 | head -n 1)
    [ -z "$v" ] && v="instalado"
    printf '%s' "$v"
    return 0
  fi
  printf 'no encontrado en PATH'
  return 1
}
opt_level() { if [ "$1" -eq 1 ]; then printf 'REQ'; else printf 'OPT'; fi; }

echo ""
echo "Prerrequisitos del harness BTP (harness: $HARNESS_ROOT)"
printf '%-14s | %-42s | %-5s | %-6s | %s\n' "Herramienta" "Necesaria para" "Nivel" "Estado" "Detalle / Instalacion"

if v=$(check_cmd git --version); then S=OK; else S=FALTA; fi
row "git" "control de versiones del MVP" "REQ" "$S" "$v" "https://git-scm.com/downloads"; record REQ "$S" git

if v=$(check_cmd node --version); then
  major=$(printf '%s' "$v" | sed -n 's/^v\?\([0-9][0-9]*\).*/\1/p')
  if [ -n "$major" ] && [ "$major" -ge 18 ]; then S=OK; else S=FALTA; v="$v (se requiere Node 18+)"; fi
else S=FALTA; fi
row "node 18+" "CAP, UI5, mbt, scripts del harness" "REQ" "$S" "$v" "https://nodejs.org/"; record REQ "$S" "node 18+"

CF_CMD="cf"
if [ -n "${CF_BIN:-}" ]; then
  cfbase="$(basename "$CF_BIN" .exe)"; cfbase="${cfbase%.cmd}"
  case "$cfbase" in cf|sap_cf) CF_CMD="$CF_BIN" ;; esac
fi
if v=$(check_cmd "$CF_CMD" --version); then
  case "$v" in *[Cc][Ff]*version*|*[Cc]loud*[Ff]oundry*) S=OK ;; *) S=FALTA; v="$v (AVISO: no parece el CLI de Cloud Foundry; si 'cf' es otra herramienta, define \$CF_BIN al CLI real (mapeo en ~/.harness/local.sh, ver skill cf-cli))" ;; esac
else S=FALTA; fi
row "cf" "despliegues y lecturas Cloud Foundry" "REQ" "$S" "$v" "https://docs.cloudfoundry.org/cf-cli/install-go-cli.html"; record REQ "$S" cf

if [ -f "$HARNESS_ROOT/AI/AGENTS.md" ] && { [ -f "$HARNESS_ROOT/AGENTS.md" ] || [ -f "$HARNESS_ROOT/templates/AGENTS.pointer.md" ]; }; then
  S=OK; v="AGENTS.md + AI/AGENTS.md presentes; verifica que tu cliente los lea"
else
  S=FALTA; v="falta AGENTS.md o AI/AGENTS.md (reinstala con install.sh)"
fi
row "cliente agentico" "leer AGENTS.md y orquestar el flujo" "REQ" "$S" "$v" "https://docs.opencode.ai/ (o tu cliente agéntico)"; record REQ "$S" "cliente agentico"

LVL=$(opt_level $NEED_MTAR)
if v=$(check_cmd mbt --version); then S=OK; else S=FALTA; fi
row "mbt" "construir MTAR (solo si el MVP lo exige)" "$LVL" "$S" "$v" "https://github.com/SAP/cloud-mta-build-tool"; record "$LVL" "$S" mbt

if [ "$NEED_MTAR" -eq 1 ]; then LVL=REQ; else LVL=OPT; fi
if v=$(check_cmd make --version); then S=OK; else S=FALTA; fi
row "make" "requerido por mbt" "$LVL" "$S" "$v" "https://www.gnu.org/software/make/"; record "$LVL" "$S" make

LVL=$(opt_level $NEED_JAVA)
if v=$(check_cmd java -version); then S=OK; else S=FALTA; fi
row "java" "builds MTA Java (solo si la spec los pide)" "$LVL" "$S" "$v" "https://adoptium.net/"; record "$LVL" "$S" java

LVL=$(opt_level $NEED_CDS)
if v=$(check_cmd cds --version); then S=OK; v="$v (global; el harness usa npx -p @sap/cds-dk cds)";
elif command -v npx >/dev/null 2>&1; then S=OK; v="valido via npx -p @sap/cds-dk cds (sin instalacion global)";
else S=FALTA; v="no global ni npx; valido via npx -p @sap/cds-dk (solo si la spec exige CAP)"; fi
row "cds" "proyectos CAP (solo si la spec lo exige)" "$LVL" "$S" "$v" "https://cap.cloud.sap/docs/get-started/"; record "$LVL" "$S" cds

LVL=$(opt_level $NEED_UI5)
if v=$(check_cmd ui5 --version); then S=OK; else S=FALTA; fi
row "ui5" "proyectos UI5/Fiori (solo si la spec lo exige)" "$LVL" "$S" "$v" "https://ui5.github.io/cli/"; record "$LVL" "$S" ui5

LVL=$(opt_level $NEED_GH)
if v=$(check_cmd gh --version); then S=OK; else S=FALTA; fi
row "gh" "repo remoto/PR (solo si la spec pide remoto)" "$LVL" "$S" "$v" "https://cli.github.com/"; record "$LVL" "$S" gh

LVL=$(opt_level $NEED_OP)
if v=$(check_cmd op --version); then S=OK; else S=FALTA; fi
row "op (1Password)" "secretos de equipo (solo si el equipo lo adopta)" "$LVL" "$S" "$v" "https://developer.1password.com/docs/cli/get-started/"; record "$LVL" "$S" "op (1Password)"

NSKILLS=0
if [ -d "$HARNESS_ROOT/AI/.opencode/skills" ]; then
  for d in "$HARNESS_ROOT"/AI/.opencode/skills/*/; do
    [ -f "${d}SKILL.md" ] && NSKILLS=$((NSKILLS + 1))
  done
fi
if [ "$NSKILLS" -gt 0 ]; then S=OK; else S=FALTA; fi
row "skills" "capacidades del harness (cf-cli, mta-build, ...)" "OPT" "$S" "$NSKILLS skills con SKILL.md" "(vienen con AI/; reinstala con install.sh si FALTA)"; record OPT "$S" skills

NAGENTS=0
if [ -d "$HARNESS_ROOT/AI/.opencode/agents" ]; then
  # shellcheck disable=SC2012
  NAGENTS=$(ls "$HARNESS_ROOT"/AI/.opencode/agents/*.md 2>/dev/null | wc -l | tr -d ' ')
fi
if [ "$NAGENTS" -gt 0 ]; then S=OK; else S=FALTA; fi
row "agents" "orquestador y especialistas" "OPT" "$S" "$NAGENTS agentes .md" "(vienen con AI/; reinstala con install.sh si FALTA)"; record OPT "$S" agents

if [ -f "$HARNESS_ROOT/AI/opencode.fragment.jsonc" ]; then S=OK; v="AI/opencode.fragment.jsonc presente"; else S=FALTA; v="no encontrado"; fi
row "fragmento MCP" "plantilla MCP del proyecto destino" "OPT" "$S" "$v" "(viene con AI/; reinstala con install.sh si FALTA)"; record OPT "$S" "fragmento MCP"

echo ""
echo "NOTA MCPs (no detectables desde shell): tu cliente agéntico debe tener configurados"
echo "sus propios MCPs: context7, codebase-memory, github, playwright, eslint, chrome-devtools."
echo "Detalle y docs oficiales: AI/docs/prerequisitos.md"

if [ -n "$N_REQ_MISSING" ]; then
  echo "RESULTADO: FALTAN REQUERIDOS ($N_REQ_MISSING). Instala y re-ejecuta este script."
  if [ "$WARN_ONLY" -eq 1 ]; then exit 0; else exit 1; fi
else
  if [ "$N_OPT_MISSING" -gt 0 ]; then
    echo "RESULTADO: OK en requeridos. Avisos opcionales ($N_OPT_MISSING): $OPT_NAMES."
  else
    echo "RESULTADO: todo OK (requeridos + opcionales presentes)."
  fi
  exit 0
fi
