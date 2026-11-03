# Testing Strategy

Validación sin inventar verde:

1. `node scripts/render-clients.js --check` — canónico vs generado (CI lo exige).
2. `node .github/scripts/check-release-versions.js` — triple versión.
3. `node scripts/validate-meta.js` — frontmatter meta (name+description),
   docs presentes, + 1 y 2. Puerta local antes de commit.
4. Instaladores: `install.ps1 -?` / `install.sh --help`, fusiones en `AI-tmp`.
5. `check-prereqs.*`, `check-docs.*`, `pre-commit-check.ps1` en su fase.
6. Navegador solo con CDP verificado (`cdp-chrome.ps1 ensure`→`cleanup`).

Cero tests unitarios heredados del harness; `validate-meta.js` es el primer
gate ejecutable local. `reviewer` verifica por muestreo independiente.

## Validación P1 (2026-11-03)

Evidencia verificada, no simulada:

- `npm pack --dry-run`: 128 ficheros. Excluidos `.opencode/`, `docs/`,
  `validate-meta`, `AGENTS.md`, `.github`. Incluidos
  `bin/`, `templates/`, `installers/`, `AI/`.
- Escenario A (researcher): 7/7 fuentes oficiales OK.
- Escenario B (architect): nuevo workflow `validate-meta.yml` + security:
  APTO CON CONDICIONES, 5 condiciones.
- Escenario C (implementer creó `validate-meta.yml` + unificó `publish.yml`;
  qa): APTO, 38 checks exit 0, `AI/` intacto, 1 regresión menor:
  granularidad log CI.
- MCP: `codebase` / `ctx7` / `github` / `playwright` / `eslint` /
  `chrome-devtools` configurados a nivel usuario; `eslint` sin config en
  repo; `harness-btp` NO indexado en `codebase-memory`; `graphify-code`
  deshabilitada; `Neon` / `browser` fuera de catálogo.
- Prueba negativa por inspección: todas las ramas fail → exit 1.

## Validación P2 (2026-11-03)

Evidencia verificada, no simulada (T-P2-04 + T-P2-05):

- Implementado: 3 creados (`knowledge-map.md`, `impact-guide.md`,
  `metrics/baseline-P1.md`) + 7 modificados (checks mapa/governance en
  `validate-meta.js`, intelligence-pack en `engineering-feature`,
  `engineering-refactor`, `engineering-improvement`).
- `node scripts/validate-meta.js`: 46 checks exit 0 (38 P1 + 8 P2).
- `node scripts/render-clients.js --check`: 61 archivos OK.
- Triple versión OK: 0.3.2 (`package.json` = `VERSION` = `AI/VERSION`).
- QA (`harness-qa`): APTO, 0 falsos positivos; 2×T0 + 1×T1 + 2×T2
  verificados contra `impact-guide.md` escenarios A–E.
- Métricas: tiempos n/d salvo que el repo los documente; tokens n/d
  (sin telemetría; `harness-btp` no indexado en `codebase-memory`,
  `index_repository` disponible pero no ejecutado).
- Cierre: T-P2-06 (este registro) + ADR-002.

## Validación Graphify local (2026-11-03)

Evidencia verificada, no simulada (T2 con diseño + implementación + QA
del orquestador; subagentes sin shell/escritura → ejecución directa):

- Instalación: `graphifyy[mcp]` 0.9.97 vía `uv tool` (reutilizado;
  `pipx` ausente, `python -m graphify` no aplica — paquete aislado).
- Grafo: `extract . --code-only` → 152 nodos; `update .` → 517 nodos /
  381 aristas / 159 comunidades / 161 archivos, 100% EXTRACTED (sin LLM,
  sin key), `graph_stats` con commit = HEAD.
- MCP STDIO: handshake `initialize` + `tools/list` (10 herramientas:
  `query_graph`, `get_node`, `get_neighbors`, `get_community`,
  `god_nodes`, `graph_stats`, `shortest_path`, `list_prs`,
  `get_pr_impact`, `triage_prs`) y `tools/call` reales desde OpenCode.
- Escenarios: A (orchestrator → `engineering-orchestrator.md` +
  `orchestrator.agent.md` copilot + `engineering-feature.md`, cross-capa
  meta/producto) OK; B (comandos `.md` → vacío documentado: nodos de
  archivo sin aristas de llamada) OK-con-limitación; C (instaladores:
  `merge_tree`/`resolve_clients`, `Merge-Tree`/`Get-ClientList`,
  `cdp-chrome.ps1` 5 funciones) OK; D (`affected` exige símbolo, no ruta)
  OK-con-limitación; E (`render-clients.js`, grado 23, 48–63 nodos) OK;
  F (workflows `validate-meta.yml`/`publish.yml` + scripts) OK.
- `AI/` intacto (`git status` solo `graphify-out/` + docs + `.gitignore`);
  triple versión 0.3.2; npm `files` excluye `graphify-out/`.
- Config solo usuario (`~/.config/opencode/opencode.jsonc`,
  `graphify-local`, aditiva); nada versionado que obligue a otros devs.

## Validación T3 (2026-11-03)

Evidencia verificada, no simulada (oportunidades en
`docs/improvements/opportunities.md`):

- A (deuda real): OPP-001, frontmatter sin CI en 2 docs canónicos.
- B (arch): OPP-002, Flow D 7→10 etapas con diseño en el propio flujo.
- C (priorización): OPP-003, impacto/esfuerzo/riesgo por candidato.
- D (implementación): diff de este ciclo; `validate-meta.js` 54 checks
  exit 0, `render --check` 61 OK, triple 0.3.2.
