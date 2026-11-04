# Roadmap fuente de verdad — harness-btp

**Estado al:** 2026-11-04  
**Versión del producto:** 0.3.2  
**Estado global:** R3.0 completada (`READY WITH LIMITATIONS`); R3.0.1 completada 2026-11-04; R3-A completada 2026-11-04 (desplegada y verificada); R3-C completada 2026-11-04 (401/403 runtime + roles asignados); R3-D completada 2026-11-04 (200 con rol vía approuter). R3-B, R3-E a R3-F pendientes.

## Propósito y continuidad

Este documento conserva el orden del roadmap, el estado conocido de las fases, sus evidencias y los pendientes que deben retomarse. Es un índice de continuidad: no sustituye los informes de fase, el backlog ni el registro de oportunidades.

Al retomar el trabajo, leer este documento y sus fuentes; comprobar el checkout, rama y cambios locales; continuar desde R3-A (verificar prerrequisitos con el mapeo local y re-inventariar el paisaje antes de cualquier acción); actualizar este documento y el backlog al cerrar cada fase; y, al terminar R3, volver a los pendientes anteriores de §6 antes de declarar terminado el roadmap global.

## Estado resumido

| Orden | Fase | Estado | Evidencia / condición |
|---:|---|---|---|
| 1 | P0, P1, P2 y trabajo T-P2 | COMPLETADAS según backlog | Auditoría inicial, gobernanza, inteligencia y estrategia de pruebas; referencias en backlog y `docs/engineering/`. |
| 2 | T3, T3.1 | COMPLETADAS | Flujo autónomo y validación operativa resumidos en backlog. |
| 3 | T4 / T4.1 | Registro parcial | El backlog documenta T4-E/F/G. No hay evidencia suficiente aquí para afirmar una fase independiente T4.1; confirmar en artefactos históricos si esa granularidad importa. |
| 4 | T5, T5.1–T5.5 y cierres | COMPLETADAS según backlog | Ingeniería de aplicaciones y demos, con límites E2E/BTP descritos en cada entrada. |
| 5 | R1 | COMPLETADA según informes disponibles | Madurez/distribución y cierres de seguridad/paquete descritos en historial. |
| 6 | R2.1–R2.4 | COMPLETADAS | CDP, QUnit/OPA5, matriz de compatibilidad, ejemplo OpenCode y telemetría local. |
| 7 | R3.0 | COMPLETADA — READY WITH LIMITATIONS | Inventario Trial de solo lectura; ver [`trial-landscape-assessment.md`](../r3/trial-landscape-assessment.md). |
| 8 | R3.0.1 | COMPLETADA 2026-11-04 | Preparación operativa local verificada viva; ver § R3.0.1 y backlog. |
| 9 | R3-A | COMPLETADA 2026-11-04 (desplegada y verificada) | App Books STARTED + CRUD HTTP; ver § R3-A y backlog. |
| 10 | R3-C | COMPLETADA 2026-11-04 (401/403 runtime; 200 con rol guiado pendiente) | Instancia + binding + matriz sin-token/sin-scopes; ver backlog. |
| 11 | R3-D | COMPLETADA 2026-11-04 (200 con rol vía approuter) | Login SSO + destino OAuth2; ver backlog. |
| 11 | R3-B, R3-D a R3-F | PENDIENTES / CONDICIONADAS | Persistencia, enrutamiento, identidad/conectividad e integración. |
| 10 | Pendientes anteriores | PENDIENTES / DIFERIDOS | Retomar después de R3; ver §6 y backlog actual. |

## Historial de fases completadas

Los estados reflejan el backlog e informes disponibles; no implican que cada entorno o flujo se haya validado en vivo.

