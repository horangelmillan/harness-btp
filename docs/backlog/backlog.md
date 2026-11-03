# Backlog

## Ahora (P-siguiente)

- [ ] P1/T5.6: E2E honesto con ensure/cleanup (`temp/` + `cds` vía `npx`,
  sin afirmar E2E/BTP no ejecutados).
- [ ] P1/T5.6: paridad approuter ps1/sh (conteo vs objeto — WARNING conocido
  no bloqueante de T5.5, ver OPP-018).
- [ ] Branch protection: marcar job `validate` como required en `main`.
- [ ] Pin SHA acciones (recomendación security, hoy `@v6` por convención).
- [x] Indexar `harness-btp` en `codebase-memory` → proyecto
  `C-Users-Horan-Desktop-harness-btp`, 726 nodos / 790 aristas,
  `index_status: ready` (2026-11-03).
- [ ] Actualizar columna fecha en `AI/docs/fuentes-oficiales.md` → 2026-11-03.
- [ ] P2: completar `.gitignore.fragment` multi-cliente (`.claude/`,
  `.cursor/`, `.github/agents|prompts|skills`, `.agents/skills`).
  Escenario E: NO promocionar a P1, cambio 6 líneas.
- [ ] P2: backup fuera del repo (`--backup-dir`, `%TEMP%/harness-bak`);
  alinear con `AI/AGENTS.md § Frontera`.
- [ ] P3: `bump-version.js` único (adiós triple edición manual).
- [ ] P3: `provision-espacio` par `.sh` + `cf-safe.sh`/`pre-commit` par.
- [ ] Mejora no bloqueante: granularidad log publish (regresión menor P1 —
  log CI menos granular tras unificar `publish.yml`).

## Después

- [ ] Evidencia Linux/macOS y Claude/Cursor/Copilot (matriz → verificado).
- [ ] `opencode.jsonc` real de ejemplo con MCPs por fase.
- [ ] Métricas reales de eficiencia cuando el cliente exponga telemetría.

## Hecho

- [x] T5.5 Demo full-stack Books+UI5 + fix `Test-JsonValid`: auditoría
  T5.5-A + diseño T5.5-B (3 mejoras trazables) + demo `temp/t55-demo`
  T5.5-C (backend 8/8, EDMX `Books`, CRUD manual, UI freestyle) + QA
  T5.5-D (integración HTTP verde; E2E/BTP no ejecutados, no afirmados) +
  fix T5.5-E (`AI/scripts/validate-app.ps1` `Test-JsonValid`, 1 archivo,
  `validate-app` ps1 exit 0 en `app-local-demo` y `temp/t55-demo`) +
  reviewer APTO-CON-PENDIENTES (P1 approuter conteo, P2 `node_modules`→OPP-014,
  P3 trazabilidad 3 mejoras, P4 evidencia aportada, P5 duplicado opp:296+299
  colapsado); `validate-meta` 54 OK, `render --check` 61 OK, triple 0.3.2;
  `git status` solo `M AI/scripts/validate-app.ps1`, originales intactos,
  `temp/` ignorado, secret scan 0; OPP-018 COMPLETED; OPP-014 PROPOSED y
  OPP-006/008 VALIDATING intactos. Sync no requerida: solo `.md`
  backlog/improvements + 1 archivo producto ya validado (clase B/C);
  sin PEND-KNOWLEDGE (sin stale verificado); sin commits (2026-11-03).
- [x] T5 Application Engineering & Verification: auditoría A/B real
  (research T5-C + diseño T5-D reutilizando `/flow`+`/verify`+`qa-review`,
  sin agentes/comandos/skills nuevos) + `AI/scripts/validate-app.ps1/.sh`
  (OPP-011, condicional PASS/WARNING/FAIL/N-A/BLOCKED, 22 PASS + 1 BLOCKED
  en demo, paridad ps1/sh, FAIL→exit 1 con diagnóstico) + demo
  `AI/specs/examples/app-local-demo` (OPP-012, CAP+SQLite local, mta.yaml
  CF válido, `@(requires:'Viewer')`) + revisión SAP (tipos MTA corregidos)
  + QA APTO + reviewer APTO-CON-PENDIENTES; `render --check` 61 OK,
  `validate-meta` 54 OK, triple 0.3.2; OPP-013 PROPOSED (cds-dk);
  OPP-006/008 siguen VALIDATING (sin BTP real); sin commits (2026-11-03).
