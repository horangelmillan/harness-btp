# R3.0 — Trial Landscape Assessment (informe técnico interno)

Fecha: 2026-11-04 · Producto 0.3.2 · Alcance: solo lectura, sin provisión ni despliegue.

## 1. Resumen ejecutivo

- Paisaje Trial verificado de extremo a extremo con CLIs reales: **BTP CLI 2.116.3** (servidor v2.122.2) y **CF CLI v8.19.0** real.
- Cuenta: GA `e1156e9atrial` (TRIAL, Subscription) + 1 subcuenta `trial` (us10, subdomain `e1156e9atrial`).
- CF: 1 org + 1 espacio `dev`, **0 apps, 0 service instances** — paisaje limpio, listo para R3-A.
- Entitlements amplios para Trial (~90 filas): XSUAA (application/broker/space/apiaccess), Destination lite, Connectivity lite, HANA hdi-shared/schema/sbss/securestore + hanatrial securestore, HANA Cloud hana-free/data-lake-free/connection-free, html5-apps-repo app-host/app-runtime, application-logs lite, autoscaler, jobscheduler, IAS application, Build Work Zone standard, Integration Suite trial + it-rt, BAS suscrito.
- Restricción principal: **Application Runtime MEMORY = 4 GB** (cuota org: 4G total, 20 app instances, 10 rutas, 400 svc instances).
- Hallazgo local R2.3 **resuelto con matiz**: `cf` en PATH sigue siendo shim node 1.0.0-beta.25, pero existe **CF CLI real** en `C:\Program Files\Cloud Foundry\cf.exe` + `cf8.exe` (v8.19.0, plugin multiapps 3.12.0). El harness debe invocar el binario real o ajustar PATH.
- `btp` no está en PATH; binario real en `C:\Users\Horan\tools\SAP\btp\btp.exe`. Carencia del harness: sin wrapper/skill `btp` (solo `sap-verify` clasifica, no ejecuta `btp get/list`).
- Clasificación general: **READY WITH LIMITATIONS** (R3-A/R3-C/R3-D/R3-F-sqlite ejecutables; R3-B/R3-E condicionados a HANA Cloud free/IAS).

## 2. Identificación del paisaje

| Dato | Valor (evidencia) |
|---|---|
| CF API | `https://api.cf.us10-001.hana.ondemand.com` (API v3.233.0, `cf api`) |
| CF org / space | `e1156e9atrial` / `dev` (`cf target`) |
| BTP CLI servidor | `https://cli.btp.cloud.sap` (server v2.122.2, `btp --info`) |
| GA | `e1156e9atrial`, id `bcd66dad-…`, subdomain `e1156e9atrial-ga`, license TRIAL |
| Subcuenta | `trial`, id `405073b1-…`, región us10, subdomain `e1156e9atrial` |
| CF landscape | `cf-us10-001`, env instance `446FC82B-…` estado OK |
| Usuario | `horangelmillan@gmail.com` en ambas CLIs (misma cuenta) |

## 3. Estado de autenticación

- **BTP CLI**: cliente 2.116.3, SSO vigente (`btp --info` muestra usuario + target GA sin re-login). Config en perfil usuario (no se imprime por contener secretos).
- **CF CLI real**: v8.19.0, sesión vigente (`cf target` → user/org/space sin re-auth).
- Correspondencia: ambas apuntan al mismo paisaje us10 / misma GA. Sin expiración.
- Nota: `cf` en PATH (`C:\nvm4w\nodejs\cf.ps1`) es el paquete npm `cf` 1.0.0-beta.25, NO CF CLI. Usar ruta absoluta al binario real.

## 4. Global Account y subcuentas

- GA `get accounts/global-account`: commercial model Subscription, license TRIAL, state OK.
- Única subcuenta en la GA: `trial` (us10, beta-enabled false, state OK). Sin directorios intermedios relevantes.
- Target BTP actual: GA (no hay subcuenta fijada; los comandos usan `--global-account/--subaccount` explícitos — no se cambió el target).
- Trust visible: `sap.default` (Business and platform users) Active. No se modificó.

## 5. Inventario de entitlements (subcuenta trial, `list accounts/entitlement`)

Extracto relevante (cuota asignada; consumo no expuesto por la CLI → NOT VERIFIED):

