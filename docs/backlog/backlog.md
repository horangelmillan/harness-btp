# Backlog

## Ahora (P-siguiente)

- [ ] Branch protection: marcar job `validate` como required en `main`.
- [ ] Pin SHA acciones (recomendación security, hoy `@v6` por convención).
- [ ] Indexar `harness-btp` en `codebase-memory`.
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
