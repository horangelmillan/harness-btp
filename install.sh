#!/bin/sh
# Instalador del harness BTP (idempotente, POSIX sh).
# Uso: ./install.sh [--dest <dir>] [--force] [--client auto|all|opencode,claude,...] [--backup-dir <dir>] [--help]
# Sin secretos. No toca package.json ni mta.yaml del proyecto.
# Backup por defecto: <dest>/AI.bak; con --backup-dir va fuera
# (p. ej. --backup-dir "$TMPDIR/harness-bak"), según AI/AGENTS.md § Frontera.
# Fusiona el árbol del cliente agéntico desde AI/clients/<cliente>/ en la raíz
# (solo faltantes; con --force hace backup a <dir>.bak o a --backup-dir).
# --client auto (defecto): detecta por huellas (CLAUDE.md|.claude→claude,
# .cursor→cursor, .github→copilot, opencode.json*|.opencode→opencode;
# sin huellas→opencode). all: todos. Lista explícita: esos.
DEST="."
FORCE=0
CLIENT="auto"
BACKUP_DIR=""
while [ $# -gt 0 ]; do
  case "$1" in
    --dest) DEST="$2"; shift 2 ;;
    --force) FORCE=1; shift ;;
    --client) CLIENT="$2"; shift 2 ;;
    --backup-dir) BACKUP_DIR="$2"; shift 2 ;;
    -h|--help)
      echo "Uso: ./install.sh [--dest <dir>] [--force] [--client <clientes>] [--backup-dir <dir>] [--help]"
      echo "  --dest <dir>    proyecto destino (por defecto: .)"
      echo "  --force         reinstala AI/ con backup (por defecto <dest>/AI.bak)"
      echo "  --backup-dir <dir>  backups fuera del destino (recomendado, p. ej. \$TMPDIR/harness-bak)"
      echo "  --client <list> auto (defecto) | all | opencode,claude,cursor,copilot,aider"
      echo "  -h, --help      muestra esta ayuda"
      exit 0 ;;
    *) echo "ABORT: opción desconocida $1 (usa --help)"; exit 1 ;;
  esac
done
# Limpieza de transitorios del merge (MT_LIST) ante salida/interrupción.
MT_CLEANUP=""
trap 'rm -f "$MT_CLEANUP" "${TMPDIR:-/tmp}/harness-mt-$$.tmp"' EXIT INT TERM
SRC="$(cd "$(dirname "$0")" && pwd)"
if [ ! -d "$SRC/AI" ]; then echo "ABORT: no se encontró AI/ junto a install.sh"; exit 1; fi
mkdir -p "$DEST"
HARNESS_VERSION="desconocida"
if [ -f "$SRC/AI/VERSION" ]; then HARNESS_VERSION="$(tr -d '[:space:]' < "$SRC/AI/VERSION")"; fi
[ -n "$HARNESS_VERSION" ] || HARNESS_VERSION="desconocida"

