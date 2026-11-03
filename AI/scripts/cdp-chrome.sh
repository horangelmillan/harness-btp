#!/bin/sh
# Gestiona el host CDP (Chrome headless) para pruebas con navegador.
# Par de AI/scripts/cdp-chrome.ps1 (R2.1): mismo contrato, tres modos.
# El MCP `playwright` solo se CONECTA a http://localhost:PUERTO: no lanza
# ningun navegador. Este script es el unico medio autorizado para levantar
# ese endpoint desde Bash (Linux/WSL/Git Bash/macOS con Chrome).
#
# Modos:
#   status  - informa si el puerto responde y si hay procesos propios vivos.
#   ensure  - garantiza un endpoint CDP operativo (reutiliza el existente
#             si responde; si el puerto lo ocupa un proceso AJENO, se detiene
#             sin matarlo e informa; si esta libre, lanza Chrome propio).
#   cleanup - mata SOLO los procesos Chrome lanzados por este script
#             (verificados por PID + linea de comandos con el perfil propio),
#             borra el perfil temporal y verifica que el puerto quede libre.
#
# Regla irrestricta (AI/AGENTS.md): `ensure` antes de cada sesion de pruebas
# con navegador, `cleanup` al terminarla. Sin limpieza verificada no se
# cierra la tarea. PROHIBIDO pkill/killall: solo PIDs del fichero owner
# verificados por cmdline.
#
# Uso: sh scripts/cdp-chrome.sh [status|ensure|cleanup] [puerto]
#   CHROME_BIN=<ruta>  binario Chrome (por defecto: google-chrome |
#                      chromium | chromium-browser; en WSL vale la ruta
#                      Windows a chrome.exe si `wslpath` la convierte).
#   TMPDIR=<dir>       base de perfiles (por defecto /tmp).
#
# Salidas: lineas ESTADO/ENDPOINT/PROPIOS/LIMPIEZA/DETENIDO. Exit: status 0
# (1 si falta una dependencia); ensure 0 ok / 1 detenido; cleanup 0 ok /
# 1 incompleto. Requisitos: curl, un Chrome compatible, (Linux: /proc o `ss`;
# macOS: `ps`, `lsof` si existe; solo se usan para DETECTAR, nunca matar).
MODE="${1:-status}"
PORT="${2:-9222}"
case "$MODE" in status|ensure|cleanup) ;; *) echo "DETENIDO: modo '$MODE' (usa status|ensure|cleanup)"; exit 1 ;; esac
case "$PORT" in ''|*[!0-9]*) echo "DETENIDO: puerto '$PORT' no numerico"; exit 1 ;; esac

BASE="${TMPDIR:-/tmp}"
# WSL con Chrome de Windows: el perfil debe vivir en %TEMP% de Windows
# (\\wsl.localhost\... provoca errores de LockFile/sandbox). Solo deteccion.
if command -v wslpath >/dev/null 2>&1 && command -v cmd.exe >/dev/null 2>&1; then
  _WT=$(cmd.exe /c "echo %TEMP%" 2>/dev/null | tr -d '\r')
  if [ -n "$_WT" ]; then
    _WL=$(wslpath -u "$_WT" 2>/dev/null)
    if [ -n "$_WL" ] && [ -d "$_WL" ]; then BASE="$_WL"; fi
  fi
fi
PROFILE_DIR="$BASE/mvp-cdp-$PORT"
OWNER_FILE="$PROFILE_DIR/owner.pids"
ENDPOINT="http://localhost:$PORT/json/version"

need() { command -v "$1" >/dev/null 2>&1 || { echo "DETENIDO: falta dependencia '$1' en PATH"; exit 1; }; }

resolve_chrome() {
  if [ -n "$CHROME_BIN" ]; then
    [ -x "$CHROME_BIN" ] || [ -f "$CHROME_BIN" ] || { echo "DETENIDO: CHROME_BIN no existe: $CHROME_BIN" >&2; exit 1; }
    printf '%s' "$CHROME_BIN"; return
  fi
  for c in google-chrome chromium chromium-browser; do
    if command -v "$c" >/dev/null 2>&1; then command -v "$c"; return; fi
  done
  echo "DETENIDO: Chrome no encontrado (define CHROME_BIN)"; exit 1
}

# Perfil en formato que el binario entienda (wslpath si .exe bajo WSL).
# Publica WIN_PROFILE (forma Windows) para verificar cmdline en interop.
WIN_PROFILE=""
profile_for_chrome() {
  case "$1" in
    *.exe) if command -v wslpath >/dev/null 2>&1; then WIN_PROFILE=$(wslpath -w "$PROFILE_DIR"); printf '%s' "$WIN_PROFILE"; else printf '%s' "$PROFILE_DIR"; fi ;;
    *) printf '%s' "$PROFILE_DIR" ;;
  esac
}

test_endpoint() {
  need curl
  curl -s -m 5 "$ENDPOINT" 2>/dev/null | grep -q "webSocketDebuggerUrl"
}