- [x] T5.1 Application Runtime Verification: demo CAP ejecuta de verdad
  (`npm install` 72 pkgs + lockfile; `cds compile` exit 0; `npm test`
  8/8: 401/CRUD 201/200/404/400/204 con SQLite `:memory:` y mocks
  reader/writer solo-[development]) + validate-app 9 escenarios A–J
  (paridad ps1/sh 9/9 tras fix BOM en `json_ok`, 0 mutaciones,
  limitación honesta: sintaxis CDS la captura `cds compile`)
  + OPP-005 aclarada (REJECTED era el duplicado, historial `da66d5c`)
  + OPP-013 COMPLETED; `cds test` nativo documentado no aplicable sin
  `@cap-js/cds-test`; sin commits (2026-11-03).
- [x] T5.2 E2E Generation ServiceDesk: NL→spec (analyst+documentarian,
  12 CAs) → diseño (architect: association, plan, UI5 diferido) →
  generación (backend-cap: 6 archivos+lockfile, compile 0) → 16/16 tests
  (qa-review APTO + gaps sap corregidos) → validate-app exit 0 con N-A
  correctos → Fase H real (defecto R5 inyectado 12/14, fix producto 1/3,
  R6-masking documentado) → independencia (%TEMP%, install+14/14+compile)
  → OPP-015 (nota SQLite en cap-cli + render) ; `render` 61 OK,
  `validate-meta` 54 OK, triple 0.3.2; sin commits (2026-11-03).

- [x] T5.3 Aislamiento fixtures + matriz terminales R6/R7:
  `AI/agents/backend-cap.md` (fixtures + fix paquete `@sap/cds` vía
  `cap-cli`) + `AI/agents/qa-review.md` (matriz terminales) +
  `AI/skills/cap-cli/SKILL.md` (TRANSITIONS) → OPP-016 COMPLETED;
  evidencia `temp/t52-servicedesk` test:119-150 + srv:78-90; QA
  APTO-CON-PENDIENTES (`npm test` t52 bloqueado entorno npx 90s,
  16 cancelados) + reviewer APTO-CON-PENDIENTES (fix paquete ya aplicado);
  `render --check` 61 OK, `validate-meta` 54 OK, triple 0.3.2; Tests
  pendiente entorno; sin commits (2026-11-03). Sync no requerida: solo
  `.md` producto, sin cambios estructurales (clase B); sin PEND-KNOWLEDGE.

- [x] T5.4 Orden-independencia + matriz condicional + WARNINGs aislamiento:
  `AI/agents/qa-review.md` (orden-independencia + matriz condicional) +
  `AI/skills/cap-cli/SKILL.md` (patrón suite aislada) +
  `AI/scripts/validate-app.ps1/.sh` (3 WARNING test-aislamiento) →
  OPP-017 COMPLETED; estática `validate-meta` 54 OK, `render --check` 61 OK,
  triple 0.3.2; runtime local QA multi-app Books 8/8 x2 + SD 16/16 x2 +
  matriz 6/6; randomize Books 7/8 y SD 8/16 por diseño (no regresión);
  reviewer APTO-CON-PENDIENTES (pendiente approuter sh paridad objeto vs
  conteo); E2E/BTP N-A; solo `.md` producto + validador solo-lectura,
  `AI/clients/` intacto; sin commits (2026-11-03).

