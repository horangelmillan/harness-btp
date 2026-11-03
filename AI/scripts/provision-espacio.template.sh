#!/bin/sh
# Plantilla de pre-provisión idempotente por paisaje (POSIX sh).
# Par de AI/scripts/provision-espacio.template.ps1 (R1.3): misma secuencia y
# mensajes SKIP:/CREATE:/ABORT:. Diferencias inevitables: sh no tiene
# regex lookarounds; la coincidencia es por substring literal (case *...*).
# Copiar a scripts/provision-<espacio>.sh y rellenar los TODO.
# Allowlist cerrada: target, spaces, space-users, services, marketplace,
# create-space, create-service, set-space-role.
# PROHIBIDO: delete-*, unbind-*, purge-*, restage-*. Usa cf. Cero secretos.
SPACE="TODO(<paisaje>)"
EXPECTED_API="TODO([TU_ENDPOINT_CF])"
EXPECTED_ORG="TODO(<org>)"
# TODO: lista los offerings requeridos, p. ej. REQUIRED_OFFERINGS="xsuaa destination"
REQUIRED_OFFERINGS=""
# TODO: una línea por instancia "nombre:offering:plan", p. ej. INSTANCES="mi-xsuaa:xsuaa:application"
INSTANCES=""
# TODO: fijar usuario, p. ej. USER="nombre.apellido@empresa.com"
USER="TODO"

if [ -n "$1" ]; then SPACE="$1"; fi
T_RAW=$(cf target 2>&1)
case "$T_RAW" in
  *"$EXPECTED_API"*) ;;
  *) echo "ABORT: endpoint no coincide (esperado $EXPECTED_API)"; exit 1 ;;
esac
case "$T_RAW" in
  *"$EXPECTED_ORG"*) ;;
  *) echo "ABORT: org no coincide (esperada $EXPECTED_ORG)"; exit 1 ;;
esac

SPACES=$(cf spaces 2>&1)
case "$SPACES" in
  *"$SPACE"*) echo "SKIP: space $SPACE ya existe" ;;
  *) cf create-space "$SPACE" && echo "CREATE: space $SPACE" ;;
esac
cf target -s "$SPACE" >/dev/null

MARKET=$(cf marketplace 2>&1)
for O in $REQUIRED_OFFERINGS; do
  case "$MARKET" in
    *"$O"*) ;;
    *) echo "ABORT: offering $O no disponible en marketplace"; exit 1 ;;
  esac
done

SERVICES=$(cf services 2>&1)
OLDIFS="$IFS"; IFS=" "
for I in $INSTANCES; do
  I_NAME=$(printf '%s' "$I" | cut -d: -f1)
  I_OFF=$(printf '%s' "$I" | cut -d: -f2)
  I_PLAN=$(printf '%s' "$I" | cut -d: -f3)
  case "$SERVICES" in
    *"$I_NAME"*) echo "SKIP: service $I_NAME ya existe" ;;
    *) cf create-service "$I_OFF" "$I_PLAN" "$I_NAME" && echo "CREATE: service $I_NAME" ;;
  esac
done
IFS="$OLDIFS"

USERS=$(cf space-users "$EXPECTED_ORG" "$SPACE" 2>&1)
case "$USERS" in
  *"$USER"*) echo "SKIP: rol de $USER ya asignado" ;;
  *) cf set-space-role "$USER" "$EXPECTED_ORG" "$SPACE" SpaceDeveloper && echo "CREATE: rol SpaceDeveloper para $USER" ;;
esac
echo "OK: provision $SPACE"
