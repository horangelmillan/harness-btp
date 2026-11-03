# `opencode.jsonc` por fases (plantilla `AI/opencode.jsonc.example`)

Ubicación: la plantilla vive en `AI/opencode.jsonc.example`. El real es LOCAL:
copiar a `<raíz>/opencode.jsonc` al instalar (está ignorado; nunca se commitea).

## Uso

1. Copiar el ejemplo a `<raíz>/opencode.jsonc`.
2. Descomentar SOLO el bloque de la fase en curso (añadir la coma que falte).
3. Rellenar `<...>` en el real local. Nunca claves en repo.
4. Reiniciar OpenCode. Validar con `node scripts/check-opencode-example.js`.

## Placeholders

`<CONTEXT7-MCP-URL>`, `<GITHUB-MCP-URL>`, `<GITHUB-PORTADOR>`,
`<CODEBASE-MEMORY-COMMAND>`, `<ESLINT-MCP-COMMAND>`,
`<PLAYWRIGHT-MCP-COMMAND>`, `<CHROME-DEVTOOLS-MCP-COMMAND>`:
solo existen en el real local; el validador los ignora (no son secreto).

## Habilitar por fase

| Fase | MCP | Requisito |
|---|---|---|
| F1 Investigación | `context7`, `codebase-memory` | proyecto indexado (sin reindex redundante) |
| F4 Desarrollo | `graphify-code` (único activo), `eslint` | índice generado tras instalar |
| F7 E2E | `playwright`, `chrome-devtools` | `ensure` antes / `cleanup` después (`AI/scripts/cdp-chrome.*`) |
| F0 Transversal | `github` (solo si la spec pide repo/PR) | portador solo local |

`graphify-local` NO va en el proyecto: es opt-in de esta máquina (ver catálogo).

## Validar

`node scripts/check-opencode-example.js` → `OK: ... ESTRUCTURALMENTE VÁLIDO
(no implica conectado)`. No lanza MCP ni usa red.

## Telemetría mínima local

Envolver comandos con `AI/scripts/log-telemetry.js` (opt-in
`HARNESS_TELEMETRY=1`); sin opt-in no escribe nada. Consultar:
`temp/telemetry/telemetry.jsonl` (o `$HARNESS_TELEMETRY_FILE`).
Deshabilitar: no exportar la variable (o `=""`). Detalle y límites:
`docs/engineering/metrics/telemetry-local.md`.

## Qué recoge / qué NO

Recoge: `ts/phase/task/cmd/duration_ms/exit_code` (+`steps` solo con fuente).
NO recoge: stdout/stderr, entorno, claves (aborta ante ellas), usuario/host,
red ni plataforma externa.

## Limitaciones

Medición local aproximada (ms); `steps` sin fuente se omite; sin telemetría
del cliente no hay métricas de coste ni de tokens (ver baseline-P1).

## No-conectividad

Esta plantilla y su validador NO prueban conexión con ningún MCP ni
plataforma: verde estructural ≠ servidor conectado.
