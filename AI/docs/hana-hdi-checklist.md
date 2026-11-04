# Checklist SAP HANA Cloud + HDI

> Problema: MVPs con persistencia real en BTP necesitan SAP HANA Cloud +
> contenedor HDI sin secretos en repo ni bindings diseñados ad hoc por MVP.
> Diseño (T4-CD): checklist única + snippet `mta-hdi-snippet.yaml`;
> modelo híbrido MTA+CLI de `AI/AGENTS.md` (managed vs existing-service,
> referencias por nombre).
> Dependencias: servicio `hana` (plan `hana-free` para trial/dev,
> `hdi-shared` para el contenedor); `sap-verify` para clasificar
> disponibilidad/coste/entitlements del espacio.

## 1. Instancia `hana` (plan `hana-free`)

- Plan `hana-free` es el default del snippet: válido para trial/dev con un
  MVP; otros planes solo si el paisaje lo exige (más capacidad, alta
  disponibilidad) — verificar entitlements del espacio con `sap-verify`
  antes de cambiarlo, sin universalizar (trial ≠ productivo).
- Si la subcuenta ya dispone de instancia HANA compartida, enlazarla como
  `existing-service` en vez de crearla (ver nota en el snippet); se crea una
  vez por espacio, nunca una por deploy.

## 2. Contenedor HDI (`hdi-shared` vs schema)

- Recurso `mvp-hdi` tipo `com.sap.xs.hdi-container` con `service: hana`,
  `service-plan: hdi-shared` (ver snippet).
- `hdi-shared` (contenedor aislado por paisaje, gestionado por el deploy)
  frente a schema dedicado/manual: preferir `hdi-shared` salvo que la spec
  exija datos compartidos entre paisajes — entonces se registra como
  decisión en la spec, no como improvisación en el `mta.yaml`.
- Cero secretos: el binding inyecta credenciales vía VCAP; nunca literales
  en repo (`AI/AGENTS.md` § Git).

## 3. Módulo desplegador `hdb` (Exit 0)

- Módulo `mvp-hdb` tipo `hdb`, `path: gen/db` (salida de `cds build --for
  hana`), `requires: mvp-hdi` (ver snippet y referencia `temp/r3a/books`).
- El deployer debe terminar con Exit 0; si falla, no seguir al despliegue
  del srv: revisar logs del módulo `hdb` (artefactos `.hdbtable`/`.hdbview`
  inválidos, namespace del contenedor).
- Verificar en local que `db/` compila (`cds build`) antes de desplegar;
  `gen/` es salida generada, no fuente versionable del MVP.

## 4. Binding CAP (`[production]` + `requires`)

- En CAP, perfil `[production]` con `cds.requires.db: { kind: "hana" }`;
  en dev se mantiene SQLite por defecto (cero coste local).
- Módulo `mvp-srv` declara `requires` por nombre a `mvp-hdi` (binding
  nativo); el runtime lee solo binding/VCAP, nunca keys.
- Keys rotadas por deploy: las keys son solo de diseño (temporal borrable,
  solo nombre documentado); el runtime NUNCA lee keys
  (`AI/AGENTS.md` § Modelo híbrido).

## 5. Esquema y evolución

- Cambios de esquema versionados en `db/` (entidades CDS); el deployer HDI
  aplica deltas sin borrar los datos del contenedor.
- Nombre/URL aún desconocidos en paisaje nuevo → placeholder que no rompa
  el deploy, registrado como `TODO(<paisaje>)` en la spec; se fija tras
  conocerlos (misma regla que destinos versionados).
- Si el contenedor se recrea (cambio de plan/espacio), los datos se
  pierden: la spec lo declara y el E2E resiembra tras el deploy.

## 6. Verificación

- Puerta `/verify`: `mbt mtad-gen -e <paisaje>.mtaext` por cada `.mtaext`
  afectado + instancia esperada existe (comando o cockpit, nunca heredada
  de notas).
- E2E: CRUD contra el srv (POST → 201) y los datos **persisten tras
  restart** de la app — a diferencia de SQLite `:memory:`, que se vacía en
  cada redeploy/restart (`AI/AGENTS.md` § Paisajes).
- Nunca afirmar persistencia OK sin E2E con restart incluido.
- Snippet validado con mbt mtad-gen 2026-11-04 (fixture aislada, descriptor con mvp-hdb/mvp-srv → mvp-hdi y recursos hana/hdi-shared, exit 0).

## Fuentes oficiales (verificadas 2026-11-04)

| Tema | URL oficial | Qué cubre |
|---|---|---|
| SAP HANA Cloud en BTP | https://help.sap.com/docs/btp/sap-business-technology-platform/sap-hana-cloud | Servicio `hana`, planes (`hana-free`), entitlements |
| HDI reference | https://help.sap.com/docs/SAP_HANA_PLATFORM/6a79c7d7a5c84461bbd805a2f5cbd86e4/sap-hana-deployment-infrastructure-reference.html | Contenedores HDI, `hdi-shared`, deployer `hdb` |
| CAP + HANA (Node.js) | https://cap.cloud.sap/docs/node.js/databases | Binding `cds.requires.db`, `kind: "hana"`, perfil `[production]` |
| MTA + Cloud Foundry deploy | https://help.sap.com/docs/btp/sap-business-technology-platform/multitarget-applications-in-cloud-foundry | Módulo `hdb`, `managed-service` vs `existing-service`, `.mtaext` por paisaje |

Verificación 2026-11-04: `curl.exe` GET (`-L`, timeout 20 s, las 4 con
HTTP 200; una 5ª candidata `cap.cloud.sap/docs/guides/databases-hana`
devolvió 404 y se descartó) en esta máquina; `AI/scripts/check-docs.ps1` tiene lista fija y
no cubre estas URLs, por eso se verificaron por fuera (sin secretos, solo
GET anónimo).