- [x] T5.4-CLOSE Cierre deuda orden (solo-docs, sin tocar código):
  fixes sobre pendientes reviewer inicial — DEP0190 eliminado vía
  `cmd.exe shell:false`, approuter `.sh` por objeto, `check-prereqs -NeedUi5`
  + `cds` vía `npx`, subshell `sh` corregido, `backend-cap` alineado;
  copias `temp/t54c-books` 8/8 x4 + `temp/t54c-sd` 16/16 x4
  (2 normal + 2 randomize); `validate-meta` 54 OK, `render --check` 61 OK,
  triple 0.3.2; OPP-017 conserva COMPLETED (nota cierre añadida, sin nueva
  OPP); OPP-014 PROPOSED, OPP-006/008 VALIDATING, OPP-009 DEFERRED,
  OPP-015/016 COMPLETED intactos; `AI/clients/`, `temp/` y originales
  intactos; sin commits (2026-11-03).

- [x] T4-E/F/G conocimiento: OPP-006→VALIDATING (xs-security, APTO estático
  54/61/0.3.2, sin BTP real) + OPP-008 VALIDATING (approuter) + OPP-009
  DEFERRED (HANA) + OPP-010 REJECTED (OData→mejora `cap-cli`); mapa/catálogos
  intactos; sin reindex (2026-11-03).
- [x] T3.1 Operational Validation: B1–B3 + C1–C2 + D1–D6 en vivo
  (grafo 557/417 = HEAD 57d3bf2; CBM 770/813 ready; probes restaurados) +
  OPP-007 (1 párrafo §4 lifecycle) + reviewer APTO; `AI/` intacto,
  sin commits (2026-11-03).
- [x] T3 Autonomous Engineering: Flow D 10 etapas
  (`OBSERVE→…→SYNCHRONIZE`) + `docs/improvements/opportunities.md`
  (OPP-001…006, escenarios A–H verificados) + checks T3 en
  `validate-meta.js` (54 en verde) + delegación selectiva en orquestador;
  11 agentes (sin nuevos), `AI/` intacto (2026-11-03).

- [x] P0 auditoría + `docs/engineering/initial-assessment.md` (2026-11-03).
- [x] P1-P5 meta mínimo: orquestador + 10 especialistas, 5 flujos, contratos,
  catálogos, ADR-001, backlog (2026-11-03).
- [x] P1 gate CI `validate-meta.yml` + `publish` unificado (2026-11-03).
- [x] T-P2-04 Project Intelligence: `knowledge-map.md` + `impact-guide.md`
  (T0/T1/T2, escenarios A–E) + `metrics/baseline-P1.md` + checks
  mapa/governance en `validate-meta.js` + intelligence-pack en 3 flujos
  (2026-11-03).
- [x] T-P2-05 QA Project Intelligence: APTO, 0 falsos positivos,
  2×T0 + 1×T1 + 2×T2 verificados (2026-11-03).
- [x] T-P2-06 cierre P2: `testing-strategy.md` § P2 + `improvement-log.md` +
  ADR-002 (inteligencia por referencias) (2026-11-03).
- [x] Graphify local: `graphifyy[mcp]` 0.9.97 (uv, reutilizado), grafo
  `graphify-out/graph.json` 517 nodos / 381 aristas (100% EXTRACTED,
  commit = HEAD), MCP STDIO `graphify-local` (10 herramientas) a nivel
  usuario, escenarios A–F verificados CLI + MCP, estrategia
  `extract --code-only` + `update` bajo demanda; docs
  `docs/mcp/graphify-local.md` + catálogo + knowledge-map +
  system-overview + impact-guide + ADR-003; `AI/` intacto, npm limpio
  (2026-11-03).
- [x] Knowledge Lifecycle: ciclo retrieve → verify transversal
  (`docs/engineering/knowledge-lifecycle.md` canónico + punteros de 1 línea
  en 5 flujos y orquestador, sin flujo/agentes/aprobaciones nuevos);
  matriz Graphify vs Codebase Memory vs ninguno + anti-doble-consulta;
  detect A/B/C + exclusión; sync `graphify update` bajo demanda con puerta
  `check-update` y `detect_changes` para Codebase Memory; freshness 3 campos;
  checklist cierre §5 con fallo no bloqueante (`PEND-KNOWLEDGE`);
  escenarios A–H verificados (F/H: cero indexaciones con árbol limpio);
  `AI/` intacto (2026-11-03).