| Servicio técnico | Plan | Cuota |
|---|---|---|
| APPLICATION_RUNTIME | MEMORY | 4 (GB) |
| xsuaa | application / broker / space / apiaccess | 1 c/u |
| destination | lite | 1 |
| connectivity | lite / connectivity_proxy | 1 c/u |
| hana | hdi-shared / schema / sbss / securestore | 10 c/u |
| hanatrial | securestore | 1 |
| hana-cloud | hana-free / relational-data-lake-free / hana-cloud-connection-free | 1 c/u |
| hana-cloud-tools | tools | 1 |
| html5-apps-repo | app-host / app-runtime | 1 c/u |
| application-logs | lite | 1 |
| autoscaler | standard | 1 |
| jobscheduler | free | 1 |
| identity | application | 1 |
| sap-identity-services-onboarding | default | 1 |
| build-workzone-standard | standard | 100 |
| it-rt | integration-flow / api | 2 / 1 |
| integrationsuite-trial | trial | 1 |
| process-automation-service | standard (+ free) | 1 |
| postgresql-db / redis-cache | trial | 1 c/u |
| alert-notification | standard | 1 |
| credstore | trial / proxy | 1 c/u |
| cloudfoundry / kymaruntime | trial | 1 c/u |
| abap-trial | shared | 1 |

Resto (~30 filas: traduction, extraction, tickets, NER, DAR, mobile lite, theming, transport, auditlog, cis, service-manager, saas-registry, sap-graph, workzone-apps, BAS…) con cuota 1–10 según tipo. Lista completa verificable re-ejecutando el mismo comando (salida ~90 filas).

## 6. Marketplace y planes (espacio dev, `cf marketplace` + `btp list services/plan --environment cloudfoundry`)

- 29 offerings en subcuenta; ~50 offerings visibles en marketplace CF (incluye backing services cf-us10-001: postgresql-db trial, redis-cache trial, application-logs lite, autoscaler, connectivity lite, jobscheduler free).
- Planes CF clave confirmados: xsuaa `application/broker/space/apiaccess`, destination `lite`, connectivity `lite`, hana `hdi-shared/schema/sbss/securestore`, hanatrial `securestore`, hana-cloud `hana-free/relational-data-lake-free/hana-cloud-connection-free`, html5-apps-repo `app-host/app-runtime`, identity `application`, alert-notification `standard`.
- Regla cumplida: offering en marketplace ≠ entitlement ≠ instancia. Aquí: entitlements SÍ asignados, instancias = 0 (ver §7/§8).

## 7. Inventario Cloud Foundry (binario real v8.19.0)

- Orgs: 1 (`e1156e9atrial`). Spaces: 1 (`dev`). Roles no enumerados (lectura `cf org-users` omitida por brevedad; permisos del usuario: lectura+escritura efectiva demostrada).
- Apps: **0** (`cf apps` → No apps found). Rutas: 0. Aisladas: segmento `trial` (default).
- Service instances: **0** (`cf services` + `btp list services/instance` → 0 entries).
- Dominios: `cfapps.us10-001.hana.ondemand.com`, `cert.cfapps.us10-001.hana.ondemand.com`, `apps.internal` (todos shared).
- Cuota org (`cf quota …-t-…`): 4G memoria total, 16G instance memory, 10 rutas, 400 svc instances, 20 app instances, paid plans allowed.
- Plugins: `multiapps 3.12.0` (bg-deploy/deploy/mta/mta-ops/mtas) — despliegue MTA disponible.

## 8. Servicios disponibles (efectivo)

| Servicio | Offering | Entitlement | Instancias | Disponible para crear |
|---|---|---|---|---|
| XSUAA | xsuaa | Sí (4 planes) | 0 | Sí |
| Destination | destination | Sí (lite) | 0 | Sí |
| Connectivity | connectivity | Sí (lite) | 0 | Sí (+Cloud Connector externo, no instalado) |
| HANA HDI | hana / hanatrial | Sí | 0 | Sí (hdi-shared contra HANA existente; sin HANA aprovisionada → condicionado) |
| HANA Cloud | hana-cloud | Sí (free) | 0 | Sí (plan free, arranque bajo demanda) |
| HTML5 repo | html5-apps-repo | Sí | 0 | Sí |
| Logging | application-logs | Sí (lite) | 0 | Sí |
| Autoscaler/jobs | autoscaler/jobscheduler | Sí | 0 | Sí |
| IAS | identity | Sí (application) | n/a (tenant default) | Integración vía trust existente |
| Workzone/Build Apps | build-workzone-standard/sap-build-apps | Sí | 0 (SaaS) | Suscripción posible |
| BAS | sapappstudiotrial | — | — | **SUBSCRIBED** (URL trial.applicationstudio activa) |

