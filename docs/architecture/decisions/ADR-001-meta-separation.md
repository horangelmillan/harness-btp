# ADR-001 — Separación producto vs meta

Fecha: 2026-11-03 · Estado: aceptada

## Contexto

`AI/` se distribuye por npm (`files` allowlist). Los agentes internos de
ingeniería no deben llegar a proyectos consumidores ni inflar el paquete.

## Decisión

- Producto: `AI/` (canónico + `clients/` generado). Multi-cliente intacto.
- Meta interno: `.opencode/` raíz + `docs/` + `scripts/validate-meta.js`.
  Versionado en git, excluido de npm (fuera de `files`), solo OpenCode,
  nombres prefijados `engineering-*` / `harness-*`.
- `AGENTS.md` raíz como fuente de precedencia (producto vs meta).

## Consecuencias

- `render --check` y triple versión siguen verdes; el paquete no crece.
- El meta evoluciona sin romper consumidores; el producto evoluciona vía
  flujos meta con revisión.