# ¿Hay alguien escuchando en el puerto? Solo deteccion (ss, /proc, lsof,
# netstat.exe). Los sockets Bound (sin estado Listen) son invisibles para
# estas herramientas (R2.1): la prueba final es un connect TCP via curl
# (exit 0 = alguien acepta = ocupado; 7 = refused = libre). Nunca se mata.
port_busy() {
  if command -v ss >/dev/null 2>&1; then
    ss -ltn 2>/dev/null | grep -qE "[:.]$PORT( |\$)" && return 0
  fi
  if [ -r /proc/net/tcp ]; then
    HEX=$(printf '%04X' "$PORT")
    grep -qi ":$HEX " /proc/net/tcp /proc/net/tcp6 2>/dev/null && return 0
  fi
  if command -v lsof >/dev/null 2>&1; then
    lsof -nP -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1 && return 0
  fi
  if command -v netstat.exe >/dev/null 2>&1; then
    # Git Bash/Windows: `netstat.exe -ano` (solo deteccion; TCP+TCPv6).
    netstat.exe -ano -p TCP 2>/dev/null | grep -qE "[:.]$PORT +.*LISTENING" && return 0
    netstat.exe -ano -p TCPv6 2>/dev/null | grep -qE "[:.]$PORT +.*LISTENING" && return 0
  fi
  # Fallback fiable: connect TCP. Cualquier aceptacion = ocupado.
  curl -s -m 2 -o /dev/null "http://localhost:$PORT/" 2>/dev/null && return 0
  return 1
}

own_pids() { [ -f "$OWNER_FILE" ] && tr ' ' '\n' < "$OWNER_FILE" | grep -E '^[0-9]+$'; }

cmdline_has_profile() {
  _p="$1"
  _cl=""
  if [ -r "/proc/$_p/cmdline" ]; then
    _cl=$(tr '\0' ' ' < "/proc/$_p/cmdline" 2>/dev/null)
  else
    # macOS/sin /proc: `ps` por PID (solo deteccion, nunca en grupo).
    _cl=$(ps -p "$_p" -o command= 2>/dev/null)
  fi
  [ -z "$_cl" ] && return 1
  case "$_cl" in *"$PROFILE_DIR"*) return 0 ;; esac
  [ -n "$WIN_PROFILE" ] && case "$_cl" in *"$WIN_PROFILE"*) return 0 ;; esac
  # Interop WSL: el perfil Windows puede variar en mayusculas/barras.
  case "$_cl" in *"mvp-cdp-$PORT"*) return 0 ;; esac
  return 1
}

is_own_alive() {
  _p="$1"
  kill -0 "$_p" 2>/dev/null || return 1
  cmdline_has_profile "$_p"
}

own_alive() { for _p in $(own_pids); do is_own_alive "$_p" && echo "$_p"; done; }

if [ "$MODE" = "status" ]; then
  if port_busy; then echo "PUERTO $PORT: ocupado"; else echo "PUERTO $PORT: libre"; fi
  if test_endpoint; then echo "ENDPOINT: responde"; else echo "ENDPOINT: sin respuesta"; fi
  echo "PROPIOS VIVOS: $(own_alive | wc -l | tr -d ' ')"
  exit 0
fi

if [ "$MODE" = "ensure" ]; then
  if test_endpoint; then
    echo "ENDPOINT operativo en $ENDPOINT; no se lanza nada (reutilizacion)."
    exit 0
  fi
  if port_busy; then
    echo "DETENIDO: el puerto $PORT lo ocupa un proceso ajeno. No se mata. Libera el puerto o avisa al usuario."
    exit 1
  fi
  CHROME=$(resolve_chrome) || exit 1
  CPROFILE=$(profile_for_chrome "$CHROME")
  mkdir -p "$PROFILE_DIR"
  "$CHROME" --headless=new --no-first-run --no-default-browser-check \
    --remote-debugging-port="$PORT" --user-data-dir="$CPROFILE" about:blank \
    >/dev/null 2>&1 &
  LAUNCHED=$!
  OK=0
  for W in 1 2 4; do
    sleep "$W"
    if test_endpoint; then OK=1; break; fi
    kill -0 "$LAUNCHED" 2>/dev/null || break
  done
  if [ "$OK" -ne 1 ]; then
    echo "DETENIDO: Chrome no respondio en $ENDPOINT tras 3 intentos."
    exit 1
  fi
  # Descubre PIDs propios: el lanzado + hijos con el perfil en cmdline.
  MINE="$LAUNCHED"
  if [ -d /proc ]; then
    for d in /proc/[0-9]*; do
      _p=${d#/proc/}; [ "$_p" = "$LAUNCHED" ] && continue
      cmdline_has_profile "$_p" 2>/dev/null && MINE="$MINE $_p"
    done
  fi
  printf '%s' "$MINE" > "$OWNER_FILE"
  echo "ENDPOINT operativo en $ENDPOINT (PIDs propios: $MINE, perfil temporal)."
  exit 0
fi

# cleanup: solo PIDs del owner verificados por cmdline; idempotente.
# Chrome headless tarda >2s en apagado graceful: TERM, espera 4s, KILL, espera.
KILLED=0; SKIPPED=0
for _p in $(own_pids); do
  if is_own_alive "$_p"; then kill "$_p" 2>/dev/null; KILLED=$((KILLED + 1)); else SKIPPED=$((SKIPPED + 1)); fi
done
sleep 4
for _p in $(own_pids); do
  if is_own_alive "$_p"; then kill -9 "$_p" 2>/dev/null; fi
done
# Espera con sondeo (el apagado headless puede tardar): max 10 s.
for _i in 1 2 3 4 5; do
  own_alive | grep -q . || break
  sleep 2
done
ALIVE_N=$(own_alive | wc -l | tr -d ' ')
if [ "$ALIVE_N" -eq 0 ] && [ -d "$PROFILE_DIR" ]; then rm -rf "$PROFILE_DIR"; fi
if [ "$ALIVE_N" -eq 0 ] && ! port_busy && ! test_endpoint; then
  echo "LIMPIEZA OK: $KILLED proceso(s) propio(s) detenido(s), $SKIPPED ya ausente(s)/ajeno(s) intacto(s), puerto $PORT libre."
  exit 0
fi
echo "LIMPIEZA INCOMPLETA: propios vivos=$ALIVE_N, puerto ocupado=$(port_busy && echo no || echo si). Revisar manual."
exit 1
