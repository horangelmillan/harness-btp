# Testing Strategy

Validación sin inventar verde:

1. `node scripts/render-clients.js --check` — canónico vs generado (CI lo exige).
2. `node .github/scripts/check-release-versions.js` — triple versión.
3. `node scripts/validate-meta.js` — frontmatter meta (name+description),
   docs presentes, + 1 y 2. Puerta local antes de commit.
4. Instaladores: `install.ps1 -?` / `install.sh --help`, fusiones en `AI-tmp`.
5. `check-prereqs.*`, `check-docs.*`, `pre-commit-check.ps1` en su fase.
6. Navegador solo con CDP verificado (`cdp-chrome.ps1 ensure`→`cleanup`).

Cero tests unitarios heredados del harness; `validate-meta.js` es el primer
gate ejecutable local. `reviewer` verifica por muestreo independiente.

## Validación P1 (2026-11-03)

Evidencia verificada, no simulada:

- `npm pack --dry-run`: 128 ficheros. Excluidos `.opencode/`, `docs/`,
  `validate-meta`, `AGENTS.md`, `.github`. Incluidos
  `bin/`, `templates/`, `installers/`, `AI/`.
- Escenario A (researcher): 7/7 fuentes oficiales OK.
- Escenario B (architect): nuevo workflow `validate-meta.yml` + security:
  APTO CON CONDICIONES, 5 condiciones.
- Escenario C (implementer creó `validate-meta.yml` + unificó `publish.yml`;
  qa): APTO, 38 checks exit 0, `AI/` intacto, 1 regresión menor:
  granularidad log CI.
- MCP: `codebase` / `ctx7` / `github` / `playwright` / `eslint` /
  `chrome-devtools` configurados a nivel usuario; `eslint` sin config en
  repo; `harness-btp` NO indexado en `codebase-memory`; `graphify-code`
  deshabilitada; `Neon` / `browser` fuera de catálogo.
- Prueba negativa por inspección: todas las ramas fail → exit 1.
