# app-local-demo

Demo mínima CAP + SQLite ejecutable en local, sin BTP ni secretos.

## Ejecución local

1. `npm install` en esta carpeta (fija `@sap/cds` 10.2.2 + `@cap-js/sqlite`
   3.1.2 vía `package-lock.json`).
2. `npm test` → 8 pruebas (`node --test test/books.test.js`): auth 401 sin
   credenciales, CRUD completo contra SQLite `:memory:` (el test arranca su
   propio `cds serve` en 4004 y lo detiene al cerrar).
3. Manual: `npx -p @sap/cds-dk cds serve --port 4004 --in-memory` → servicio
   en `http://localhost:4004/odata/v4/catalog/Books`.
4. `npx -p @sap/cds-dk cds compile srv/service.cds --to edmx` → EDMX en stdout.

## Auth local (mock, nivel MOCK)

`@(requires: 'Viewer')` en `srv/service.cds` se verifica con usuarios mock
solo-`[development]` en `package.json` (`reader`/`writer`, passwords dummy
iguales al usuario, patrón estándar CAP como en bookshop): sin credenciales
→ 401; con rol → 200/201; la distinción `Viewer` vs `Editor` a nivel de
operación se aplica en BTP (ruta `xs-app.json` con `scope`), no en local.

Nota: `cds test` nativo exige el paquete `@cap-js/cds-test` (no instalado
por diseño para mantener la demo sin dependencias extra); `npm test` usa el
runner built-in `node --test`, determinista y sin dependencias nuevas.
La primera ejecución de `npm test` requiere red (npx cachea `@sap/cds-dk`);

## Niveles de evidencia

| Nivel | Qué es | Comando |
|---|---|---|
| LOCAL | Estático + build/test en tu máquina | `validate-app.ps1`, `cds compile`, `npm test` |
| MOCK | Servicios simulados (SQLite, mocks XSUAA) | `cds serve`, usuarios mock dev |
| BTP | Trial/dev real con `cf target` verificado | `/verify` + `deploy-cf` + `e2e-fiori` |

Sin credenciales en el repo: `xs-security.json` solo declara scopes/roles.