## 9. Evaluación XSUAA — AVAILABLE (no verificado en runtime, sin instancias)

- Servicio + 4 planes con cuota. Marketplace expone broker con los 4 planes.
- 0 instancias: OAuth/scopes/role-collections configurables al crear `application` (R3-C). Sin crear recursos hoy: lectura de planes = evidencia; runtime (token/scopes/CAP `@(requires)`) pendiente de R3-C.
- Capacidad harness: `validate-app` (estática xs-security) + `cap-cli` + plantillas CAP con xsuaa. Suficiente para R3-C.

## 10. Evaluación IAS — PARTIALLY AVAILABLE

- Entitlement `identity application` + onboarding default; trust `sap.default` Active.
- Sin visibilidad de tenant/usuarios de prueba desde CLI (requiere cockpit/admin IAS → NOT VERIFIED).
- R3-E ejecutable parcial: trust XSUAA↔IAS por defecto usable; custom IAS config fuera de alcance (no modificar trust).

## 11. Evaluación Destination — AVAILABLE (sin instancias)

- Offering + plan lite con cuota; broker `sm-destination-…` en marketplace.
- 0 instancias, 0 destinations visibles desde CLI (requieren instancia + binding → no creados por §11/§13).
- R3-D: crear instancia lite + destino HTTP/OAuth posible; harness `deploy-cf` + `cf-safe` (allowlist `services/marketplace`) lo soportan.

## 12. Evaluación Connectivity — PARTIALLY AVAILABLE

- Servicio lite + proxy con cuota; broker CF presente; security groups del espacio incluyen `connectivity-agent-security-group`.
- Cloud Connector: concepto distinto del servicio; no instalado localmente (NOT VERIFIED); Trial admite Cloud Connector con límites.
- R3-E: destinos on-prem reales requieren Connector → condicionado; conectividad cloud-cloud (lite) sí probables en R3-D.

## 13. Evaluación HANA Cloud y HDI — PARTIALLY AVAILABLE

- Entitlements: hana-free + data-lake-free + connection-free + tools; hana hdi-shared/schema (×10) + hanatrial securestore.
- Sin instancias (0). `hana-cloud hana-free` permite aprovisionar HANA bajo demanda en Trial (documentado; no ejecutado por §11).
- R3-B condicionado a crear instancia hana-free (provisión permitida en R3, no en este inventario). `cds deploy --to hana` validable entonces; hoy: NOT VERIFIED en runtime. HDI-shared requiere HANA base existente.
- Harness: `cap-cli`/`mta-build` + plantillas con hdi-container; `validate-app` estático OK.

## 14. Evaluación Approuter — AVAILABLE (vía planes)

- `app-front developer` + html5-apps-repo ambos planes con cuota; Node.js runtime vía Application Runtime.
- Sin app desplegada: enrutamiento+XSUAA+Destination validable en R3-D/R3-F. Harness: plantillas approuter (auditadas T5.x) + `deploy-cf` + `cf-safe`.

## 15. Evaluación MTA — AVAILABLE

- MBT real **1.2.50** (`mbt.ps1` vía pnpm) + CF CLI v8.19.0 + plugin multiapps 3.12.0 (`deploy/mta/mta-ops/mtas`, bg-deploy).
- `mta.yaml` CF válido ya usado en demos locales (T5). Sin despliegue hoy por §13. R3-A puede usar `mbt build + cf deploy` con binarios reales.

## 16. Herramientas locales

| Herramienta | Versión/estado | Nota harness |
|---|---|---|
| Node.js / npm | v24.22.1 / 11.19.1 | OK |
| Git | 2.49.0 | OK, árbol limpio |
| BTP CLI | 2.116.3 (en `tools/SAP/btp/`, NO en PATH) | Invocar por ruta absoluta; carencia wrapper documentada |
| CF CLI | **v8.19.0** (`Program Files\Cloud Foundry\cf.exe/cf8.exe`) + multiapps 3.12.0 | OK; `cf` en PATH es shim node beta → no usar |
| MBT | 1.2.50 | OK |
| Java | Temurin 17.0.19 | OK (CAP Java opcional) |
| Maven (`mvn`) | No instalado | Solo necesario si R3 usa Java; Node CAP no lo exige |
| `cds` | No en PATH; `npx @sap/cds-dk` falló (sin ejecutable offline) | PENDIENTE: instalar `npm i -g @sap/cds-dk` o documentar uso vía npx con red; bloquea R3-A hasta resolver |
| UI5 tooling | NOT VERIFIED (no comprobado) | PENDIENTE menor (R3-F) |