| Fase | Estado | Resultado y evidencia resumida |
|---|---|---|
| P0 | COMPLETADA | Auditoría inicial; `docs/engineering/initial-assessment.md`. |
| P1 | COMPLETADA según backlog | Gobernanza Meta-Harness, orquestación/especialistas, flujos, contratos, catálogos y CI. El backlog conserva pendientes administrativos de branch protection. |
| P2 / T-P2-04–06 | COMPLETADAS | Knowledge Map, inteligencia de proyecto, estrategia de pruebas, improvement log y ADR; detalle en backlog. |
| T3 | COMPLETADA | Flujo autónomo y oportunidades documentadas. |
| T3.1 | COMPLETADA | Validación operativa indicada en backlog, con grafo/índice y probes restaurados. |
| T4 | COMPLETADA en lo registrado | El backlog registra T4-E/F/G: OPP-006 y OPP-008 `VALIDATING`, OPP-009 `DEFERRED`, OPP-010 `REJECTED`. Esto no demuestra validación BTP runtime. |
| T4.1 | PENDIENTE DE CONFIRMAR como etiqueta separada | No afirmar fase independiente sin artefacto que la confirme. Conservar el nombre T4-E/F/G documentado. |
| T5 | COMPLETADA | Ingeniería y verificación CAP/UI5; ver detalle por subfase en backlog. |
| T5.1 | COMPLETADA | Verificación CAP local y tests; no equivale a despliegue BTP. |
| T5.2 | COMPLETADA | Flujo de generación ServiceDesk y evidencia en backlog. |
| T5.3 | COMPLETADA | Aislamiento de fixtures y matriz de terminales. |
| T5.4 / T5.4-CLOSE | COMPLETADAS | Orden-independencia, validación condicional y cierre documentado. |
| T5.5 / T5.5-CLOSE | COMPLETADAS | Demo Books/UI5; el historial separa las pruebas ejecutadas de E2E/BTP no ejecutadas. |
| R1 | COMPLETADA según historial git (`b7a6195` madurez R1, `9931f6c` cierre R1 paridad `cf-safe` y fuga npm, 0.3.2 intacta) | Madurez de producto, paridad `cf-safe` y guardia de distribución. Las etiquetas `R1-CLOSE` / `R1-FINAL-CLOSE` figuran NOT VERIFIED: no hay artefacto en el repo que las confirme. No implica publicación. |
| R2.1 | COMPLETADA | Higiene CDP multiplataforma y protección de procesos ajenos. |
| R2.2 | COMPLETADA | Fixture CAP + UI5 con QUnit/OPA5 reales; resultados detallados en backlog. |
| R2.3 | COMPLETADA | Matriz 12 celdas: 1 `VERIFIED`, 11 `NOT VERIFIED`; Windows × OpenCode reportado como verificado. |
| R2.4 | COMPLETADA | Ejemplo JSONC por fases y telemetría local opt-in basada en métricas observables. |

## R3.0 — inventario Trial

R3.0 está COMPLETADA como **READY WITH LIMITATIONS**. El informe técnico canónico es [`docs/engineering/r3/trial-landscape-assessment.md`](../r3/trial-landscape-assessment.md).

Resumen para continuidad:

- Inspección de solo lectura con BTP CLI y CF CLI reales. Se registró una cuenta/subcuenta Trial en us10, un org y un espacio CF, y cero aplicaciones/instancias en el momento del inventario.
- Se identificaron BTP CLI, CF CLI v8 y MBT reales; también un conflicto de resolución de `cf` en PATH. Verificar rutas al usarlas; nunca copiar credenciales al repo.
- `cds` no estaba disponible y el intento offline de npx no lo resolvió.
- El informe registra cuota Trial de memoria total 4 GB, límites de instancias/rutas y expiración/suspensión. Verificar cuotas actuales antes de cualquier acción.
- Entitlements, planes y marketplace no prueban instancias, despliegues, autenticación de aplicación ni E2E.
- IAS y Cloud Connector tienen límites de visibilidad/condición. Mantener intacto el trust `sap.default`.
- El paisaje se reportó limpio entonces; es evidencia histórica. Re-inventariar antes de cada fase y preservar todo recurso que exista ahora.

## R3.0.1 — preparación operativa completada

