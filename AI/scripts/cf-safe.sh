#!/bin/sh
# Broker determinista para Cloud Foundry (POSIX sh). Par de cf-safe.ps1 (R1.3).
# Único punto de salida hacia cf en Bash/Git Bash. Fail-closed: denylist
# primero, luego allowlist, luego validación de target.
# Uso: sh scripts/cf-safe.sh <verbo...> [--allow-write] [--what-if]
#      [--expected-api URL] [--expected-org ORG]
# Salida: UNA línea JSON {ok,exit,verb,output}. El crudo va a
# temp/cf-safe/*.raw.log, nunca secretos a stdout (redactado básico).
# Diferencias honestas vs .ps1: sin extracción de nombres de service-keys,
# sin truncado a 4000 chars (se emiten máx 200 líneas en logs), redacción por
# sed (clientsecret|password|BEGIN PRIVATE|eyJ...). Para JSON completo y
# nombres, usar cf-safe.ps1 en Windows.
EXPECTED_API="https://api.cf.us10-001.hana.ondemand.com"
EXPECTED_ORG=""
ALLOW_WRITE=0
WHAT_IF=0
ARGS=""
while [ $# -gt 0 ]; do
  case "$1" in
    --allow-write) ALLOW_WRITE=1; shift ;;
    --what-if) WHAT_IF=1; shift ;;
    --expected-api) EXPECTED_API="$2"; shift 2 ;;
    --expected-org) EXPECTED_ORG="$2"; shift 2 ;;
    --expected-api=*) EXPECTED_API="${1#--expected-api=}"; shift ;;
    --expected-org=*) EXPECTED_ORG="${1#--expected-org=}"; shift ;;
    --) shift; while [ $# -gt 0 ]; do ARGS="$ARGS $1"; shift; done ;;
    *) ARGS="$ARGS $1"; shift ;;
  esac
done
set -- $ARGS
VERB="${1:-}"
case "$VERB" in
  delete-*|unbind-*|purge-*|restage-*) echo '{"ok":false,"exit":1,"verb":"'"$VERB"'","output":"DENY: verbo destructivo fuera de allowlist cerrada."}'; exit 1 ;;
  create-service-key|create-key) echo '{"ok":false,"exit":1,"verb":"'"$VERB"'","output":"DENY: create-service-key directo prohibido."}'; exit 1 ;;
esac
case "$ARGS" in *"|"*|*">"*|*";"*|*'`'*|*'$('* ) echo '{"ok":false,"exit":1,"verb":"'"$VERB"'","output":"DENY: posible inyeccion en argumentos."}'; exit 1 ;; esac
if [ "$VERB" = "set-env" ] && [ "$ALLOW_WRITE" -eq 0 ]; then
  echo '{"ok":false,"exit":1,"verb":"'"$VERB"'","output":"DENY: set-env exige --allow-write explicito."}'; exit 1
fi
READ_OK=0
for V in target apps app services service marketplace spaces space-users service-keys service-key env logs plugins; do
  if [ "$VERB" = "$V" ]; then READ_OK=1; fi
done
WRITE_OK=0
for V in create-space create-service set-space-role set-env; do
  if [ "$VERB" = "$V" ]; then WRITE_OK=1; fi
done
if [ "$VERB" = "target" ]; then
  case "$ARGS" in *" -o "*|*" -s "*) WRITE_OK=1; READ_OK=0 ;; esac
fi
if [ "$READ_OK" -eq 0 ]; then
  if [ "$WRITE_OK" -eq 1 ] && [ "$ALLOW_WRITE" -eq 0 ]; then
    echo '{"ok":false,"exit":2,"verb":"'"$VERB"'","output":"FUERA DE ALLOWLIST: escritura sin --allow-write."}'; exit 2
  fi
  if [ "$WRITE_OK" -eq 0 ]; then
    echo '{"ok":false,"exit":2,"verb":"'"$VERB"'","output":"FUERA DE ALLOWLIST: verbo no listado."}'; exit 2
  fi
fi
if [ "$VERB" = "logs" ]; then
  case "$ARGS" in *--recent*) ;; *) echo '{"ok":false,"exit":2,"verb":"logs","output":"FUERA DE ALLOWLIST: logs solo con --recent."}'; exit 2 ;; esac
fi
if [ "$WHAT_IF" -eq 1 ]; then
  echo '{"ok":true,"exit":0,"verb":"'"$VERB"'","output":"WHATIF: cf'"$ARGS"'"}'; exit 0
fi
if [ -z "$VERB" ]; then echo '{"ok":false,"exit":2,"verb":"","output":"FUERA DE ALLOWLIST: sin argumentos."}'; exit 2; fi
if ! command -v cf >/dev/null 2>&1; then
  echo '{"ok":false,"exit":4,"verb":"'"$VERB"'","output":"ERROR: cf no encontrado en PATH."}'; exit 4
fi
T_RAW=$(cf target 2>&1)
case "$T_RAW" in
  *"$EXPECTED_API"*) ;;
  *) echo '{"ok":false,"exit":3,"verb":"'"$VERB"'","output":"TARGET MISMATCH: endpoint no coincide."}'; exit 3 ;;
esac
if [ -n "$EXPECTED_ORG" ]; then
  case "$T_RAW" in
    *"$EXPECTED_ORG"*) ;;
    *) echo '{"ok":false,"exit":3,"verb":"'"$VERB"'","output":"TARGET MISMATCH: org no coincide."}'; exit 3 ;;
  esac
fi
TMPD="$(dirname "$0")/../../temp/cf-safe"
mkdir -p "$TMPD"
RAW="$TMPD/cf-$(date +%Y%m%d-%H%M%S)-PID$$.raw.log"
# shellcheck disable=SC2086
OUT=$(cf $ARGS 2>&1)
CODE=$?
printf '%s' "$OUT" > "$RAW"
RED=$(printf '%s' "$OUT" | sed -E 's/(clientsecret|password)([^ ]*)/\1***REDACTED***/gI; s/eyJ[A-Za-z0-9_-]+\.eyJ[A-Za-z0-9_.-]+/***REDACTED***/g')
if [ "$VERB" = "logs" ]; then RED=$(printf '%s' "$RED" | tail -n 200); fi
ESC=$(printf '%s' "$RED" | sed 's/\\/\\\\/g; s/"/\\"/g' | tr '\n' ' ' | cut -c1-4000)
if [ "$CODE" -ne 0 ]; then echo '{"ok":false,"exit":4,"verb":"'"$VERB"'","output":"'"$ESC"'"}'; exit 4; fi
echo '{"ok":true,"exit":0,"verb":"'"$VERB"'","output":"'"$ESC"'"}'
exit 0
