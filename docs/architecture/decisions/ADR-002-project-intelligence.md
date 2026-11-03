# ADR-002 — Project Intelligence por referencias

Fecha: 2026-11-03 · Estado: aceptada

## Contexto

P2 necesitaba mapa de conocimiento, guía de impacto proporcional y
baseline de métricas sin duplicar catálogos ni inventar telemetría
(tokens n/d, `harness-btp` no indexado en `codebase-memory`).

## Decisión

- `docs/engineering/knowledge-map.md` y `docs/engineering/impact-guide.md`
  referencian catálogos/flujos existentes; no copian su contenido
  (regla anti-duplicación verificada por `validate-meta.js`).
- Clasificación T0/T1/T2 con intelligence-pack opcional en
  `engineering-feature|refactor|improvement`; T0 directo sin delegar.
- `docs/engineering/metrics/baseline-P1.md`: solo hechos observados,
  tiempos n/d explícitos, nunca inventar.

## Consecuencias

- `validate-meta.js` 46 checks verde; `render --check` 61 OK; triple 0.3.2.
- QA T-P2-05 APTO, 0 falsos positivos (2×T0 1×T1 2×T2).
- El mapa lo mantiene `harness-architect` en T1/T2; el orquestador lo
  consulta antes de delegar.
