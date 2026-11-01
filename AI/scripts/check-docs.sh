#!/bin/sh
# Verificación de fuentes oficiales del harness BTP (POSIX sh).
# Uso: sh AI/scripts/check-docs.sh
# - Comprueba cada URL de AI/docs/fuentes-oficiales.md con UN solo intento
#   HTTP GET (timeout 15 s, --retry 0, sin reintentos ni bucles).
# - Emite OK / ROTO / PENDIENTE por fuente + fecha.
# - OK: HTTP 2xx-3xx. ROTO: HTTP 4xx-5xx confirmado. PENDIENTE: sin respuesta
#   (timeout/DNS; avisa pero no falla: re-verificar y actualizar la fecha).
# - exit 1 si alguna fuente REQUERIDA está ROTA. exit 0 en otro caso.
# - Cero secretos: solo peticiones GET anónimas, sin credenciales.
FECHA=$(date +%F)
FALLOS_REQ=0
# check_doc <nombre> <url> <nivel>: un solo intento, sin bucles.
check_doc() {
  _code=$(curl -s -o /dev/null -w "%{http_code}" -L --max-time 15 --retry 0 "$2" 2>/dev/null)
  _rc=$?
  if [ $_rc -ne 0 ]; then
    echo "$1 | PENDIENTE (sin respuesta: timeout/DNS) | $FECHA | $2"
  elif [ "$_code" -ge 200 ] && [ "$_code" -lt 400 ]; then
    echo "$1 | OK | $FECHA | $2"
  else
    echo "$1 | ROTO (HTTP $_code) | $FECHA | $2"
    if [ "$3" = "REQ" ]; then FALLOS_REQ=$((FALLOS_REQ + 1)); fi
  fi
}
echo ""
echo "Fuentes oficiales del harness BTP ($FECHA)"
check_doc "cf-cli" "https://docs.cloudfoundry.org/cf-cli/install-go-cli.html" "REQ"
check_doc "mbt" "https://github.com/SAP/cloud-mta-build-tool" "REQ"
check_doc "cap" "https://cap.cloud.sap/docs/get-started/" "REQ"
check_doc "ui5-cli" "https://ui5.github.io/cli/" "REQ"
check_doc "opencode" "https://docs.opencode.ai/docs" "REQ"
check_doc "npm-trusted-publishers" "https://docs.npmjs.com/trusted-publishers/" "REQ"
check_doc "op-1password" "https://developer.1password.com/docs/cli/get-started/" "OPT"
echo ""
if [ "$FALLOS_REQ" -gt 0 ]; then
  echo "RESULTADO: $FALLOS_REQ fuente(s) REQUERIDA(s) ROTA(s). Revisa AI/docs/fuentes-oficiales.md y actualiza la fecha tras corregir."
  exit 1
else
  echo "RESULTADO: ninguna fuente REQUERIDA rota. Actualiza la columna de fecha en AI/docs/fuentes-oficiales.md."
  exit 0
fi
