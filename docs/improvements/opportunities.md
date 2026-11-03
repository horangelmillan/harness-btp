---
title: Registro de oportunidades de mejora (T3)
date: 2026-11-03
status: vigente
---

# Opportunities — Autonomous Engineering (T3)

Registro trazable de oportunidades del Meta-Harness. Cada entrada conserva
los 12 campos de `§1`. Deduplicación (§2) antes de registrar. Estados (§3).

## 1. Esquema (12 campos)

`ID` · problema · evidencia · componente · impacto · frecuencia ·
causa probable · solución propuesta · esfuerzo · riesgo de regresión ·
prioridad (`Critical|High|Medium|Low|Research`) · estado (§3).

## 2. Deduplicación

Antes de registrar: buscar en `docs/backlog/backlog.md`,
`docs/improvements/improvement-log.md`, este registro y
`docs/research/findings.md`. Coincidencia → reutilizar ID, no crear otro.
Un duplicado detectado se cierra como `REJECTED (duplicada de OPP-xxx)`.

## 3. Estados

`DETECTED` → `INVESTIGATING` → `PROPOSED` → `PRIORITIZED` → `IN_PROGRESS`
→ `VALIDATING` → `COMPLETED` | `DEFERRED` | `REJECTED` (con justificación).

## 4. Registro

### OPP-001 · `validate-meta.js` sin checks de frontmatter en docs canónicos nuevos

- Evidencia: `scripts/validate-meta.js:37-41` solo exige frontmatter en
  mapa/guía/baseline; `docs/mcp/graphify-local.md:1-5` y
  `docs/engineering/knowledge-lifecycle.md:1-5` tienen frontmatter sin
  protección CI. Componente: `scripts/validate-meta.js`.
  Impacto: regresión silenciosa posible. Frecuencia: cada edición de esos
  docs. Causa: checks añadidos en P2 solo para 3 archivos.
  Solución: extender la lista a los 5 docs con frontmatter.
  Esfuerzo: T1 (1 archivo, ~5 líneas). Riesgo: bajo (solo añade fallos ante
  frontmatter ausente). Prioridad: Medium. Estado: COMPLETED (2026-11-03,
  este ciclo; `validate-meta.js` en verde).

### OPP-002 · Flow D de 7 etapas, sin ciclo autónomo de 10

- Evidencia: `.opencode/commands/engineering-improvement.md` (12 líneas,
  `OBSERVAR→…→DOCUMENTAR`). Componente: Flow D.
  Impacto: sin synchronize/gobernanza formal; T3 §5 exige
  `OBSERVE→…→SYNCHRONIZE`. Frecuencia: cada mejora. Causa: Flow D previo a T3.
  Solución: ampliar Flow D a 10 etapas con delegación selectiva y puerta SAP.
  Esfuerzo: T1 (1 archivo). Riesgo: bajo (docs meta, validados por script).
  Prioridad: High. Estado: COMPLETED (2026-11-03, este ciclo).

### OPP-003 · Priorización T3 (este ciclo)

- Evidencia: este registro. Componente: proceso.
  Candidatos evaluados: OPP-001 (impacto medio/esfuerzo T1/riesgo bajo →
  hacer ya), OPP-002 (impacto alto/esfuerzo T1/riesgo bajo → hacer ya),
  OPP-006 (impacto medio/esfuerzo y riesgo desconocidos sin fuentes
  oficiales → RESEARCH, no implementar), nuevo agente autónomo
  (impacto nulo demostrado → REJECTED, reutilizar orquestador).
  Prioridad: High. Estado: COMPLETED (justificación registrada aquí).

### OPP-004 · Implementación autónoma acotada (Escenario D)

- Evidencia: diff de este ciclo (`validate-meta.js` + Flow D + docs).
  Es la materialización de OPP-001+OPP-002. Pruebas:
  `node scripts/validate-meta.js` en verde, `render --check` OK, triple
  versión OK. Revisión independiente: Escenario E (reviewer). Prioridad:
  High. Estado: COMPLETED (2026-11-03: reviewer APTO por muestreo +
  runtime `54 checks` + `render 61 OK` + triple 0.3.2, `AI/` intacto).

