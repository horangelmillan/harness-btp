#!/bin/sh
# Chequeo pre-commit (POSIX sh). Par de pre-commit-check.ps1 (R1.3).
# Bloquea secretos fuera de temp/. Falla (exit 1) si encuentra señales en
# archivos staged fuera de temp/ y sin marcador ***REDACTED***.
# Patrones: clientsecret, password, BEGIN PRIVATE, JWT (eyJ.eyJ).
# Uso manual: sh scripts/pre-commit-check.sh
REPO_ROOT=$(cd "$(dirname "$0")/../.." 2>/dev/null && pwd)
case "$REPO_ROOT" in ""|/) REPO_ROOT=$(pwd) ;; esac
cd "$REPO_ROOT" || exit 0
STAGED=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null)
if [ -z "$STAGED" ]; then echo "pre-commit-check: sin cambios staged; OK."; exit 0; fi
FAIL=0
for F in $STAGED; do
  case "$F" in temp/*) continue ;; esac
  [ -f "$REPO_ROOT/$F" ] || continue
  HITS=$(grep -inE 'clientsecret|password|BEGIN PRIVATE|eyJ[A-Za-z0-9_-]+\.eyJ' "$REPO_ROOT/$F" 2>/dev/null | grep -v '\*\*\*REDACTED\*\*\*')
  if [ -n "$HITS" ]; then
    echo "BLOQUEADO: posible secreto en $F:"
    echo "$HITS"
    FAIL=$((FAIL + 1))
  fi
done
if [ "$FAIL" -gt 0 ]; then
  echo "pre-commit-check: $FAIL archivo(s). Redacta con ***REDACTED*** o mueve a temp/."
  exit 1
fi
echo "pre-commit-check: OK, sin secretos detectados."
exit 0
