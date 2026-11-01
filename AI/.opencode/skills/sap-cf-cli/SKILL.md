---
name: sap-cf-cli
description: Uso seguro del CLI de Cloud Foundry como sap_cf en Windows
---

# CLI Cloud Foundry (`sap_cf`)

En [TU_PC] `cf` es el CLI de **Cloudflare**. Cloud Foundry se invoca
**siempre** como `sap_cf` (`sap_cf.cmd`, ruta de instalación de
Cloud Foundry CLI en [TU_PC]; verificado en Windows, adapta rutas).

## Lectura segura (sin secretos)

```
sap_cf target          # endpoint / org / espacio actuales
sap_cf api             # endpoint y versión API
sap_cf orgs            # solo nombres
sap_cf spaces          # solo nombres
sap_cf apps            # estado observable (started/stopped, rutas)
sap_cf services        # instancias visibles
sap_cf logs <app> --recent
```

`target`, `api`, `orgs`, `spaces` y `app <nombre>` nunca muestran tokens.
Si una salida incluyera un secreto, redáctalo antes de citarla.

## Mutaciones (solo `deploy-cf`, con destino confirmado)

- Confirmar endpoint/org/espacio contra la spec **antes** de cada despliegue.
- `sap_cf push` para apps simples; `sap_cf deploy <archivo>.mtar` para MTA
  (requiere plugin `multiapps`, no instalado: ver skill `mta-build`).
- Verificar después: `sap_cf apps` + `sap_cf logs <app> --recent` + URL.

## Denylist

- `cf ...` para cualquier operación Foundry.
- Borrar o renombrar orgs, espacios, apps o servicios fuera del MVP.
- `sap_cf login`/re-autenticaciones no solicitadas (si la sesión caduca,
  pedir al usuario el flujo interactivo, nunca credenciales en texto).
- `--var`/`--vars-file` con secretos en shell compartida; usar archivos ya
  ignorados por Git y no citar sus valores.