### OPP-005 · Prevención de duplicados (Escenario G)

- Evidencia: re-registro intencional de OPP-001 durante este ciclo.
  Búsqueda en backlog + improvement-log + este registro localiza OPP-001 →
  segundo registro cerrado como `REJECTED (duplicada de OPP-001)`.
  Aclaración T5.1 (2026-11-03, sin cambio de decisión): el `REJECTED` se
  refiere al duplicado sin ID propio, no a OPP-005; ver también
  `docs/quality/testing-strategy.md:92` (G duplica OPP-001 → REJECTED).
  Historial git: OPP-005 creada en `da66d5c` siempre con estado COMPLETED.
  Prioridad: Medium. Estado: COMPLETED (mecanismo §2 verificado).

### OPP-006 · Skill reutilizable XSUAA/IAS (Escenario H, SAP BTP)
- Problema: auth XSUAA/IAS recurrente sin guía producto verificable.
  Evidencia: `AI/docs/xs-security-checklist.md` + `AI/specs/examples/xs-security.json`
  (T4-E/F) + `AI/skills/sap-verify/SKILL.md` y `AI/specs/_template.md` modificados.
  Componente: `AI/docs|specs|skills` (producto). Impacto: alto (auth recurrente
  en CAP). Frecuencia: cada proyecto con xs-security.
  Causa: conocimiento disperso en consumidores. Solución: 2 docs producto
  + ejemplos + puerta `sap-verify` (no skill nueva).
  Esfuerzo: T1. Riesgo regresión: bajo (solo docs/ejemplos, `AI/clients/` por render).
  Prioridad: High. Estado: VALIDATING (2026-11-03: APTO estático —
  `validate-meta` 54 OK, `render --check` 61 OK, triple 0.3.2; NO `AVAILABLE`
  sin prueba real BTP; pendiente despliegue CF/XSUAA para COMPLETED).

### OPP-007 · Freshness: `detect_changes` no mide desfase del índice (T3.1)

- Evidencia: tras `index_repository` full con probes, `search_code`
  recuperaba `t31CbmProbeZeta` (`findings.md:7`); tras restaurar y
  reindexar, 0 resultados (770/813, ready). Pero `detect_changes`
  siguió `changed_count=8` (compara árbol vs `HEAD`, estilo git).
  Componente: `docs/engineering/knowledge-lifecycle.md` §4.
  Impacto: reindexaciones repetidas innecesarias si se lee el conteo como
  desfase. Frecuencia: cada tarea con cambios sin commitear.
  Solución: 1 párrafo en §4 (semántica git + `built_at_commit`≠frescura
  árbol + `search_code` para `.md`). Esfuerzo: T0. Riesgo: nulo.
  Prioridad: Medium. Estado: COMPLETED (2026-11-03, corrección solo-docs;
  `validate-meta.js` en verde).

### OPP-008 · Guía Destination/Approuter producto (T4-E/F, SAP BTP)
- Problema: consumo de destinos vía Approuter sin patrón producto verificable.
  Evidencia: `AI/docs/destination-approuter-checklist.md` +
  `AI/specs/examples/mta-approuter-snippet.yaml` + `AI/specs/examples/xs-app.json`
  (T4-E/F). Componente: `AI/docs|specs` (producto).
  Impacto: medio-alto (conectividad recurrente). Frecuencia: cada proyecto con
  destinos. Causa: conocimiento disperso en consumidores.
  Solución: checklist + 2 ejemplos producto (no skill nueva).
  Esfuerzo: T1. Riesgo regresión: bajo (solo docs/ejemplos).
  Prioridad: High. Estado: VALIDATING (2026-11-03: APTO estático —
  `validate-meta` 54 OK, `render --check` 61 OK, triple 0.3.2; NO `AVAILABLE`
  sin prueba real BTP con destino/Approuter para COMPLETED).
  Trazabilidad: problema (sin patrón) → implementación (T4-E/F) → validación
  (T4-F estática; T4-G registra).

