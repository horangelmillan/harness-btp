# Roadmap fuente de verdad — harness-btp

**Estado al:** 2026-11-04  
**Versión del producto:** 0.4.0  
**Estado global:** Release 0.4.0 publicada 2026-11-04 (flujo E completo: QA APTO, PR #4 mergeado 4a7728e, tag v0.4.0, Publish to npm OIDC success run 41802784727, npm confirma create-harness-btp@0.4.0 2026-11-04T08:53:27Z; ramas release-0.4.0 borradas; cero secretos). R3.0 completada (`READY WITH LIMITATIONS`); R3.0.1 completada 2026-11-04; R3-A completada 2026-11-04 (desplegada y verificada); R3-C completada 2026-11-04 (401/403 runtime + roles asignados); R3-D completada 2026-11-04 (200 con rol vía approuter); R3-B completada 2026-11-04 (CRUD + persistencia HANA). R3-F completada 2026-11-04 (ver fila 13 y backlog). R3-E PARCIAL/CONDICIONADA 2026-11-04 (IAS verificado; Connectivity runtime pendiente de prerrequisitos de entorno; ver fila 14 y backlog).

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
| 12 | R3-B | COMPLETADA 2026-11-04 (CRUD + persistencia HANA) | Base + HDI + deployer + restart puro; ver backlog. |
| 13 | R3-F | COMPLETADA 2026-11-04 | Diseño opción B estáticos en books-srv (+0M) + autorización "Aprobar deploy UI5". Local: `npm test` 11/11, UI5 local 200, `validate-app` exit 0, `validate-meta` 58 OK, build+deploy OK. SSO headed con perfil persistente (OPP-021). Diagnóstico $batch con red: #23 GET $metadata 200, #24 POST $batch 403 "Forbidden" 9B sin token (desafío CSRF), #25 HEAD 200 (token fetch automático), #26 POST $batch 200 con x-csrf-token y HANA Proof + Proof 2; tabla 3 filas con ambos registros — handshake CSRF estándar, modelo auto-recuperado, SIN defecto (P1 anterior retirado con evidencia). MTAR 52.906.918 bytes (`excludes:` ignorado por builder npm, 2 sintaxis empíricas; `ignore:` honrado; data.zip solo prod). Post-deploy limpio: R3F-UI-mievy9 201→204 + filtro R3F- [], Proofs intactos (4 redeploys), Component-preload 404 benigno, screenshot timeout menor. Persistencia restart y redeploy verificadas. Limpieza DELETE 204 + filtro []; HANA Proof* intactos; 0 temporales; cero secretos. Hallazgos: P2 excludes-vs-ignore (lección mta-build, mejora futura pendiente, no cambio); P3 screenshot timeout + 403 solo-Viewer no testeable. QA APTO parcial (tests/MTAR/apps/services; SSO no re-verificado por presupuesto) + reviewer COMPLETADA sin bloqueos. OPP-009 COMPLETED 2026-11-04 (§6.9: checklist + ejemplo HDI producto creados y validados). Ver backlog. |
| 14 | R3-E | PARCIAL/CONDICIONADA 2026-11-04 | IAS VERIFICADO (límites trial): trust `sap.default` Active 1 entry intacto, re-verificado hoy vía `btp list security/trust` (cero mutaciones en todo R3); IdP approuter = IAS (`accounts.sap.com`, 2FA, sesiones headed R3-F/R3-F-close); propagación IAS→XSUAA funcional (matriz Editor/Viewer 201/403 con SSO); re-login SSO interactivo tras caducidad CLI y re-verificación OK. Entitlements: connectivity lite (1) + connectivity_proxy (1), destination lite (1), identity application (1), MEMORY 4. Instancias: solo 4 (books-xsuaa, books-destination, books-hana, books-db); SIN instancia connectivity/identity (tenant-level, esperado). Connectivity cloud-cloud: plan disponible, runtime NO VERIFICADO (sin instancia/binding/prueba; no se creó nada sin backend). On-prem BLOQUEADO (sin Cloud Connector: 8443 cerrado, sin install, sin servicio; sin backend; llamada Destination OAuth2 R3-D es cloud-cloud, no prueba on-prem). Prerrequisito de cierre: Connector + backend alcanzable + destino con conectividad + instancia lite → test propagación principal. Cero mutaciones BTP (lectura + re-login); cero secretos; cuota intacta. OPP-006/008/009 COMPLETED 2026-11-04 (§6.9). Ver backlog. |
| 15 | Pendientes anteriores | PENDIENTES / DIFERIDOS | Retomar después de R3; ver §6 y backlog actual. |
| 16 | Release 0.4.0 | PUBLICADA 2026-11-04 | Flujo E completo: QA APTO (render 65, triple, installers smoke, validate-meta 58, check-package 185, pack dry-run), docs README (backups externos + v0.4.0 + changelog), bump-version.js 0.3.2→0.4.0 triple OK, gates verdes, PR #4 (check validate verde) mergeado 4a7728e, tag v0.4.0 pusheado, workflow Publish to npm OIDC success (run 41802784727, 18s, tarball 0.4.0 185 ficheros), npm confirma create-harness-btp@0.4.0 2026-11-04T08:53:27Z. Ramas release-0.4.0 borradas (local+remoto). Cero secretos. Ver backlog. |

## Historial de fases completadas

Los estados reflejan el backlog e informes disponibles; no implican que cada entorno o flujo se haya validado en vivo.

| Fase | Estado | Resultado y evidencia resumida |
|---|---|---|
| P0 | COMPLETADA | Auditoría inicial; `docs/engineering/initial-assessment.md`. |
| P1 | COMPLETADA según backlog | Gobernanza Meta-Harness, orquestación/especialistas, flujos, contratos, catálogos y CI. El backlog conserva pendientes administrativos de branch protection. |
| P2 / T-P2-04–06 | COMPLETADAS | Knowledge Map, inteligencia de proyecto, estrategia de pruebas, improvement log y ADR; detalle en backlog. |
| T3 | COMPLETADA | Flujo autónomo y oportunidades documentadas. |
| T3.1 | COMPLETADA | Validación operativa indicada en backlog, con grafo/índice y probes restaurados. |
| T4 | COMPLETADA en lo registrado | El backlog registra T4-E/F/G: OPP-006, OPP-008 y OPP-009 `COMPLETED` 2026-11-04 (§6.9, con evidencia runtime R3-C/D/E/F + R3-B), OPP-010 `REJECTED` (intacta). |
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

- **Branch protection (§6.1 RESUELTO 2026-11-04, verificado remoto):**
  ruleset `main-requiere-validate` (id 26513554, enforcement active) en
  `refs/heads/main` exige check `validate` (integración 15368,
  strict=false); repo sin protección previa (protection 404, rulesets [])
  ni otras protecciones alteradas; workflow `Validate meta` job `validate`.
  Siguiente §6 pendiente tras §6.2: fecha fuentes oficiales.
- **Pin SHA acciones (§6.2 RESUELTO-por-verificación 2026-11-04, sin edición de workflows):**
  2 workflows (.github/workflows/validate-meta.yml, publish.yml),
  4 referencias `uses:`, todas con pin SHA + comentario `# v6`:
  actions/checkout@d23441a48e516b6c34aea4fa41551a30e30af803 # v6
  (2026-07-16) y actions/setup-node@249970729cb0ef3589644e2896645e5dc5ba9c38
  # v6 (ambos workflows); verificación upstream
  (gh api repos/<org>/<repo>/commits/v6): checkout → d23441a48…af803
  COINCIDE, setup-node → 24997072…5ba9c38 COINCIDE; sin majors que
  actualizar (v6 vigente en ambos), sin cambios de comportamiento; alcance:
  sin reusable workflows, sin imágenes Docker, sin referencias locales en
  workflows; check `validate`, triggers, permisos y jobs intactos;
  `validate-meta` 58 OK; versión 0.3.2 intacta.
  Siguiente §6 pendiente: actualizar columna fecha en
  AI/docs/fuentes-oficiales.md → 2026-11-03.
- **Fecha fuentes oficiales (§6.3 RESUELTO 2026-11-04):**
  `./AI/scripts/check-docs.ps1` exit 0: 7/7 OK (cf-cli, mbt, cap,
  ui5-cli, opencode, npm-trusted-publishers REQUERIDAS + op-1password
  OPCIONAL con redirect 308 ya documentado). Fechas registradas:
  2026-11-04 real en las 7 celdas (NO la objetivo 2026-11-03); línea 26
  actualizada. Cero URLs rotas, cero cambios de contenido que exijan
  modificar guías → sin trabajo adicional. Gates: render 65 OK
  (0 escritos), validate-meta 58 OK, triple 0.3.2, check-package 183
  limpio. Siguiente §6 pendiente: completar `.gitignore.fragment`
  multi-cliente (P2, escenario E: sin promocionar a P1).
- **`.gitignore.fragment` multi-cliente (§6.4 RESUELTO-por-verificación 2026-11-04, sin edición del fragmento, P2 conservada):**
  las 6 entradas YA existían (commit b7a6195 R1 2026-11-03, blame
  líneas 25-31): `.claude/`, `.cursor/`, `.agents/`
  (+`.agents/skills/`), `.github/agents/`, `.github/skills/`,
  `.github/prompts/`; cero ediciones necesarias. Escenario E validado
  con mecanismo existente: `install.ps1 -Dest temp/s64-install` fusiona
  las 6 (grep OK); `git check-ignore -v` en repo scratch: ignorados
  `.claude/c.md`, `.cursor/x.md`, `.github/agents/a.md`,
  `.github/prompts/p.md`, `.github/skills/s2.md`,
  `.agents/skills/s.md` (este último vía regla padre `.agents/`);
  visibles `.github/workflows/ci.yml` y `README.md` (check-ignore
  vacío). `.github/` completo NO ignorado; workflows intactos.
  Transitorios borrados. Sin cambios de producto (fragmento intacto);
  `validate-meta` 58 OK; escenario E, no promocionado a P1.
  Siguiente §6 pendiente: backup fuera del repo (`--backup-dir`,
  `%TEMP%/harness-bak`) + alinear con AI/AGENTS.md § Frontera (RESUELTO
  2026-11-04 como §6.5, P2 conservada — ver entrada dedicada abajo).
- **Backups fuera del proyecto (§6.5 RESUELTO 2026-11-04, P2 conservada — NO promocionada a P1):**
  diseño T2 harness-architect + implementación + 2 fixes + QA matriz +
  reviewer. Default fuera del proyecto (ps1
  `%TEMP%/harness-bak/<yyyy-MM-dd>/`, sh
  `$HOME/.harness/bak/<yyyy-MM-dd>/`; `-BackupDir`/`--backup-dir` lo
  sustituye añadiendo fecha salvo que termine en fecha); pre-validación
  ABORT exit 1 si backup-dir dentro del destino (incluye rutas
  relativas: fix `canon_path` con prepend cwd en sh; ps1 vía
  GetFullPath); nombres únicos `<base>-<HHmmss>[-n].bak` tope 100, SIN
  borrar previos (eliminados Remove-Item/rm -rf de backups); BakLabel =
  basename real; ayudas actualizadas; mensajes SKIP/CREATE/BACKUP/OK/ABORT
  intactos. QA: matriz 4 fixtures × ps1/sh 8/8 PASS tras fix (inicial
  sin backup; update con backup recuperable fuera + 2º force sin borrar;
  override fechado/no-duplicado; rechazo interno relativo+absoluto exit 1
  dest intacto; sh en Git Bash). Reviewer: APTO-CON-PENDIENTES, P1
  ninguno; P2 colisión mismo segundo entre árboles con igual basename
  (`skills` ×3, distinguibles solo por ruta completa del mensaje — sin
  pérdida de datos, mejora futura de nombre); P3 symlinks/case en
  canon_path + trap ruidoso (menores, futuros). Gates: validate-meta 58
  OK; triple 0.3.2 intacta (sin bump); render N/A justificado (no se
  toca AI/canónico); check-package N/A (instaladores fuera de npm). Cero
  secretos; transitorios y .bak de prueba borrados.
  Siguiente §6 pendiente: P3 `bump-version.js` único (adiós triple
  edición manual) — RESUELTO 2026-11-04 como §6.6, ver abajo.
- **`bump-version.js` único (§6.6 RESUELTO 2026-11-04, P3 conservada — mecanismo completado, NO bump):**
  el mecanismo YA existía (`scripts/bump-version.js`, R1.2: `<X.Y.Z> [--check]`); §6.6 lo COMPLETA con guarda
  pre-escritura (+6 líneas): en modo escritura aborta (exit 1, sin escribir) si la triple previa discrepa;
  interfaz y estilo intactos. Validación: repo real `--check` → OK 0.3.2 exit 0; sandbox temp triple
  discrepante → `--check` y escritura exit 1 sin escribir; sandbox triple 0.0.0 → escritura 9.9.9 OK +
  guardia OK; sandbox borrado. Triple real 0.3.2 intacta (SIN bump: la tarea centraliza procedimiento, no
  versiona). Gates: `validate-meta` 58 OK; sin cambios en AI/, workflows, versions, docs de producto; cero
  secretos. Siguiente §6 pendiente: paridad `provision-espacio` + `cf-safe.sh` + pre-commit (par `.sh`) — RESUELTO 2026-11-04 como §6.7, ver abajo.
- **Paridad ps1/sh (§6.7 RESUELTO 2026-11-04, P3 conservada):** diseño T2 + implementación F1 (CF_BIN con
  fallback en ambos provision-templates) + F2 (sh acepta $2/$3) + F3 (gate service-key+valores→exit 2 sin
  --allow-write en sh) + fix WhatIf-redactado + fix canon_path relativas + 2 micro-edits del orquestador
  (divergencia NeedValues documentada como intencional; Bearer/JWT en WhatIf sh). QA matriz stub-cf 7/7 PASS
  (PS5.1 + Git Bash, sin BTP real) + re-verificación orquestador (d)-sh relativo/absoluto ABORT exit 1,
  force OK; probes Bearer/JWT redactados, what-if plano intacto. Reviewer APTO-CON-PENDIENTES, P1 ninguno;
  P2 gate 1-flag vs 2-flags (divergencia intencional documentada: sh nunca devuelve valores); P3
  substring-falso-SKIP y trap ruidoso (aceptados, documentados). Diferencias aceptadas por diseño (NO
  tocadas): P3 match exacto/substring, S2 JSON shape, S3 sed/`set --`, S4 wording, sin dry-run en provision,
  args con espacios no soportados en sh. Gates: validate-meta 58 OK; render N/A justificado (AI/scripts no
  propaga a AI/clients/); triple 0.3.2 intacta; cero secretos; transitorios borrados. Siguiente §6
  pendiente: granularidad de logs publish — RESUELTA 2026-11-04 como §6.8, ver abajo.
- **Granularidad logs publish (§6.8 RESUELTO 2026-11-04, mejora no bloqueante):**
  historial 9af5d2c steps sin nombre → b7a6195 nombres+pins → c1d3f74 guardia
  check-package; lo que se perdía: límites entre validación/preparación/
  publicación (logs fundidos). Cambio: grupos colapsables `::group::1/4..4/4`
  envolviendo los runs existentes + echo de versión en 4/4 (`Publicando
  create-harness-btp v$(node -p ...)`); triggers/permisos/OIDC/pins SHA/
  nombres/check `validate`/semántica intactos; cero secretos (solo versión
  pública). Validación sin publicar: `gh workflow view` parsea el YAML en
  servidor OK; simulación local de cuerpos (pack dry-run 183 ficheros, version
  echo 0.3.2, check-package 183 limpio, validate-meta 58 OK). Mejora no
  bloqueante conservada (no exige re-publicación).
  Siguiente §6 pendiente: §6.9 OPP-006/008/009 COMPLETED 2026-11-04 +
  restantes exactos (ver backlog entrada Siguiente).
- **OPP-006, OPP-008, OPP-009, OPP-023, OPP-024 y OPP-025:** COMPLETED 2026-11-04 (§6.9, con evidencia runtime R3-C/D/E/F + R3-B y artefactos producto para 006/008/009; §6-learnings con gates 65/58 + QA APTO + reviewer APROBAR para 023/024/025; fuera de la lista de pendientes).
- **Nombres backup inequívocos (§6.12 RESUELTO 2026-11-04, P2 conservada — NO promocionada a P1):**
  fix tag saneado en Get-UniqueBackupPath/unique_backup_path
  (`<tag>-<HHmmss>[-n].bak`, tope 100, ABORT al agotar); call sites
  AI→`AI`, Merge-Tree→label (agents-skills, github-skills, opencode);
  1 línea ayuda c/u; paridad ps1/sh; sin rutas personales en el nombre
  (solo etiqueta); ABORT pre-cambio y mensajes intactos. QA APTO: 3
  dests × 2 skills trees × ps1/sh = 12 backups únicos e identificables;
  colisión real mismo segundo en ps1 (`AI-030523`+`AI-030523-1` vía
  contador); contenido preservado (markers); update/restore OK
  (restore=copia manual, sin comando); cero .bak en dests; sh probe
  contador OK. Reviewer APTO-CON-PENDIENTES, P1/P2 ninguno; P3: race
  TOCTOU concurrente ínfimo, HHmmss sin fecha (aislado por dir
  yyyy-MM-dd), heredados symlinks/case + trap (NO reabiertos, siguen
  separados). Gates: validate-meta 58 OK; triple 0.3.2; render N/A
  (AI/scripts no propaga); cero secretos; transitorios borrados.
  Siguiente §6 pendiente: P3 symlinks/case canon_path + trap ruidoso
  (separado, NO parte de este P2) — RESUELTO 2026-11-04 como §6.13, ver abajo.
- **canon_path físico + trap (§6.13 RESUELTO 2026-11-04, P3 conservada — NO promocionada; TOCTOU NO reabierto, sigue P3 separado):**
  fix canon_path físico + trap on_exit. QA inicial NO-APTO (junctions
  intermedias no resueltas: fail-open sh con 2 niveles inexistentes + ps1
  solo reparse final); fix: sh baja al ancestro existente + pwd -P, ps1
  camina todos los componentes con Resolve-Link (.Target, tope 32); trap
  on_exit (EXIT preserva código, INT→130/TERM→143 con mensaje stderr,
  MT_CLEANUP="" tras merge OK). Re-verificación orquestador con junctions
  reales mklink /J (sin admin): ps1 y sh ABORT exit 1 ante junction→dentro
  (relativa y absoluta), ACEPTAN e instalan exit 0 ante junction→fuera;
  exit 0 en éxito-con-avisos en ambos (un "exit 1" intermedio fue artefacto
  de Select-Object truncando el pipe, verificado en limpio). Reviewer APTO
  (P1 ninguno; P2 ninguno; P3: TOCTOU separado, symlinks /D sin privilegios
  NO-VERIFICADO con junctions como cobertura Windows). Symlinks /D reales:
  NO-VERIFICADO (mklink exige privilegios; causa registrada). Gates:
  validate-meta 58 OK; triple 0.3.2; render N/A (AI/scripts no propaga);
  cero secretos; temp/t613 + backups de prueba borrados (incl.
  $TEMP/harness-bak/<fecha> del orquestador). Siguiente §6 pendiente: P3
  Component-preload 404 benigno + screenshot timeout (R3-F) + §6.14 TOCTOU (P3 MITIGADO, ver abajo).
- **Ventana TOCTOU mitigada (§6.14 MITIGADO 2026-11-04, P3 conservada — NO eliminada, riesgo residual explícito, nada reabierto):**
  mitigación con mecanismos existentes, sin locks por diseño:
  Assert-ExternalBackupRoot/assert_external_backup_root llamados justo
  antes de cada escritura (AI + Merge-Tree), pre-validación intacta;
  ventana reducida a microsegundos. QA APTO: revalidación detecta
  reapuntado j→dentro (ABORT exit 1, dest intacto) en ps1+sh; race-loop 30
  installs + 80 flips: 22 ABORT, 8 exit 0, 0 .bak dentro; regresión
  update/restore OK; limpieza hecha. Reviewer APTO (P1 ninguno; P2
  opcional: revalidar también el path final $Bak — registrado como mejora
  futura, NO aplicado). Riesgo residual EXPLÍCITO (NO declarar eliminado):
  intercalado exacto entre Assert y Move (microsegundos, 0/30 en prueba)
  sigue teóricamente posible; TOCTOU concurrente real posible aunque no
  observado; impacto acotado (backup caería dentro del proyecto u otra
  ruta local; sin secretos en backups más allá del contenido del repo).
  Siguiente §6 pendiente: P3 symlinks /D sin privilegios (NO-VERIFICADO,
  intacto) + resto P3 (preload 404, screenshots, 403 solo-Viewer; colisión
  basename ya resuelta §6.12). Cero secretos; sin commit/push.
- **Symlink /D + triage P3 R3-F (§6.15 REGISTRADO 2026-11-04, solo-docs, sin cambios de código):** symlink /D con mklink exige privilegios (error observado, exit 1); sin Developer Mode ni elevación (prohibido); caso symlink /D queda NOT VERIFIED con esa causa; cobertura Windows sigue siendo junctions mklink /J (§6.13/§6.14: ABORT dentro / ACEPTA fuera); fixture temp/t615 borrada. Triage P3 R3-F (cero fixes, evidencia ya en R3-F/R3-F-close): a) 404 Component-preload.js BENIGNO; b) timeout screenshot Playwright LIMITACIÓN DE HERRAMIENTA; c) 403 solo-Viewer LIMITACIÓN DE IDENTIDAD. Ninguno es defecto reproducible. Siguiente real: sin pendientes accionables en §6; §6 funcionalmente completo con los límites documentados.
- **OPP-010:** `REJECTED`; no es trabajo pendiente, salvo nueva decisión.
- Pendientes del backlog actual (§6.1–§6.9 + §6.12–§6.14 2026-11-04 + §6.15 2026-11-04, ver arriba): restantes exactos — P2 snippet mtad-gen RESUELTO 2026-11-04 (fixture aislada temp/t611, `mbt mtad-gen` exit 0); P2 colisión basename skills RESUELTA 2026-11-04 (§6.12); P3 canon_path físico + trap RESUELTO 2026-11-04 (§6.13, P3 conservada; symlinks /D NO-VERIFICADO); P3 ventana TOCTOU MITIGADA 2026-11-04 (§6.14, P3 conservada — NO eliminada, riesgo residual explícito; mejora futura P2 path final $Bak NO aplicada); P3 Component-preload 404 benigno + screenshot timeout TRIADO (ver §6.15); 403 solo-Viewer TRIADO (ver §6.15); §6.15 symlink /D NOT VERIFIED + triage sin fixes. §6 sin pendientes accionables; funcionalmente completo con límites documentados.
- Otros pendientes R1/R2: no se afirma que existan fuera de los elementos registrados; revisar backlog e informes antes de cerrar el roadmap.

