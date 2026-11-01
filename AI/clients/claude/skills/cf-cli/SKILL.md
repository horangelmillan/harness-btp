---
name: cf-cli
description: Uso estándar del CLI de Cloud Foundry (cf)
---

# CLI Cloud Foundry (`cf`)

El CLI de Cloud Foundry se invoca como `cf`, resuelto por máquina: si
existe `$env:CF_BIN` (mapeo local en `~/.harness/local.ps1` o
`$HOME/.harness/local.sh`, NO versionado) se usa ese binario; si no, `cf`.
Verificar una vez por sesión con `Get-Command` antes del primer comando CF
del turno. Nunca transcribir el mapeo en `AGENTS.md` ni en la spec.

## Lectura segura (sin secretos)

```
cf target          # endpoint / org / espacio actuales
cf api             # endpoint y versión API
cf orgs            # solo nombres
cf spaces          # solo nombres
cf apps            # estado observable (started/stopped, rutas)
cf services        # instancias visibles
cf logs <app> --recent
```

`target`, `api`, `orgs`, `spaces` y `app <nombre>` nunca muestran tokens.
Si una salida incluyera un secreto, redáctalo antes de citarla.

## Mutaciones (solo `deploy-cf`, con destino confirmado)

- Confirmar endpoint/org/espacio contra la spec **antes** de cada despliegue.
- `cf push` para apps simples; `cf deploy <archivo>.mtar` para MTA
  (requiere plugin `multiapps`, no instalado: ver skill `mta-build`).
- Verificar después: `cf apps` + `cf logs <app> --recent` + URL.

## Denylist

- Borrar o renombrar orgs, espacios, apps o servicios fuera del MVP.
- `cf login`/re-autenticaciones no solicitadas (si la sesión caduca,
  pedir al usuario el flujo interactivo, nunca credenciales en texto).
- `--var`/`--vars-file` con secretos en shell compartida; usar archivos ya
  ignorados por Git y no citar sus valores.