## 17. Restricciones del Trial (vs harness/entorno)

1. **Trial**: memoria 4G total; 20 app instances; 10 rutas; expiración/suspensión de recursos trial; HANA Cloud solo planes free; sin garantías de uptime.
2. **Permisos**: usuario con lectura amplia + env CF OK; trust/usuarios IAS fuera de visibilidad CLI.
3. **No contratado**: Kyma trial disponible pero innecesario; ABAP shared ajeno a R3.
4. **Entorno local**: shim `cf` beta en PATH (confusión R2.3), `btp` fuera de PATH, `cds`/`mvn` ausentes — deficiencias locales, NO del harness ni del Trial.
5. **Harness**: sin wrapper `btp` (documentado §18); cobertura CF real vía `cf-safe`/`cf-cli` SÍ existe (hallazgo researcher). Nada atribuible al harness que sea del Trial.

## 18. Compatibilidad con harness-btp (capacidades reales, rutas)

- Lectura CF real: `AI/scripts/cf-safe.ps1` + `cf-safe-client.ps1` + `AI/docs/cf-safe.md` y skill `AI/skills/cf-cli/SKILL.md` (denylist login/secretos, JSON). Usar con `CF_BIN` apuntando al exe real.
- Pre-provisión: `AI/scripts/provision-espacio.template.ps1/.sh` (SKIP/CREATE idempotente).
- Detección CLIs: `AI/scripts/check-prereqs.ps1/.sh` (ya avisa si `cf` no es Cloud Foundry — caso actual).
- Post-deploy: `AI/agents/deploy-cf.md` (`cf apps/logs`, confirmación target).
- Clasificación servicios: `AI/skills/sap-verify/SKILL.md` (Documentado/Pendiente/Coste).
- Estática: `AI/scripts/validate-app.ps1/.sh`, `pre-commit-check`, skills `cap-cli`/`mta-build`.
- **Carencia real**: sin skill/script `btp` para subcuentas/entitlements/planes (`sap-verify` no ejecuta `btp get/list`). Registrar como oportunidad (no crear en este inventario por §13).

## 19. Matriz de capacidades

| Capacidad | Estado | Evidencia |
|---|---|---|
| CAP (compilar/validar/desplegar) | PARTIALLY AVAILABLE | Estática OK (T5.x); runtime CF OK (cuota+buildpacks por verificar en R3-A); `cds` pendiente instalar |
| SAPUI5 (build/deploy) | PARTIALLY AVAILABLE | html5-apps-repo ambos planes; tooling local NOT VERIFIED |
| OData V4 | PARTIALLY AVAILABLE | Sin app; desplegable en R3-A |
| XSUAA | AVAILABLE | 4 planes + cuota (runtime en R3-C) |
| IAS | PARTIALLY AVAILABLE | Trust default Active; admin tenant NOT VERIFIED |
| Destination | AVAILABLE | Plan lite + cuota (instancia en R3-D) |
| Connectivity | PARTIALLY AVAILABLE | lite OK; Cloud Connector ausente |
| HANA Cloud | PARTIALLY AVAILABLE | Planes free + cuota; sin instancia (R3-B) |
| HDI | PARTIALLY AVAILABLE | hdi-shared/schema ×10; requiere HANA base |
| Approuter | AVAILABLE | app-front + html5 repo (runtime en R3-D/F) |
| MTA | AVAILABLE | MBT 1.2.50 + cf 8.19 + multiapps 3.12 |
| CF ops | AVAILABLE | target/org/space/domains/quotas/apps/services verificados hoy |

Ningún AVAILABLE afirma runtime sin instancia — solo disponibilidad de planes + herramienta.

## 20. Plan de pruebas R3 (ordenado, priorizado)

### R3-A — CF + despliegue básico (CAP + Node + OData V4) · PRIORIDAD 1
- Prerrequisitos: instalar/resolver `cds` (`npm i -g @sap/cds-dk`), usar `cf.exe` real, espacio `dev` (vacío OK).
- Servicios: Application Runtime (MEM 4G). Entitlements: ya asignados.
- Harness: `cap-cli` (scaffold Books), `validate-app`, `mta-build`, `deploy-cf`, `cf-safe`, `check-prereqs`.
- Operaciones: scaffold → `cds compile` → `npm test` → `mbt build` → `cf push`/`cf deploy` (1 app, 256–512M) → `cf apps/logs`.
- Evidencia: app STARTED + ruta `…cfapps.us10-001…` + CRUD OData + logs. Aceptación: HTTP 200/201/404 + `validate-app` PASS.
- Restricciones: 4G totales (usar 1 app pequeña); shim `cf` no usar.