### OPP-009 · HANA (HDI) diferido (T4-G)
- Problema: guía HANA/HDI pendiente sin fuente verificada en este ciclo.
  Evidencia: este registro + §2 (sin duplicado en backlog/log/findings).
  Componente: `AI/docs|specs` (producto, futuro). Impacto: medio.
  Frecuencia: cada proyecto con HANA. Causa: presupuesto T4 agotado en
  OPP-006/008. Solución: checklist+ejemplo HDI en ciclo futuro con fuente
  oficial. Esfuerzo: T1 estimado. Riesgo: bajo.
  Prioridad: Medium. Estado: DEFERRED (2026-11-03: pospuesto con justificación,
  no descartado).

### OPP-010 · Skill OData dedicada rechazada (T4-G)
- Problema: propuesta de skill OData dedicada.
  Evidencia: §2 — capacidad cubierta por `AI/skills/cap-cli` + `sap-verify`
  (verificación de servicios) y patrones CAP existentes; skill nueva duplicaría.
  Componente: `AI/skills` (producto). Impacto: nulo demostrado.
  Frecuencia: n/a. Causa: solape funcional. Solución: derivar a mejora de
  `cap-cli` si surge caso real (no skill nueva). Esfuerzo: T0.
  Riesgo regresión: medio si se duplica (confusión de triggers).
  Prioridad: Low. Estado: REJECTED (2026-11-03: duplicada/solapada —
  derivado a mejora futura de `cap-cli`, con justificación).

### OPP-011 · Validador condicional producto `validate-app` (T5-E/F)
- Problema: `/verify` solo 4 checks genéricos; checklists XSUAA/Approuter
  eran guías sin ejecución; ningún diagnóstico estructurado por tipo de app.
  Evidencia: auditoría T5-A/B (researcher T5-C + architect T5-D) +
  `AI/scripts/validate-app.ps1` / `.sh` (solo-lectura, veredictos
  PASS/WARNING/FAIL/N-A/BLOCKED, exit 0/1) + integración en
  `AI/agents/qa-review.md` (E5) y `AI/commands/verify.md` (E7).
  Componente: `AI/scripts|agents|commands` (producto).
  Impacto: alto (puerta E5/E7 con evidencia previa condicional).
  Frecuencia: cada MVP con backend/frontend/MTA.
  Causa: validación documentada sin implementación ejecutable.
  Solución: validador condicional por archivos presentes + diagnósticos
  archivo|problema|impacto|fix + niveles LOCAL/BTP/E2E (implementado).
  Esfuerzo: T2 (diseño + 2 scripts + 3 ediciones + demo + render).
  Riesgo regresión: bajo (solo-lectura; `render --check` 61 OK,
  `validate-meta` 54 OK, triple 0.3.2; demo 22 PASS + 1 BLOCKED).
  Prioridad: High. Estado: COMPLETED (2026-11-03: runtime local verificado
  por orquestador + harness-qa APTO + reviewer APTO-CON-PENDIENTES;
  sin paisaje BTP real — ver OPP-006/008 VALIDATING).

### OPP-012 · Escenario demo local `app-local-demo` (T5-I)
- Problema: sin escenario mínimo que demuestre generación+validación
  end-to-end sin credenciales. Evidencia:
  `AI/specs/examples/app-local-demo/` (package.json cds^10.2.2/sqlite^3.1.2,
  db/schema.cds Books, srv/service.cds con @(requires:'Viewer'),
  mta.yaml uaa `org.cloudfoundry.managed-service`, SQLite solo-local
  documentado, xs-security/xs-app/manifest coherentes, test/README).
  Componente: `AI/specs/examples` (producto). Impacto: medio (base
  reproducible para E2E futuro). Frecuencia: cada ciclo de validación.
  Causa: demos anteriores acopladas a paisaje real. Solución: demo
  autocontenida local + `test/validate-local.md`.
  Esfuerzo: T1 (dentro de T5-EF). Riesgo regresión: nulo (ejemplos).
  Prioridad: Medium. Estado: COMPLETED (2026-11-03: validate-app exit 0
  en `.ps1` y `.sh`; `cds compile/test` pendientes de cds-dk — ver OPP-013).

