# Matriz de compatibilidad OS × cliente (canónico meta)

> Fuente canónica de estado de compatibilidad del harness. `README.md § Compatibilidad`
> es un resumen; ante discrepancia manda este archivo.
> Leyenda y reglas de clasificación en § Leyenda. Última actualización: 2026-11-03 (R2.3-QA).

## Leyenda

| Estado | Significado | Requisito |
|---|---|---|
| `VERIFIED` | Funciona de verdad en este equipo | Ejecución real con salida íntegra guardada en `temp/r23/logs/` |
| `NOT VERIFIED` | Sin evidencia; no se afirma que funcione | Inspección estática como máximo |
| `BLOCKED` | Intento real impedido por causa externa | Comando + error que lo demuestra |

Reglas honestas (vinculantes):

- Git Bash ≠ Linux. WSL ≠ Linux nativo. `sh -n` ≠ funcional. Config ≠ funcional.
- Presencia del binario (`Get-Command`) ≠ funcional.
- Nunca `VERIFIED`/`PARTIAL` sin ejecución real.

## Tabla OS × cliente

| OS \ Cliente | OpenCode | Claude Code | Cursor | GitHub Copilot |
|---|---|---|---|---|
| **Windows build 26300** | `VERIFIED` ① | `NOT VERIFIED` ② | `NOT VERIFIED` ③ | `NOT VERIFIED` ④ |
| **Linux nativo** | `NOT VERIFIED` ⑤ | `NOT VERIFIED` ⑥ | `NOT VERIFIED` ⑦ | `NOT VERIFIED` ⑧ |
| **macOS nativo** | `NOT VERIFIED` ⑨ | `NOT VERIFIED` ⑩ | `NOT VERIFIED` ⑪ | `NOT VERIFIED` ⑫ |

## Detalle por celda

### ① Windows × OpenCode → `VERIFIED` (2026-11-03)

- **Versiones:** Windows 10.0.26300 (Windows 11 Pro), PS 5.1 (5.1.26100.9818),
  OpenCode v2.0.23, Node v24.22.1, npm 11.19.1, git 2.49, harness v0.3.2.
- **Comandos (todos exit 0, salida íntegra en `temp/r23/logs/`):**

  | Comando | Resultado | Log |
  |---|---|---|
  | `install.ps1 -Dest temp/r23/win-opencode` | OK + `Test-Path` AI/AGENTS.md, AGENTS.md, `.opencode/` | `install-win-opencode.log` |
  | `node scripts/validate-meta.js` (raíz repo) | 55 checks OK | `validate-meta.log` |
  | `node scripts/render-clients.js --check` (raíz repo) | 61 archivos OK | `render-check.log` |
  | `AI/scripts/check-docs.ps1` | ninguna fuente REQUERIDA rota | `check-docs.log` |
  | `AI/specs/examples/app-ui5-qunit-opa/scripts/run-ui5-tests.ps1` (defecto, puertos 4022+9222) | HTTP 4/4 + QUnit 13/0 + OPA5 5/0, cleanup puertos libres | `fixture-ui5.log` |
  | `node bin/harness-btp.js --help` | uso impreso (init --dest/--force/--ref/--client) | terminal (no log) |
  | `AI/scripts/check-prereqs.ps1` | exit 1 SOLO por `cf` (ver limitaciones) | `check-prereqs.log` |
- **Limitaciones:** `check-prereqs` REQ `cf` = FALTA porque el `cf` en PATH es
  `1.0.0-beta.25` y no el CLI de Cloud Foundry v8 (aviso del propio script);
  resto REQ OK; OPT `ui5`/`op` ausentes (no bloquean). Sin BTP real (sin entorno CF).

### ② Windows × Claude Code → `NOT VERIFIED`

- **Evidencia:** `Get-Command claude` sin resultado (binario ausente en este equipo).
- **Fecha:** 2026-11-03. **Motivo:** sin binario no hay ejecución posible;
  `AI/clients/` contiene adapter renderizado pero config ≠ funcional.

### ③ Windows × Cursor → `NOT VERIFIED`

- **Evidencia:** `Get-Command cursor` resuelve a `cursor.cmd` (editor presente),
  pero presencia ≠ funcional: el harness nunca se instaló ni ejecutó bajo Cursor.
- **Fecha:** 2026-11-03. **Motivo:** sin ejecución real no se clasifica.

### ④ Windows × GitHub Copilot → `NOT VERIFIED`

- **Evidencia:** `Get-Command copilot` resuelve a shim de VS Code
  (`copilot-shim/copilot.exe`); `gh` 2.95.0 presente (solo CLI de GitHub, no el agente).
- **Fecha:** 2026-11-03. **Motivo:** presencia del shim ≠ agente funcional con el harness.

### ⑤–⑫ Linux nativo / macOS nativo (× los 4 clientes) → `NOT VERIFIED`

- **Evidencia estática (igual para las 8 celdas):** `Test-Path install.sh` = True,
  shebang `#!/bin/sh` (POSIX), `AI/docs/prerequisitos.md` documenta
  `sh AI/scripts/check-prereqs.sh`; README afirmaba par `.sh` "verificado en
  Git Bash" — Git Bash ≠ Linux, WSL ≠ Linux, `sh -n` ≠ funcional.
- **Fecha:** 2026-11-03. **Motivo:** sin máquina nativa Linux/macOS no hay
  ejecución posible; `install.sh` nunca se ejecutó (ni siquiera bajo Git Bash
  en este turno: `sh` no existe en este PATH de PowerShell).

## Alcance y no-objetivos

- Esta matriz cubre **instalación + validación del harness** (instaladores,
  `check-prereqs`, `check-docs`, `validate-meta`, `render --check`, fixture R2.2).
  No cubre despliegues SAP BTP/CF (sin entorno real) ni telemetría de clientes.
- Los logs de `temp/r23/logs/` son transitorios de la tarea R2.3 (ignorados por git);
  la evidencia canónica es esta matriz + `docs/backlog/backlog.md`.
- Promover una celda a `VERIFIED` exige ejecución real en el OS nativo con log
  íntegro y las versiones registradas, como la celda ①.
