---
description: Ingeniería feature del harness (spec → release parcial)
agent: engineering-orchestrator
---

Flow A — Feature: $ARGUMENTS (p. ej. `añadir --backup-dir a install.sh`).

1. Analizar solicitud y clasificar complejidad.
2. Investigar contexto (`harness-researcher` si hay docs/MCP implicados).
3. Spec mínima o diseño (`harness-architect` si toca ≥3 archivos).
4. Dividir y delegar (`harness-implementer`, `sap-btp-specialist` si BTP).
5. Probar (`harness-qa`: `render --check`, versiones, `validate-meta.js`).
6. Revisar (`reviewer` por muestreo).
7. Docs + backlog + ADR (`documentation-engineer`). Cierre con evidencias.