**Estado: COMPLETADA 2026-11-04 (evidencia abajo).** Objetivo cumplido:
ambigüedades de herramientas locales resueltas sin aprovisionar ni desplegar.

Resuelto y verificado en vivo (solo lectura):

1. CDS CLI disponible y reproducible: convención existente
   `npx -p @sap/cds-dk cds` confirmada con red (`@sap/cds-dk` 10.2.0 en
   npm, `cds --version` operativo y cacheado). Sin cambio de producto;
   R3-A fija versión al scaffoldear.
2. CF CLI real invocable por convención: `$env:CF_BIN` (mapeo local no
   versionado) honrado por `cf-safe.ps1`, `cf-safe.sh`, `check-prereqs.ps1`
   y `check-prereqs.sh`, con guardia fail-closed (nombres permitidos:
   `cf` y wrappers documentados `sap_cf`, con o sin extensión) en ambos
   brokers. Verificado sin mapeo (FALTA + hint) y con el mapeo local de
   la máquina (`sap_cf.cmd` → `cf.exe` real v8.19.0, OK) en PowerShell,
   incluyendo ruta con espacios y rechazo de binario ajeno
   (`notepad.exe` → DENY exit 1). El otro `cf` en PATH es una herramienta
   ajena del equipo, no un defecto del harness; ningún CLI fue renombrado,
   reemplazado ni reinstalado y el mapeo personal no está versionado.
3. Brecha BTP cerrada con el cambio mínimo: skill producto `btp-cli`
   (solo `--info`/`get`/`list` verificados contra CLI 2.116.3, convención
   `$env:BTP_BIN`, denylist de mutaciones), fila en catálogo y registro
   en `AI/AGENTS.md`; `AI/clients/` regenerado vía render (65 archivos).
   Validada con `btp --info` y `get subaccount` vigentes.

Asuntos que quedan (no bloquean R3-A): `ui5` CLI ausente (OPT, solo si
R3-F lo exige); `AI/.opencode/` es un espejo local versionado que no
incluye `btp-cli` (no tocado; seguimiento futuro); los raw logs de
`cf-safe` son transitorios y `check-package` los vigila (se borran al
cerrar). Instalar herramientas globales, modificar producto o ampliar
alcance sigue requiriendo decisión registrada. R3.0.1 no tocó BTP.
Registro de la decisión original (ya ejecutada): se evaluó disponer de
CDS CLI, invocar el CF real sin el shim ajeno, resolver `BTP_BIN` e
integrarlo en el harness y confirmar prerrequisitos sin cambiar versión
ni editar `AI/clients/` a mano y sin añadir agentes, skills o MCP sin
justificación — todo ello quedó resuelto arriba salvo las notas del
párrafo anterior.

## R3 pendiente: secuencia y criterios

La secuencia deriva del plan en R3.0. La disponibilidad reportada no equivale a validación runtime.

### R3-A — CF + CAP + MTA

Validación desplegable inicial: scaffold CAP/OData, compilación y tests locales, build MTA y despliegue controlado de una app pequeña. Prerrequisitos: CDS CLI resuelto, CF binario real identificado, target/org/space/recursos actuales inspeccionados. Evidencia prevista: app iniciada, ruta, operaciones HTTP CRUD pertinentes y `validate-app`. Respetar la cuota Trial y obtener autorización específica antes de desplegar.

**Resultado 2026-11-04: COMPLETADA.** Autorización obtenida; `books-srv` STARTED web:1/1 con CRUD 200/201/200/204/404 verificado y registro de prueba eliminado. Fixes aplicados: auth `dummy` (sin XSUAA en R3-A), esquema SQLite desplegado en build (`server.js` + `db.sqlite` en MTAR), builder `npm` sin `commands`. SQLite declarado efímero; 0 servicios gestionados creados.

### R3-B — HANA Cloud + HDI

Condicionada a R3-A verde y a disponibilidad/viabilidad actual del plan HANA free. Provisión de HANA/HDI exige autorización explícita, inspección previa y protección de recursos existentes. Aceptación: CAP lee/escribe contra HANA y evidencia HDI. SQLite es fallback local, no éxito de R3-B.

