# System Overview — Meta-Harness

Producto vs meta (ADR-001): `AI/` se distribuye; `.opencode/` raíz + `docs/` +
`scripts/validate-meta.js` son internos (excluidos de npm por `files`).

## Orquestador

`.opencode/agents/engineering-orchestrator.md`: clasifica (feature/research/
refactor/improvement/release/fix), dimensiona (directo vs delegar),
coordina dependencias, consolida, verifica entregables, actualiza
backlog/docs/ADR, registra decisiones. No re-delega decisiones finales.

## Especialistas (`.opencode/agents/`)

| Agente | Dominio | Reutiliza del producto |
|---|---|---|
| `harness-researcher` | docs oficiales, SAP Help, OpenCode, MCP, skills | `researcher`, `context7`, `check-docs` |
| `harness-architect` | arquitectura, orquestación, contratos, fuentes canónicas | `architect`, `render-clients.js` |
| `harness-implementer` | agentes/comandos/skills/scripts, compat multi-cliente | `backend-cap`, `frontend-ui5`, instaladores |
| `harness-qa` | pruebas, instaladores, render, regresiones | `qa-review`, `sap-verify`, `pre-commit-check` |
| `sap-btp-specialist` | CF, CAP, HANA, XSUAA/IAS, UI5/OData, despliegues | `deploy-cf`, `backend-cap`, `frontend-ui5`, `cf-cli`, `cap-cli`, `mta-build` |
| `security-engineer` | app/cloud/DevSecOps, secretos, MCP, supply chain | `cf-safe`, `pre-commit-check` |
| `documentation-engineer` | README, docs, backlog, ADR, changelog | `documentarian` |
| `mcp-skills-engineer` | MCP/skills: evaluar, integrar, documentar | `INICIO.md § Skills candidatas` |
| `performance-engineer` | tokens, contexto, delegación, tiempos | presupuesto anti-bloqueo |
| `reviewer` | revisión independiente, regresiones | `qa-review`, `harness-evolution` (propone, orquestador aplica) |

## MCP (estrategia en `docs/mcp/catalog.md`)

Descubrir antes de instalar. Documentar propósito, consumidores, coste,
alternativas. Hoy solo `graphify-code` (local, deshabilitado). En este
entorno además: `context7`, `codebase-memory`, `github`, `playwright`,
`eslint`, `chrome-devtools`. No inventar servidores/capacidades.

## Skills (catálogo en `docs/skills/catalog.md`)

Reutilizar primero las 4 del producto + globales (`sapui5`,
`systematic-debugging`, `verification-before-completion`,
`test-driven-development`, `git-workflow`). Nuevas solo si hay necesidad
real, canónicas en repo, sin duplicados.

## Flujos (`.opencode/commands/engineering-*.md`)

feature (spec→diseño→división→implementación→pruebas→revisión→docs→backlog),
research (oportunidad→investigación→contraste→propuesta→backlog),
refactor (deuda→dependencias→diseño→implementación→regresión),
improvement (observar harness→medir→cambio acotado→comparar→registrar),
release (verificar→compat→render→tests→changelog→versión→artefactos).
Composables, reutilizan etapas comunes.

## Automejora

OBSERVAR → ANALIZAR → IDENTIFICAR → PROPONER → IMPLEMENTAR → VALIDAR →
DOCUMENTAR. Solo mejoras verificables con regresión (`validate-meta.js` +
`render --check` + versiones). Sin nuevas aprobaciones manuales.

## Eficiencia (prioridad arquitectónica)

Contexto mínimo por agente (rutas + criterios, nunca historial); delegación
selectiva (directo si es trivial); paralelo solo independiente; resúmenes
estructurados con referencias (no reproducir archivos); model selection por
capacidad cuando el cliente lo permita; métricas solo con telemetría real
(nunca inventar).
