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