# Resuelve la ruta de backup: fuera del destino si --backup-dir, si no <ruta>.bak.
backup_path() {
  BP_CUR="$1"
  if [ -n "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    BP_BASE=$(basename "$BP_CUR")
    printf '%s' "$BACKUP_DIR/$BP_BASE.bak"
  else
    printf '%s' "$BP_CUR.bak"
  fi
}

if [ -d "$DEST/AI" ]; then
  if [ "$FORCE" -eq 1 ]; then
    OLD_VERSION="desconocida"
    if [ -f "$DEST/AI/VERSION" ]; then OLD_VERSION="$(tr -d '[:space:]' < "$DEST/AI/VERSION")"; fi
    [ -n "$OLD_VERSION" ] || OLD_VERSION="desconocida"
    BP_AI=$(backup_path "$DEST/AI")
    rm -rf "$BP_AI" && mv "$DEST/AI" "$BP_AI"
    cp -r "$SRC/AI" "$DEST/AI" && echo "BACKUP: AI/ (v$OLD_VERSION) -> $BP_AI; CREATE: AI/ (v$HARNESS_VERSION)"
  else
    echo "SKIP: AI/ ya existe (usa --force para reinstalar con backup .bak)"
  fi
else
  cp -r "$SRC/AI" "$DEST/AI" && echo "CREATE: AI/ (v$HARNESS_VERSION)"
fi

if [ -f "$DEST/AGENTS.md" ]; then
  echo "SKIP: AGENTS.md ya existe"
else
  cp "$SRC/templates/AGENTS.pointer.md" "$DEST/AGENTS.md" && echo "CREATE: AGENTS.md (puntero a AI/AGENTS.md)"
fi

# Fusion idempotente de un arbol: merge_tree <origen> <destino> <etiqueta>
# (etiqueta p. ej. ".opencode/"; el backup va a <destino>.bak).
merge_tree() {
  MT_SRC="$1"; MT_DST="$2"; MT_LABEL="$3"
  if [ ! -d "$MT_SRC" ]; then echo "AVISO: no existe $MT_SRC (regenera con node scripts/render-clients.js)"; return 0; fi
  MT_BAKLABEL="$(printf '%s' "$MT_LABEL" | sed 's:/$::').bak"
  if [ "$FORCE" -eq 1 ]; then
    if [ -d "$MT_DST" ]; then
      MT_BAK=$(backup_path "$MT_DST")
      rm -rf "$MT_BAK" && mv "$MT_DST" "$MT_BAK"
      echo "BACKUP: $MT_LABEL -> $MT_BAKLABEL ($MT_BAK)"
    fi
    mkdir -p "$(dirname "$MT_DST")"
    cp -r "$MT_SRC" "$MT_DST" && MT_COUNT=$(find "$MT_DST" -type f | wc -l) && echo "CREATE: $MT_LABEL (+$MT_COUNT archivos)"
  else
    MT_COUNT=0
    MT_LIST="${TMPDIR:-/tmp}/harness-mt-$$.tmp"
    MT_CLEANUP="$MT_LIST"
    find "$MT_SRC" -type f -print > "$MT_LIST"
    while IFS= read -r MT_FILE; do
      MT_REL=${MT_FILE#"$MT_SRC"/}
      if [ -f "$MT_DST/$MT_REL" ]; then
        echo "SKIP: $MT_LABEL$MT_REL ya existe"
      else
        mkdir -p "$(dirname "$MT_DST/$MT_REL")"
        cp "$MT_FILE" "$MT_DST/$MT_REL"
        MT_COUNT=$((MT_COUNT + 1))
      fi
    done < "$MT_LIST"
    rm -f "$MT_LIST"
    echo "CREATE: $MT_LABEL (+$MT_COUNT archivos)"
  fi
}

# Resuelve la lista de clientes: detecta huellas en auto, valida explícitos.
resolve_clients() {
  case "$CLIENT" in
    auto)
      RC_LIST=""
      { [ -f "$DEST/CLAUDE.md" ] || [ -d "$DEST/.claude" ]; } && RC_LIST="$RC_LIST claude"
      [ -d "$DEST/.cursor" ] && RC_LIST="$RC_LIST cursor"
      [ -d "$DEST/.github" ] && RC_LIST="$RC_LIST copilot"
      if ls "$DEST"/opencode.json* >/dev/null 2>&1 || [ -d "$DEST/.opencode" ]; then RC_LIST="$RC_LIST opencode"; fi
      [ -z "$RC_LIST" ] && RC_LIST=" opencode"
      echo "CLIENT: auto -> $(printf '%s' "$RC_LIST" | tr ' ' ',' | sed 's/^,//')" >&2
      printf '%s' "$RC_LIST"
      ;;
    all) printf ' opencode claude cursor copilot' ;;
    *)
      RC_OUT=""
      RC_REST="$CLIENT,"
      while [ -n "$RC_REST" ]; do
        RC_ONE=${RC_REST%%,*}; RC_REST=${RC_REST#*,}
        RC_ONE=$(printf '%s' "$RC_ONE" | tr 'A-Z' 'a-z' | tr -d ' ')
        [ -z "$RC_ONE" ] && continue
        case "$RC_ONE" in
          opencode|claude|cursor|copilot|aider) RC_OUT="$RC_OUT $RC_ONE" ;;
          *) echo "ABORT: cliente desconocido '$RC_ONE' (usa auto|all|opencode,claude,cursor,copilot,aider)" >&2; exit 1 ;;
        esac
      done
      [ -z "$RC_OUT" ] && { echo "ABORT: --client vacío (usa auto|all|opencode,claude,cursor,copilot,aider)" >&2; exit 1; }
      printf '%s' "$RC_OUT"
      ;;
  esac
}

CLIENTS_SRC="$SRC/AI/clients"
RC_RESOLVED=$(resolve_clients); RC_STATUS=$?
if [ "$RC_STATUS" -ne 0 ]; then exit "$RC_STATUS"; fi
for C in $RC_RESOLVED; do
  case "$C" in
    opencode) merge_tree "$CLIENTS_SRC/opencode" "$DEST/.opencode" ".opencode/" ;;
    claude) merge_tree "$CLIENTS_SRC/claude" "$DEST/.claude" ".claude/" ;;
    cursor)
      merge_tree "$CLIENTS_SRC/cursor/commands" "$DEST/.cursor/commands" ".cursor/commands/"
      merge_tree "$CLIENTS_SRC/cursor/skills" "$DEST/.agents/skills" ".agents/skills/" ;;
    copilot)
      merge_tree "$CLIENTS_SRC/copilot/agents" "$DEST/.github/agents" ".github/agents/"
      merge_tree "$CLIENTS_SRC/copilot/skills" "$DEST/.github/skills" ".github/skills/"
      merge_tree "$CLIENTS_SRC/copilot/prompts" "$DEST/.github/prompts" ".github/prompts/" ;;
    aider) echo "SKIP: aider usa AGENTS.md raiz (nada que fusionar)" ;;
  esac
done

FRAG="$SRC/AI/.gitignore.fragment"
touch "$DEST/.gitignore"
ADDED=0
while IFS= read -r line; do
  case "$line" in ""|\#*) continue ;; esac
  if ! grep -qxF -- "$line" "$DEST/.gitignore"; then
    printf '%s\n' "$line" >> "$DEST/.gitignore"
    ADDED=$((ADDED + 1))
  fi
done < "$FRAG"
if [ "$ADDED" -eq 0 ]; then echo "SKIP: .gitignore ya contiene el fragmento"
else echo "CREATE: .gitignore (+$ADDED líneas)"; fi

echo "OK: harness v$HARNESS_VERSION instalado en $DEST (package.json y mta.yaml intactos)"

# Verificación de prerrequisitos en modo aviso (no bloquea la instalación).
if [ -f "$SRC/AI/scripts/check-prereqs.sh" ]; then
  sh "$SRC/AI/scripts/check-prereqs.sh" --warn-only || true
else
  echo "AVISO: no se encontró check-prereqs.sh (ver AI/docs/prerequisitos.md)"
fi
