# Fuentes oficiales del harness BTP

Tabla de documentación oficial que respalda las guías del harness.
Antes de usar una fuente en una spec, re-verifica su estado y registra la fecha:

```powershell
# Windows
powershell -ExecutionPolicy Bypass -File AI/scripts/check-docs.ps1
# Linux/macOS o Git Bash
sh AI/scripts/check-docs.sh
```

`exit 1` = alguna fuente REQUERIDA está rota. `PENDIENTE` = no hubo respuesta
(timeout/DNS: avisa, no falla); actualiza la fecha tras re-verificar.

| Fuente | URL oficial | Qué cubre | Nivel | Última verificación |
|---|---|---|---|---|
| Cloud Foundry CLI | https://docs.cloudfoundry.org/cf-cli/install-go-cli.html | Instalación y uso del CLI `cf` v8 (target, push, plugins como multiapps) | REQUERIDA | 2026-11-04 |
| Cloud MTA Build Tool | https://github.com/SAP/cloud-mta-build-tool | Construcción de MTAR desde `mta.yaml`, comandos `mbt`, requisitos (`make`) | REQUERIDA | 2026-11-04 |
| CAP | https://cap.cloud.sap/docs/get-started/ | Setup Node.js/`cds-dk`, comandos `cds`, arranque de proyectos CAP | REQUERIDA | 2026-11-04 |
| UI5 CLI | https://ui5.github.io/cli/ | Instalación y uso del CLI `ui5` para proyectos UI5/Fiori | REQUERIDA | 2026-11-04 |
| OpenCode | https://docs.opencode.ai/docs | Agente orquestador, MCP servers, configuración (la raíz `docs.opencode.ai/` devuelve 404; `/docs` es la entrada canónica) | REQUERIDA | 2026-11-04 |
| npm trusted publishers | https://docs.npmjs.com/trusted-publishers/ | Publicación OIDC sin tokens de larga vida (CI: GitHub Actions, GitLab, CircleCI) | REQUERIDA | 2026-11-04 |
| 1Password op CLI | https://developer.1password.com/docs/cli/get-started/ | Gestión opcional de secretos de equipo (responde 308 a `/cli/get-started`, verificado con seguimiento; solo referencia opcional) | OPCIONAL | 2026-11-04 |

Verificación 2026-11-04: `webfetch` + `curl.exe` GET (`-L`, timeout 15 s)
y `AI/scripts/check-docs.ps1` en esta máquina (todas OK, `exit 0`).
