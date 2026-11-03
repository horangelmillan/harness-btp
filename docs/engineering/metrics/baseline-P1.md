---
title: Baseline de métricas P1 (parcial reconstruida)
date: 2026-11-03
status: parcial
---

# Baseline P1 — solo observado (tiempos n/d)

> Reconstruida el 2026-11-03 desde evidencias en repo.
> Tiempos de ejecución n/d (sin telemetría entonces): no inventar.
> Metodología T-P2-02: registrar solo hechos verificables.

## P0 — auditoría (fuente: `docs/engineering/initial-assessment.md:5-7`)

- 3 subagentes de auditoría.
- `render --check` OK: 61 archivos.
- Triple versión OK: 0.3.2 (`package.json` = `VERSION` = `AI/VERSION`).

## P1 — meta mínimo (fuente: `docs/backlog/backlog.md` § Hecho)

- 11 agentes meta (orquestador + 10 especialistas).
- 5 flujos (`engineering-feature|research|refactor|improvement|release`).
- Contratos (`docs/engineering/contracts.md`).
- Catálogos agentes/MCP/skills.
- ADR-001 (separación producto/meta).
- Backlog inicial.
- `validate-meta.js` en verde + gate CI `validate-meta.yml` + `publish` unificado.

## Lo que NO hay

- Tiempos por fase: n/d.
- Conteo de lecturas/llamadas P1: n/d.
- Métricas de coste MCP o tokens: n/d (sin telemetría, ver
  `docs/engineering/system-overview.md` § Eficiencia).
