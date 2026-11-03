#!/bin/sh
# Runner único de app-ui5-qunit-opa: HTTP backend + QUnit unit + OPA5 journey.
# Orden: ensure CDP → arranca CAP propio (4022) → npm test (HTTP) →
# QUnit unit (cdp-eval.js) → OPA5 journey (cdp-eval.js) → cleanup en trap
# (CAP solo PID propio + cdp cleanup + puerto libre verificado).
# Par de scripts/run-ui5-tests.ps1 (R2.2).
# Uso: sh scripts/run-ui5-tests.sh [port=4022] [cdp-port=9222]
#   CHROME_BIN=<ruta> TMPDIR=<dir> (ver cdp-chrome.sh).
PORT="${1:-4022}"
CDP_PORT="${2:-9222}"
HERE=$(dirname "$0")
FIXTURE=$(cd "$HERE/.." && pwd)
CAP_PID=""
FAIL=0

# Resuelve cdp-chrome.sh vía Test-Path equivalente ([ -f ] en varias rutas).
CDP=""
for c in "$FIXTURE/../../../scripts/cdp-chrome.sh" \
         "$FIXTURE/../../AI/scripts/cdp-chrome.sh" \
         "AI/scripts/cdp-chrome.sh"; do
  if [ -f "$c" ]; then CDP="$c"; break; fi
done
if [ -z "$CDP" ]; then echo "DETENIDO: cdp-chrome.sh no encontrado"; exit 1; fi

cleanup() {
  echo "== cleanup =="
  # El PID guardado puede haber muerto dejando huérfanos: respaldo por
  # identidad (cmdline con NUESTRO puerto). Nunca pkill/killall desnudo.
  if [ -n "$CAP_PID" ] && kill -0 "$CAP_PID" 2>/dev/null; then
    kill "$CAP_PID" 2>/dev/null
    echo "CAP propio PID $CAP_PID detenido."
  else
    echo "CAP propio PID guardado ya ausente."
  fi
  # Huérfanos propios (npx/node cds serve en nuestro puerto): solo esos.
  # shellcheck disable=SC2009
  for _p in $(ps -eo pid,args 2>/dev/null | grep "cds serve.*--port $PORT" | grep -v grep | awk '{print $1}'); do
    kill "$_p" 2>/dev/null && echo "huerfano propio PID $_p detenido."
  done
  sleep 2
  sh "$CDP" cleanup "$CDP_PORT" || FAIL=1
  # Ground truth: connect TCP con reintentos (node/chrome tardan segundos
  # en soltar; los TimeWait propios rechazan conexión aunque figuren).
  for _i in 1 2 3 4 5 6 7 8; do
    if curl -s -m 2 -o /dev/null "http://localhost:$PORT/" 2>/dev/null; then
      if [ "$_i" -eq 8 ]; then echo "AVISO: puerto $PORT aún ocupado tras cleanup."; FAIL=1; fi
      sleep 2
    else
      echo "Puerto $PORT libre verificado."
      break
    fi
  done
  exit $FAIL
}
trap cleanup EXIT INT TERM

wait_cap() {
  t=0
  while [ "$t" -lt 90 ]; do
    if curl -s -m 5 "http://localhost:$PORT/odata/v4/catalog/Books" 2>/dev/null | grep -q '"value"'; then
      return 0
    fi
    sleep 1; t=$((t + 1))
  done
  return 1
}

echo "== ensure CDP =="
sh "$CDP" ensure "$CDP_PORT" || { echo "DETENIDO: sin endpoint CDP verificado no hay prueba con navegador."; exit 1; }

echo "== arranca CAP (puerto $PORT) =="
(cd "$FIXTURE" && npx -p @sap/cds-dk cds serve --port "$PORT" --in-memory >/dev/null 2>&1 &) 
CAP_PID=$!
if ! wait_cap; then echo "DETENIDO: CAP no respondió GET /Books 200 en 90 s."; exit 1; fi

echo "== HTTP backend (node --test) =="
(cd "$FIXTURE" && PORT="$PORT" npm test) || { echo "FALLO: suite HTTP backend en rojo."; exit 1; }

echo "== QUnit unit puro =="
node "$FIXTURE/scripts/cdp-eval.js" "$CDP_PORT" \
  "http://localhost:$PORT/test/unit/unitTests.qunit.html" unit 120000 \
  || { echo "FALLO: QUnit unit sin 0 failed (¿CDN UI5 bloqueado? ver salida)."; exit 1; }

echo "== OPA5 journey CRUD =="
node "$FIXTURE/scripts/cdp-eval.js" "$CDP_PORT" \
  "http://localhost:$PORT/test/integration/opaTests.qunit.html" opa 240000 \
  || { echo "FALLO: OPA5 sin 0 failed (¿CDN UI5 bloqueado? ver salida)."; exit 1; }

echo "VERDE: HTTP + QUnit unit + OPA5 journey."