## Invariantes y restricciones

- Mantener versión **0.4.0**.
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

**Siguiente paso registrado:** R3-E PARCIAL/CONDICIONADA 2026-11-04 (IAS verificado; Connectivity runtime pendiente de prerrequisitos de entorno, no del harness). R3 cerrada en lo verificable; retomar §6 (§6.1–§6.9 + §6.12–§6.14 2026-11-04; restantes exactos en backlog entrada Siguiente: P2 snippet mtad-gen RESUELTO 2026-11-04, P2 colisión basename skills RESUELTA 2026-11-04 (§6.12), P3 canon_path físico + trap RESUELTO 2026-11-04 (§6.13, symlinks /D NO-VERIFICADO), P3 ventana TOCTOU MITIGADA 2026-11-04 (§6.14, P3 conservada — NO eliminada, riesgo residual explícito), P3 Component-preload 404 + screenshot timeout TRIADO (ver §6.15), 403 solo-Viewer TRIADO (ver §6.15)). §6.15 symlink /D NOT VERIFIED + triage P3 R3-F REGISTRADO 2026-11-04 sin fixes; §6 sin pendientes accionables, funcionalmente completo con límites documentados). OPP-006/008/009/023/024/025 COMPLETED 2026-11-04 (fuera de la lista); OPP-010 REJECTED intacta.