# Catálogo MCP

Estrategia: descubrir antes de instalar; documentar propósito, consumidores,
coste, alternativas. No inventar servidores.

| MCP | Propósito | Consumidores | Estado |
|---|---|---|---|
| `graphify-code` (local, `AI/opencode.fragment.jsonc`) | índice de código | implementer, qa | `enabled:false`, opcional |
| `graphify-local` (local, solo usuario, ver `docs/mcp/graphify-local.md`) | grafo estructural harness-btp (517 nodos, STDIO) | orchestrator, architect, implementer, qa | opt-in, esta máquina |
| `context7` | docs vigentes (CAP/UI5/CF/MTA) | researcher, specialists | entorno, por fase |
| `codebase-memory` | grafo del repo indexado | orchestrator, implementer | entorno, sin reindex redundante; puerta `detect_changes`, reindex completo solo B/T2 con presupuesto (verificado 2026-11-03) |
| `github` | repos remotos/PRs | orchestrator (solo si spec lo pide) | entorno |
| `playwright` | E2E Fiori (exige CDP `ensure` antes) | e2e, qa | entorno `:9222` |
| `chrome-devtools` | debug, traces, LCP, heaps | e2e, qa, performance | entorno |
| `eslint` | calidad JS/TS | implementer, qa | entorno |

Coste: cada MCP suma contexto y llamadas; cargar solo en su fase
(`AI/AGENTS.md § MCP y skills`). Sin telemetría no hay métricas de coste.
> Telemetría mínima local (duración/exit sin plataforma): `docs/engineering/metrics/telemetry-local.md`; plantilla por fases: `AI/docs/opencode-fases.md`.
