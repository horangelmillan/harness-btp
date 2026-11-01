# Prerrequisitos del harness BTP

Verifica tu máquina **antes** de iniciar el flujo (`/flow`):

```powershell
# Windows
powershell -ExecutionPolicy Bypass -File AI/scripts/check-prereqs.ps1
# Linux/macOS o Git Bash
sh AI/scripts/check-prereqs.sh
```

Si tu MVP exige builds o despliegues, promociona opcionales a requeridos:

```powershell
AI/scripts/check-prereqs.ps1 -NeedMtar -NeedCds   # MTAR + CAP/UI5
sh AI/scripts/check-prereqs.sh --need-mtar --need-gh
```

## Requerido siempre

| Herramienta | Para qué | Instalación oficial |
|---|---|---|
| `git` | versiones del MVP | https://git-scm.com/downloads |
| `node` 18+ | CAP, UI5, mbt, scripts | https://nodejs.org/ |
| `cf` CLI v8 | despliegues y lecturas Cloud Foundry | https://docs.cloudfoundry.org/cf-cli/install-go-cli.html |
| cliente agéntico | leer `AGENTS.md` y orquestar | https://docs.opencode.ai/ (o tu cliente; verifica que lea `AGENTS.md`) |

## Opcional según el MVP

| Herramienta | Solo si… | Instalación oficial |
|---|---|---|
| `mbt` + `make` | el MVP construye MTAR | https://github.com/SAP/cloud-mta-build-tool y https://www.gnu.org/software/make/ |
| `java` 17 | builds MTA Java | https://adoptium.net/ |
| `cds` | la spec exige CAP (`npx -p @sap/cds-dk` vale, sin instalación global) | https://cap.cloud.sap/docs/get-started/ |
| `ui5` | la spec exige UI5/Fiori | https://ui5.github.io/cli/ |
| `gh` | la spec pide repo remoto/PR | https://cli.github.com/ |
| `op` (1Password) | el equipo lo adopta | https://developer.1password.com/docs/cli/get-started/ |

## MCPs y skills (no detectables desde shell)

El script solo verifica **presencia de archivos** (`AI/.opencode/skills/*/SKILL.md`,
`AI/.opencode/agents/*.md`, `AI/opencode.fragment.jsonc`). Los **MCPs viven en tu
cliente agéntico**, no en el repo: debes tener configurados
`context7`, `codebase-memory`, `github`, `playwright`, `eslint` y `chrome-devtools`.

- MCPs en OpenCode: https://docs.opencode.ai/mcp-servers/
- Context7: https://github.com/upstash/context7
- Playwright MCP: https://github.com/microsoft/playwright-mcp
- Chrome DevTools MCP: https://github.com/ChromeDevTools/chrome-devtools-mcp
- GitHub CLI (MCP `github`): https://cli.github.com/
- ESLint: https://eslint.org/docs/latest/use/getting-started

## Re-verificar

Tras instalar lo que falte, re-ejecuta `check-prereqs` (mismo comando de arriba):
`exit 0` = puedes empezar; `exit 1` = aún falta algo **REQUERIDO** (la tabla dice cuál y dónde instalarlo).
El script nunca imprime secretos (solo ejecuta `<comando> --version`).
