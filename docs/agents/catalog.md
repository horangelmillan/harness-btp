# Catálogo de agentes

## Meta internos (`.opencode/agents/`, solo OpenCode, no publicados)

| Agente | Responsabilidad |
|---|---|
| `engineering-orchestrator` | ciclo completo, delegación, verificación, backlog/docs |
| `harness-researcher` | investigación técnica con fuentes+fecha |
| `harness-architect` | diseño, contratos, fuentes canónicas |
| `harness-implementer` | implementación multi-cliente |
| `harness-qa` | pruebas reales con evidencia |
| `sap-btp-specialist` | dominio SAP → capacidades reutilizables |
| `security-engineer` | seguridad sin fricción |
| `documentation-engineer` | docs/backlog/ADR/changelog |
| `mcp-skills-engineer` | MCP/skills sin duplicados |
| `performance-engineer` | tokens/contexto/delegación |
| `reviewer` | revisión independiente por muestreo |

## Producto (`AI/agents`, canónico → `AI/clients/`)

`orchestrator`, `analyst`, `architect`, `backend-cap`, `frontend-ui5`,
`e2e-fiori`, `qa-review`, `deploy-cf`, `documentarian`, `researcher`,
`harness-evolution`. No duplicar: el meta reutiliza sus patrones
(presupuestos, higiene CDP, puerta verify) sin copiar código.