### R3-C — XSUAA

Validar instancia, binding, scopes/roles y autenticación runtime sobre la aplicación base. Evidencia: respuestas diferenciadas sin token/con rol/con scopes según pruebas, más validación del artefacto de seguridad. Un plan listado no demuestra esos resultados.

### R3-D — Approuter + Destination

Validar Destination, configuración de destino y acceso mediante Approuter sin exponer secretos; respetar la dependencia de la base y seguridad descrita en el informe. Instanciar servicios o desplegar requiere autorización y verificación de recursos/cuota.

### R3-E — IAS + Connectivity

Condicionada por acceso administrativo IAS y disponibilidad de Cloud Connector. No modificar `sap.default`. Se puede reportar resultado parcial cloud-cloud; no afirmar acceso on-prem sin Connector y prueba real.

### R3-F — integración full-stack

Después de R3-A, R3-C y R3-D; incluir HANA solo si R3-B resulta verde. Si se usa SQLite, declararlo como tal. Aceptación: cadena CAP/UI5/OData, autenticación/enrutamiento, build MTA, despliegue y pruebas E2E pertinentes con evidencia. Validar componentes aislados no vuelve verde automáticamente la integración.

## Pendientes anteriores que se retoman después de R3

Al completar o cerrar R3, volver al backlog original antes de declarar terminado el roadmap. No alterar estados sin nueva evidencia.

- **Branch protection:** marcar `validate` como required en `main`; requiere autoridad administrativa.
- **OPP-006 y OPP-008:** completar validación BTP real de XSUAA/IAS y Destination/Approuter; permanecen `VALIDATING` según el historial disponible.
- **OPP-009:** HANA/HDI `DEFERRED`; reevaluar con evidencia de R3-B.
- **OPP-010:** `REJECTED`; no es trabajo pendiente, salvo nueva decisión.
- Pendientes del backlog actual: pin SHA de acciones; actualizar fecha de fuentes oficiales; completar `.gitignore.fragment` multi-cliente; backup fuera del repo; centralizar `bump-version.js`; paridad `provision-espacio`/`cf-safe.sh`/pre-commit; granularidad de logs publish. Confirmar su estado al retomarlos.
- Otros pendientes R1/R2: no se afirma que existan fuera de los elementos registrados; revisar backlog e informes antes de cerrar el roadmap.

## Invariantes y restricciones

- Mantener versión **0.3.2**.
- No hacer commit, push, merge, tag, release ni publish sin orden explícita.
- No editar manualmente `AI/clients/`; usar el generador documentado si una fase aprobada lo requiere.
- Mantener separadas la capa de producto (`AI/`) y Meta-Harness (`docs/`, herramientas y gobernanza internas).
- No confundir planes, entitlements o listings con instancias, runtime, despliegues o E2E verificados.
- Proteger recursos existentes. Antes de toda acción BTP, re-inventariar y confirmar target. No aprovisionar, modificar ni desplegar sin autorización explícita.
- Respetar límites y disponibilidad del Trial. Distinguir limitaciones del entorno, permisos, herramientas locales y defectos del harness.
- No añadir agentes, skills o MCP salvo necesidad demostrada conforme a las reglas del proyecto.
- No ampliar el alcance de una fase al ejecutarla.

## Cierre y reanudación por fase

Al cerrar cada fase, registrar en backlog y aquí su estado, fecha, alcance, archivos afectados, evidencia ejecutada, limitaciones, recursos creados/modificados, pendientes y siguiente fase. Mantener `NOT VERIFIED`, `BLOCKED`, `DEFERRED` o `REJECTED` cuando aplique; la ausencia de evidencia no es éxito.

**Siguiente paso registrado:** R3-B (HANA Cloud + HDI, provisión con autorización específica) o R3-E (IAS + Connectivity) según decida el usuario. Al terminar R3, retomar los pendientes anteriores de §6.