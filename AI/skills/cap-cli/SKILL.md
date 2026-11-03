---
name: cap-cli
description: Invocación verificada del CLI de CAP y facets en este equipo
---

# CLI de CAP (`cds`)

Nombres verificados el 2026-10-29 (docs cap.cloud.sap vía `context7`;
paquete `@cap-js/cds-dk` **no existe** — el correcto es `@sap/cds-dk`):

- CLI solo vía `npx -p @sap/cds-dk cds ...` (el `node_modules` del proyecto
  no incluye el ejecutable `cds`; `npx cds` a secas falla).
- Runtime del proyecto: `@sap/cds` v10 + `@cap-js/sqlite` v3 (SQLite solo
  para dev local; sin persistencia en CF).
- Scaffold: `npx -p @sap/cds-dk cds init <nombre> --nodejs` (no global).
- Facets usadas en este harness: `mta xsuaa approuter html5-repo
  destination ui5` (lista completa real con `cds add --help`, no de memoria).
- Tras `cds add`, siempre `npm install` antes del siguiente comando.
- SQLite local NO enforcea `String enum` ni `@assert.unique` (DDL sin
  CHECK/UNIQUE verificado en T5.2 con `@sap/cds` 10.2.2 + `@cap-js/sqlite`
  3.1.2): valida enums/unicidad en handlers `before CREATE/UPDATE`
  (400/409), no confíes en el runtime.
- `cds add` es aditivo y genera `mta.yaml`/`xs-security.json`: revisar el
  diff antes de aceptar lo generado (nombres de instancia deben coincidir
  con las existentes en la subcuenta).
- Estados terminales: mapa `TRANSITIONS = { OPEN: [...], ... }` (terminales
  sin salidas) + guarda `RESOLVED` exige `resolvedAt >= createdAt`, resto
  rechaza `resolvedAt/resolutionNotes` (400). Ejemplo de forma, no copiar
  datos de la app de referencia.

## Patrón suite aislada (forma, no copiar datos)

- Puerto propio: `const PORT = Number(process.env.PORT || 4011)` (env con
  fallback; nunca literal fijo sin env).
- Arranque: `spawn('npx', ['-p', '@sap/cds-dk', 'cds', 'serve', '--port',
  String(PORT), '--in-memory'], { ..., shell: process.platform === 'win32' })`.
- Espera lista: bucle `GET /Assets` hasta 200 con `Array.isArray(json.value)`,
  timeout 90 s, reintento 500 ms.
- Fixtures propias: `mkAsset()`/`mkRequest(assetID)` con seriales únicos
  (`randomUUID`), `cleanup(reqID, assetID)` con `DELETE` tolerante a fallos.
- Cada `it` envuelve en `try { ... } finally { await cleanup(...) }`.
- Cierre: `after` mata solo el PID propio (`taskkill /pid <pid> /t /f` en
  win32, `SIGTERM` en unix; guarda `exitCode !== null`).