### R3-B — Persistencia (CAP + HANA Cloud + HDI) · PRIORIDAD 2 (condicionada)
- Prerrequisitos: R3-A verde + crear instancia `hana-cloud hana-free` (+ espera de aprovisionado).
- Entitlements: hana-free/data-lake-free/connection-free, hana hdi-shared/schema.
- Harness: `cap-cli` (perfil hana), `mta-build` (hdi-container), `deploy-cf`.
- Operaciones: crear instancia → binding → `cds deploy --to hana` → validar tablas/HDI.
- Aceptación: lectura/escritura CAP contra HANA. Riesgo: tiempos de provisión trial; fallback SQLite documentado (no como éxito).

### R3-C — Seguridad (XSUAA + OAuth + roles/scopes) · PRIORIDAD 1
- Prerrequisitos: R3-A (app base).
- Servicios: xsuaa `application` (+ broker). Sin coste adicional.
- Harness: plantillas xs-security (`validate-app`), `cap-cli` (`@(requires)`), `sap-verify`.
- Operaciones: crear instancia xsuaa application → xs-security.json + role-templates → bind → probar 401 sin token / 200 con token + scopes.
- Aceptación: 401/403/200 según rol; `validate-app` seguridad PASS.

### R3-D — Enrutamiento (Approuter + Destination) · PRIORIDAD 1
- Prerrequisitos: R3-C verde.
- Servicios: destination lite, html5-apps-repo app-host/app-runtime.
- Operaciones: instancia destination lite → destino HTTP test → approuter + xsuaa binding → ruta protegida → consumo destino desde CAP.
- Aceptación: login via approuter + destino responde (sin exponer secretos).

### R3-E — Identidad y conectividad (IAS + Connectivity) · PRIORIDAD 3 (si el entorno lo permite)
- Prerrequisitos: R3-D. Trust `sap.default` intacto (no modificar).
- Servicios: identity application, connectivity lite. Cloud Connector solo si se instala.
- Aceptación parcial: login IAS por defecto + conectividad cloud-cloud; on-prem solo con Connector (documentar si no disponible).

### R3-F — Integración full-stack · PRIORIDAD 2 (tras A+C+D)
- Stack: CAP + UI5 + OData V4 + HANA (si B verde, si no SQLite declarado) + HDI + XSUAA + Approuter + Destination + MTA.
- Operaciones: `mbt build` único → `cf deploy` → E2E (HTTP + QUnit/OPA5 donde aplique).
- Aceptación: cadena completa verde + `validate-app` + matriz documentada.

## 21. Bloqueos y recomendaciones

- **Bloqueos antes de R3-A**: (1) `cds` no disponible offline — instalar `@sap/cds-dk` global o fijar versión en docs; (2) fijar invocación CF/BTP por ruta absoluta o variable `CF_BIN`/`BTP_BIN` (PATH contaminado por shim node).
- **Recomendaciones**: no usar el shim `cf` de node; no fijar target BTP global (usar flags por comando); crear `temp/r30/` para logs (redactados); registrar oportunidad `btp-wrapper` en `docs/improvements/opportunities.md` (deduplicar: `sap-verify` no ejecuta btp); no crear instancias hasta R3-A…F.
- **Problemas del harness**: solo la carencia `btp` (§18); `check-prereqs` ya detecta el `cf` ajeno (correcto); sin falsos positivos nuevos.
- **Resultado**: **READY WITH LIMITATIONS** — comenzar por R3-A (+C/D en secuencia); B condicionado a hana-free; E parcial.

---
*Teams y comandos ejecutados (solo lectura)*: `btp --info/get/list (global-account, subaccount, entitlement, environment-instance, available-environment, services/instance=0, services/offering=29, services/plan --environment cloudfoundry=65, subscription, trust)`; `cf (exe real) api/target/orgs/spaces/apps=0/services=0/domains/marketplace/org/space/quota/plugins`; locales: `node/npm/git/btp/cf/mbt/java` (+`cds/mvn` ausentes, `npx cds-dk` fallido offline). Gates: `validate-meta.js` 58 OK, `render --check` 61 OK, `check-package` 178 limpio, `bump-version --check` 0.3.2. Sin credenciales impresas; sin mutaciones (1 archivo informe pendiente de revisión).
