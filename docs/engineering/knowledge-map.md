---
title: Mapa de conocimiento del Meta-Harness
date: 2026-11-03
status: vigente
---

# Knowledge Map — Meta-Harness

Nodos y aristas como **referencias** a los catálogos canónicos.
No duplica contenido: el detalle vive en cada catálogo/fuente.

## Nodos (referencias)

| Nodo | Referencia canónica |
|---|---|
| Orquestador + especialistas (11) | `docs/agents/catalog.md` § Meta internos |
| Agentes producto (11, reutilizar patrones) | `docs/agents/catalog.md` § Producto |
| MCP (7, descubrir antes de instalar) | `docs/mcp/catalog.md` |
| Grafo estructural local (Graphify, opt-in) | `docs/mcp/graphify-local.md` |
| Skills producto (4) + globales + meta | `docs/skills/catalog.md` |
| Flujos (5: feature/research/refactor/improvement/release) | `docs/engineering/system-overview.md` § Flujos |
| Contratos delegación/respuesta | `docs/engineering/contracts.md` |
| Separación producto/meta | `docs/architecture/decisions/ADR-001-meta-separation.md` |
| Diagnóstico P0 + addendum P1 | `docs/engineering/initial-assessment.md` |
| Backlog (fuente de pendientes) | `docs/backlog/backlog.md` |
| Guía de impacto (T0/T1/T2) | `docs/engineering/impact-guide.md` |
| Métricas (solo observado) | `docs/engineering/metrics/baseline-P1.md` |

## Aristas (quién usa qué)

- Orquestador → catálogo agentes: elige especialista sin copiar su spec.
- Orquestador → impact-guide: clasifica T0/T1/T2 antes de delegar.
- Implementer/qa → catálogo MCP: solo MCP listados; si falta, propone vía
  `mcp-skills-engineer`, no lo inventa.
- Implementer → catálogo skills: reutiliza producto/globales primero.
- Todos → contracts: delegación con presupuesto, respuesta ≤10 líneas.
- Todos → ADR-001: meta fuera de npm, producto multi-cliente intacto.
- Architect → system-overview § Flujos + initial-assessment §5: diseña
  sobre lo existente (reutilizar/evolucionar/crear).
- Documentation → backlog + metrics: registra sin inventar tiempos.

## Regla anti-duplicación

Si un dato ya vive en un catálogo, aquí solo va el enlace.
`scripts/validate-meta.js` falla ante MCP mencionado en `.opencode/`
no listado en `docs/mcp/catalog.md`.