### OPP-013 · Convertir BLOCKED `cds` en verificación LOCAL-BUILD (T5-G)
- Problema: `validate-app` emite BLOCKED en `cds` (CLI ausente en este
  equipo/CI); `cds compile --to edmx` y `cds test` de la demo no ejecutados.
  Evidencia: salida `BLOCKED|build|cds|CLI cds no disponible` (`.ps1` y
  `.sh`, exit 0) + QA T5-G pendiente ambiental.
  Componente: entorno dev/CI (no producto). Impacto: medio (compilación
  real CDS sin verificar). Frecuencia: cada validación CAP.
  Causa: `cds` solo vía proyecto (`npx -p @sap/cds-dk`), nada instalado.
  Solución: instalar `@sap/cds-dk` en CI/dev por proyecto y ejecutar
  `cds compile --to edmx` + `cds test` sobre la demo; sin cambiar el
  validador (BLOCKED ya es el comportamiento correcto sin herramienta).
  Esfuerzo: T1. Riesgo regresión: nulo (entorno).
  Prioridad: Medium. Estado: COMPLETED (2026-11-03, T5.1: `npm install`
  reproducible 72 paquetes, `@sap/cds` 10.2.2 + `@cap-js/sqlite` 3.1.2 con
  lockfile; `cds compile --to edmx` exit 0 con `EntitySet Books`;
  `npm test` 8/8 en verde con SQLite `:memory:`; `cds test` nativo queda
  documentado como no aplicable sin `@cap-js/cds-test` — ver
  `AI/specs/examples/app-local-demo/test/validate-local.md:5`; validador
  intacto, que ya trataba `cds` ausente como BLOCKED).

### OPP-014 · `node_modules/` ausente en `AI/.gitignore.fragment` (T5.1)
- Problema: MVPs consumidores que instalen dependencias npm (p. ej. demo
  CAP T5.1) pueden versionar `node_modules/` porque el fragmento producto
  no lo ignora (cubre `temp/`, `*.mtar`, `.env*`, cachés de cliente, pero
  no `node_modules/`).
  Evidencia: `AI/.gitignore.fragment` (sin línea `node_modules/`) vs
  `.gitignore:2` del propio harness (sí la tiene); `AI/specs/examples/
  app-local-demo/node_modules/` existe en disco ignorado solo por el
  `.gitignore` raíz, no por el fragmento que heredarían los MVPs.
  Componente: `AI/.gitignore.fragment` (producto, instalador lo fusiona).
  Impacto: medio (repos consumidores contaminados). Frecuencia: cada MVP
  con `npm install`. Causa: fragmento previo a demos con dependencias.
  Solución: añadir `node_modules/` (+ `package-lock.json` NO — el lock
  debe versionarse para reproducibilidad) y caso de prueba en instalador.
  Esfuerzo: T0 (1 línea + verificación `bin/harness-btp.js --help`/
  install en `temp/`). Riesgo regresión: bajo (solo ignora más).
  Prioridad: Medium. Estado: PROPOSED (2026-11-03: deduplicado — sin
  coincidencia en backlog/log/findings/este registro; temáticamente
  cercano al item P2 multi-cliente del backlog, pero distinto alcance).

