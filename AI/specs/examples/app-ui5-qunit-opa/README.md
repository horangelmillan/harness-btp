# app-ui5-qunit-opa (R2.2)

Fixture UI5 (OData V4) + QUnit unit puro + OPA5 journey CRUD contra CAP local
(`--in-memory`, SQLite volátil). Hermana de `app-local-demo`: no la extiende
ni depende de `temp/`; forma reutilizada de `temp/t55-demo` (vista
rápida, no dependencia).

## Contenido

- `db/schema.cds` + `srv/service.cds`: `Books{ID UUID, title String,
  stock Integer}` sin `@requires` (navegador sin login; el runtime sigue
  siendo autoridad 400/404).
- `app/`: UI5 con OData V4 `/odata/v4/catalog/` + routing
  lista/detalle/crear (namespace `qunit.books`).
- `app/model/formatter.js`: lógica pura espejo de controllers (0 fetch).
- `app/test/unit/`: QUnit puro (13 asserts reales sobre formatter).
- `app/test/integration/`: journey OPA5
  carga→lista→crear(UUID por timestamp)→detalle→PATCH stock→DELETE→lista
  sin el título; `pages.js` con page objects.
- `app/test/testsuite.qunit.html`: índice de ambas suites.
- `test/books.test.js`: categoría HTTP backend (CRUD + 400/404, fixtures
  UUID + cleanup finally, spawn cap-cli win32 `cmd.exe`, espera GET 200
  90 s/500 ms).
- `scripts/run-ui5-tests.ps1` / `.sh`: únicos runners (ensure CDP →
  CAP → HTTP → QUnit → OPA5 → cleanup try/finally + trap, solo PIDs
  propios, perfil `mvp-cdp-9222` R2.1).
- `scripts/cdp-eval.js`: helper Node-stdlib (fetch + WebSocket global) que
  abre el target en el CDP propio, navega con `Page.navigate` (el
  `/json/new?url=` no navega en headless=new) y sondea `document.title`
  hasta el resumen QUnit. Necesario porque `--dump-dom` a stdout sale
  vacío en este Chrome para páginas de red (verificado: screenshot/pdf a
  fichero sí funcionan).

## UI5 CDN

Pineado a la línea `1.120.x` LTS:
`https://ui5.sap.com/1.120/resources/sap-ui-core.js` (el CDN sirve el
último patch de la línea 1.120; sin patch fijo para no congelar parches
de seguridad — documentado aquí según R2.2-DESIGN).

## Uso

```powershell
npm install
npm test                                   # solo HTTP backend (puerto 4022)
powershell -ExecutionPolicy Bypass -File scripts/run-ui5-tests.ps1
sh scripts/run-ui5-tests.sh                # par Unix
```

Requiere internet (CDN UI5) y Chrome para las suites de navegador; sin
ellos, `npm test` sigue en verde y el runner reporta el bloqueo sin
simular resultados.