- E (revisión independiente): `reviewer` (subagente distinto) sobre el diff.
- F (preservación): log + registro + backlog + mapa + overview + strategy.
- G (duplicados): re-registro de OPP-001 → `REJECTED (duplicada de OPP-001)`.
- H (SAP BTP): OPP-006 `xsuaa-ias` en `INVESTIGATING`; nada incorporado
  sin fuentes oficiales (separación meta/producto/consumidor intacta).
- Métricas: 6 oportunidades (4 completadas, 1 validando, 1 investigando),
  0 regresiones, 1 delegación (reviewer), `AI/` intacto.
  Codebase Memory / Graphify: verificación en vivo n/d en este turno
  (sin MCP en sesión); último estado documentado 2026-11-03
  (726/790 ready; grafo 517/381). Sync omitida: solo `.md` meta + 1 `.js`
  de validación, sin cambios estructurales que la exijan.

## Validación T3.1 (2026-11-03, operativa en vivo)

Herramientas verificadas en vivo: `graphify` CLI 0.9.97 + MCP
`graphify-local` (10 herramientas) + MCP `codebase-memory`
(`index_status`/`detect_changes`/`search_graph`/`search_code`/
`index_repository` full). `query_graph` exige `question` (no `query`);
`search_code` exige `pattern` (no `query`) — ambos fallos de argumento
limpios y recuperables (D5).

- B1 PASS: `graph_stats` 544/405/162 (build 024a316, stale) →
  `get_node`/`get_neighbors` `render-clients.js` con funciones y líneas
  reales (`collectActual`, `diffMaps`).
- B2 PASS: probe `scripts/__t31-probe.js` (`t31ProbeMarkerAlpha`) →
  `graphify update .` (92% caché AST, rebuild 559/418) → `get_node` lo
  localiza (`L3`); `render-clients.js` intacto (sin sustitución
  incompleta); probe eliminado. Incremental soportado (caché AST).
- B3 PASS: `get_neighbors validate-meta.js` (`fs`/`path`/`cp` L4–6,
  `need()` L10, `fm()` L14) contrastado con fuente — coincide.
  `query_graph` por keywords es ruidoso (arranca por tokens, trunca por
  budget); para impacto de archivo usar `get_node`/`get_neighbors`.
- C1 PASS: `index_status` ready 726/790; `search_graph` halla código real
  (`need`/`fm`); 0 resultados para contenido T3 nuevo → índice
  desactualizado (honesto, no fresco).
- C2 PASS: marcador `t31CbmProbeZeta` en `findings.md` → `index_repository`
  full (774/816) → `search_code` lo recupera (`findings.md:7`, 285 ms) →
  restaurado → reindex (770/813) → 0 resultados. Límite: `search_graph`
  BM25 no recupera `.md` documental (usar `search_code`).
- D1 PASS (B2+C2 combinados, 1 sync por índice). D2 PASS (edición `.md`
  no exigió rebuild del grafo). D3 PASS (probe de código no exigió
  reindex documental — se hizo después, por C2). D4 PASS (`check-update`
  silencio, exit 0, cero syncs). D5 PASS (fallos de argumento limpios,
  tarea no bloqueada, reintento OK). D6 PASS (ciclo 2 refleja lo último:
  probes 0, 770/813; sin duplicados).
- E: `detect_changes` es git-backed (árbol vs `HEAD`): con cambios T3 sin
  commitear queda en 8 tras reindexar → corrección mínima OPP-007 (1
  párrafo §4 lifecycle). `built_at_commit` no cubre contenido sin
  commitear. Sin falsos positivos adicionales.
- F: reviewer APTO (probes 0, §4 fiel, `AI/` intacto aparente;
  runtime como supuesto ajeno — confirmado abajo).
- Coste: 2×`graphify update` (caché 92%) + 2×`index_repository` full en
  repo pequeño; sin telemetría no hay tokens/tiempos.

## Freshness Knowledge Lifecycle (2026-11-03, ver `knowledge-lifecycle.md` §4–§6)

- `detect_changes` proyecto `C-Users-Horan-Desktop-harness-btp`:
  `changed_count=0` (árbol limpio) → cero reindex (escenarios F/H).
- `graphify check-update .` en silencio con HEAD (`024a316`) por delante del
  grafo (`built_at_commit` anterior) en 2 commits solo-docs → correctamente
  sin `update` (clase A, escenarios F/H).
- `index_status`: ready 726/790. `graph_stats`: 517/381/159 con
  `built_at_commit` 2 commits por detrás de HEAD (ambos solo-docs);
  `check-update` en silencio → correctamente sin `update`.
- Fallo de herramienta → `PEND-KNOWLEDGE` en backlog + APTO-CON-PENDIENTE,
  nunca bloqueo (escenario G, política del ciclo).

## Validación T5.3 (2026-11-03, solo-docs producto)

Aislamiento de fixtures + matriz de terminales R6/R7 (OPP-016):

- Cambios ya aplicados (no tocados aquí): `AI/agents/backend-cap.md`
  (fixtures + fix paquete `@sap/cds` vía `cap-cli`),
  `AI/agents/qa-review.md` (matriz terminales R6/R7),
  `AI/skills/cap-cli/SKILL.md` (TRANSITIONS).
- Evidencia: `temp/t52-servicedesk` test:119-150 + srv:78-90.
- Estática: `validate-meta` 54 OK, `render --check` 61 OK, triple 0.3.2.
- QA APTO-CON-PENDIENTES (`npm test` t52 bloqueado entorno npx 90s,
  16 cancelados); reviewer APTO-CON-PENDIENTES (fix paquete ya aplicado).
- Tests pendiente entorno; sync no requerida (solo `.md` producto, clase B).