### OPP-015 · Nota SQLite enum/unique en skill `cap-cli` (T5.2)
- Problema: MVPs CAP+SQLite asumen que `String enum` y `@assert.unique`
  se enforcean en runtime; en realidad el DDL SQLite no genera CHECK/UNIQUE
  y POSTs inválidos devolvían 201 (detectado por `backend-cap` en T5.2-D,
  desviación 1).
  Evidencia: `temp/t52-servicedesk/srv/servicedesk.js:1-11` (nota +
  validación en handlers 400/409) + `AI/skills/cap-cli/SKILL.md` (+2 líneas
  con versiones verificadas) + 4 clientes regenerados por render.
  Componente: `AI/skills/cap-cli` (producto, capacidad existente mejorada —
  no skill nueva, según Fase K).
  Impacto: medio (todo MVP CAP+SQLite). Frecuencia: cada validación de enums.
  Causa: presunción de enforcement DDL. Solución: nota en skill + patrón
  handlers (aplicado). Esfuerzo: T0. Riesgo regresión: nulo (docs;
  `render --check` 61 OK, `validate-meta` 54 OK).
  Prioridad: Medium. Estado: COMPLETED (2026-11-03).

### OPP-016 · Aislamiento fixtures + matriz terminales R6/R7 (T5.3)
- Problema: fixtures de test sin aislamiento entre casos y transiciones a
  estados terminales sin matriz de validación exigible en revisión.
  Evidencia: `temp/t52-servicedesk/test:119-150` (fixtures) y
  `temp/t52-servicedesk/srv:78-90` (terminales) + `AI/agents/backend-cap.md`
  (fixtures + fix paquete `@sap/cds` vía `cap-cli`) +
  `AI/agents/qa-review.md` (matriz terminales R6/R7) +
  `AI/skills/cap-cli/SKILL.md` (TRANSITIONS).
  Componente: `AI/agents|skills` (producto, capacidades existentes mejoradas —
  no agentes/skills nuevos).
  Impacto: medio (todo MVP CAP con estados terminales + tests con fixtures).
  Frecuencia: cada generación CAP con transiciones de estado.
  Causa: aislamiento no exigido en generación y matriz prev×next×`resolvedAt`
  solo documentada fuera de la puerta de revisión.
  Solución: fixtures aislados + fix paquete `@sap/cds` vía `cap-cli` +
  matriz terminales R6/R7 exigible en `qa-review` (aplicado).
  Esfuerzo: T2. Riesgo regresión: bajo (solo-docs producto;
  `render --check` 61 OK, `validate-meta` 54 OK, triple 0.3.2).
  Prioridad: Medium. Estado: COMPLETED (2026-11-03: APTO estático —
  `validate-meta` 54 OK, `render --check` 61 OK, triple 0.3.2; QA
  APTO-CON-PENDIENTES — `npm test` t52 bloqueado entorno npx 90s,
  16 cancelados; reviewer APTO-CON-PENDIENTES — fix paquete ya aplicado;
  Tests pendiente entorno, no bloquea el registro).
   Deduplicación §2: sin coincidencia en backlog/log/findings/este registro.

