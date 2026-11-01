---
name: mta-build
description: Construir y verificar artefactos MTAR con mbt en este equipo
---

# Build MTA (`mbt`)

`mbt` es Cloud MTA Build Tool 1.2.50 (verificado 2026-10-29). Invocarlo
siempre como `mbt`, nunca como `cf` ni rutas inventadas.

## Flujo

```
mbt build                # requiere mta.yaml en la raíz del proyecto
```

- El `.mtar` resultante queda en `mta_archives/` con el nombre/versión de
  `mta.yaml`. Comprobar existencia y fecha antes de desplegar.
- Para módulos Node.js, `mbt` ejecuta `npm install`/`npm run build` según
  `mta.yaml`; para Java necesita Maven (`mvn` no instalado: documentar como
  pendiente si una spec lo exige).
- `mbt build --help` para flags (`--mtar`, `--platform=cf`).

## Despliegue del MTAR

`sap_cf deploy <archivo>.mtar` requiere el **plugin multiapps**. Verificar
siempre con `sap_cf plugins` antes de asumir su ausencia (2026-10-30 resultó
ya instalado contra lo documentado). Instalarlo solo cuando un MVP necesite
despliegue MTA:

```
sap_cf install-plugin -r CF-Community multiapps
```

Alternativa sin plugin para MVPs simples: `sap_cf push` por app según plan.

## Notas

- El binario `mbt.exe` se obtuvo con el propio `install.js` del paquete npm
  (`node install.js cloud-mta-build-tool`). Si `mbt` vuelve a fallar tras
  una actualización global, repetir ese comando en el directorio del paquete.
- Nunca versionar `mta_archives/*.mtar` ni `default-services.json` con claves.
- `mbt` exige `make` en `%PATH%` (ver `AGENTS.md` § Disciplina de shell y
  CLIs): si falla `exec: "make": executable file not found`, anteponer el
  `bin` de ezwinports/GnuWin32 al `$env:PATH` solo para el comando.
