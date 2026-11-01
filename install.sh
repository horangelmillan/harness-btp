#!/bin/sh
# Instalador del harness BTP (idempotente, POSIX sh).
# Uso: ./install.sh [--dest .] [--force]
# Sin secretos. No toca package.json ni mta.yaml del proyecto.
DEST="."
FORCE=0
while [ $# -gt 0 ]; do
  case "$1" in
    --dest) DEST="$2"; shift 2 ;;
    --force) FORCE=1; shift ;;
    *) echo "ABORT: opción desconocida $1"; exit 1 ;;
  esac
done
SRC="$(cd "$(dirname "$0")" && pwd)"
if [ ! -d "$SRC/AI" ]; then echo "ABORT: no se encontró AI/ junto a install.sh"; exit 1; fi

if [ -d "$DEST/AI" ]; then
  if [ "$FORCE" -eq 1 ]; then
    rm -rf "$DEST/AI.bak" && mv "$DEST/AI" "$DEST/AI.bak"
    echo "BACKUP: AI/ -> AI.bak"
    cp -r "$SRC/AI" "$DEST/AI" && echo "CREATE: AI/ (reinstalado con --force)"
  else
    echo "SKIP: AI/ ya existe (usa --force para reinstalar con backup .bak)"
  fi
else
  cp -r "$SRC/AI" "$DEST/AI" && echo "CREATE: AI/"
fi

if [ -f "$DEST/AGENTS.md" ]; then
  echo "SKIP: AGENTS.md ya existe"
else
  cp "$SRC/templates/AGENTS.pointer.md" "$DEST/AGENTS.md" && echo "CREATE: AGENTS.md (puntero a AI/AGENTS.md)"
fi

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

echo "OK: harness instalado en $DEST (package.json y mta.yaml intactos)"

# Verificación de prerrequisitos en modo aviso (no bloquea la instalación).
if [ -f "$SRC/AI/scripts/check-prereqs.sh" ]; then
  sh "$SRC/AI/scripts/check-prereqs.sh" --warn-only || true
else
  echo "AVISO: no se encontró check-prereqs.sh (ver AI/docs/prerequisitos.md)"
fi