### OPP-017 · Orden-independencia + matriz condicional + WARNINGs aislamiento (T5.4)
- Problema: suites de test orden-dependientes (fallan con `--randomize`)
  + matriz de terminales exigida sin condicional (ruido en apps sin
  transiciones) + `validate-app` sin señal de aislamiento.
  Evidencia: `AI/agents/qa-review.md` (orden-independencia + matriz
  condicional) + `AI/skills/cap-cli/SKILL.md` (patrón suite aislada) +
  `AI/scripts/validate-app.ps1/.sh` (3 WARNING test-aislamiento).
  Componente: `AI/agents|skills|scripts` (producto, capacidades existentes
  mejoradas — no agentes/skills nuevos).
  Impacto: medio-alto (todo MVP CAP con suites + puerta E5/E7).
  Frecuencia: cada generación CAP con tests + cada `verify`.
  Causa: fixtures compartidos/orden implícito + matriz incondicional +
  validador sin chequeo de aislamiento.
  Solución: patrón suite aislada + matriz terminales condicional +
  3 WARNINGs test-aislamiento en `validate-app` (aplicado, sin tocar
  `AI/clients/`).
  Esfuerzo: T2. Riesgo regresión: bajo (solo-docs producto + validador
  solo-lectura; `render --check` 61 OK, `validate-meta` 54 OK, triple 0.3.2).
  Prioridad: Medium. Estado: COMPLETED (2026-11-03: APTO estático —
  `validate-meta` 54 OK, `render --check` 61 OK, triple 0.3.2; runtime local
  QA multi-app Books 8/8 x2 + SD 16/16 x2 + matriz 6/6; randomize Books 7/8
  y SD 8/16 por diseño — orden-dependencia honesta, no regresión; reviewer
  APTO-CON-PENDIENTES — pendiente approuter sh paridad objeto vs conteo;
  E2E/BTP N-A).
  Cierre T5.4-CLOSE (2026-11-03, sin cambio de estado — sigue COMPLETED):
  fixes aplicados sobre pendientes del reviewer inicial (APTO-CON-PENDIENTES)
  — DEP0190 eliminado vía `cmd.exe shell:false`, approuter `.sh` por objeto
  (paridad con `.ps1`), `check-prereqs -NeedUi5` + `cds` vía `npx`,
  subshell `sh` corregido, `backend-cap` alineado; copias `temp/t54c-books`
  8/8 x4 y `temp/t54c-sd` 16/16 x4 (2 normal + 2 randomize); estática
  `validate-meta` 54 OK, `render --check` 61 OK, triple 0.3.2; sin nueva OPP
  (§2: alcance contenido en OPP-017, no duplica OPP-014/006/008/009/015/016).
  Deduplicación §2: sin coincidencia en backlog/log/findings/este registro
  (OPP-016 cubre fixtures+matriz base; OPP-017 añade orden-independencia,
  matriz condicional y WARNINGs multi-app).

### OPP-018 · Demo full-stack Books+UI5 freestyle + fix `Test-JsonValid` ps1 (T5.5)
- Problema: sin demo full-stack CAP+UI5 freestyle verificable por HTTP y
  `validate-app.ps1` fallaba ante JSON con BOM/comentarios (`Test-JsonValid`
  con `Get-Content -Raw` + `ConvertFrom-Json` estricto).
  Evidencia: auditoría T5.5-A + diseño T5.5-B (3 mejoras trazables) +
  demo `temp/t55-demo` T5.5-C (backend 8/8, EDMX `Books`, CRUD manual,
  UI freestyle) + QA T5.5-D (integración HTTP verde; E2E/BTP no ejecutados,
  no afirmados) + fix T5.5-E (`AI/scripts/validate-app.ps1` `Test-JsonValid`,
  1 archivo) + reviewer APTO-CON-PENDIENTES + validaciones orquestador
  (`git status` solo `M AI/scripts/validate-app.ps1`, originales intactos,
  `temp/` ignorado, secret scan 0).
  Componente: `temp/t55-demo` (evidencia no versionada) +
  `AI/scripts/validate-app.ps1` (producto, 1 archivo).
  Impacto: medio-alto (primera demo full-stack + validador JSON robusto).
  Frecuencia: cada MVP full-stack + cada `verify` con JSON no canónico.
  Causa: demos previas solo-backend (OPP-012 `app-local-demo`) + parseo JSON
  estricto sin tolerancia BOM.
  Solución: demo full-stack + `Test-JsonValid` tolerante (aplicado).
  Esfuerzo: T2 demo + T1 fix. Riesgo regresión: bajo (solo-lectura;
  `validate-meta` 54 OK, `render --check` 61 OK, triple 0.3.2;
  `validate-app` ps1 exit 0 en `app-local-demo` y `temp/t55-demo`).
  Prioridad: Medium. Estado: COMPLETED (2026-11-03: fix COMPLETED +
  demo COMPLETED en integración HTTP; E2E pendiente no hecho, no afirmado).
  P1 (paridad approuter ps1 PASS vs sh WARNING): WARNING conocido no
  bloqueante, va a backlog P1/T5.6. P2 (`node_modules/` bajo demo): cubierto
  por OPP-014 PROPOSED existente, no se duplica (§2).
  Deduplicación §2: sin coincidencia en backlog/log/findings/este registro
  (OPP-012 demo solo-backend; OPP-011/017 validador sin fix JSON;
  OPP-014/006/008 alcance distinto).
