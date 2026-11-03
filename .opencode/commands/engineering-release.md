---
description: Release del harness (verificar → versionar → publicar)
agent: engineering-orchestrator
---

Flow E — Release: $ARGUMENTS (p. ej. `0.3.3`).

1. `harness-qa`: `render --check`, triple versión, instaladores, `validate-meta.js`.
2. Compat multi-cliente (tabla `install --client`, `.gitignore` sin duplicados).
3. `documentation-engineer`: changelog, README, `docs/releases/`.
4. Versionar (`package.json`+`VERSION`+`AI/VERSION`+tag `vX.Y.Z` coinciden).
5. `npm pack --dry-run`; push tag solo con orden expresa (publica CI con OIDC).
