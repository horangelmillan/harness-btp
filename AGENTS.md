# harness-btp — reglas de ingeniería (Meta-Harness)

> Este repo tiene DOS capas. En conflicto, manda este archivo.

1. **Producto** (`AI/`): lo que se instala en proyectos SAP. Reglas en
   `AI/AGENTS.md`. Fuente canónica `AI/agents|commands|skills`; generado
   `AI/clients/` (no editar a mano; `node scripts/render-clients.js`).
2. **Meta interno** (`.opencode/` raíz + `docs/` + `scripts/validate-meta.js`):
   herramientas para desarrollar el producto. Solo OpenCode. No se publica
   en npm (`files` allowlist lo excluye). Nombres prefijados `engineering-*`.

## Presupuesto anti-bloqueo (heredado de AI/AGENTS.md, obligatorio)

- Toda delegación `subagent` lleva presupuesto explícito (minutos o nº acciones).
- Prohibido reintentar >3 veces lo mismo; al agotar: entrega parcial + cierre
  limpio (solo PIDs propios, borrar perfiles temporales).
- Éxito solo con evidencia observable. Sin endpoint CDP verificado no hay
  prueba de navegador que dar por hecha (`AI/scripts/cdp-chrome.ps1`).

## Frontera (irrestricta)

- Cero secretos en git. Revisar diff antes de operar.
- No `push`/PR sin orden expresa. Commits locales pequeños, en español.
- Nunca `*.bak` dentro del repo; backup válido fuera o vía git.
- No tocar `AI/clients/` a mano; CI exige `render --check` + triple versión
  (`package.json=VERSION=AI/VERSION`) en verde.
- PowerShell 5.1: prohibidos `ver|head|tail|where <args>|grep`; usar
  `Get-Command`, `Select-Object`, `Select-String`.
- Transitorios en `temp/<tarea>/`; lo que se conserva va a `evidencia/` con referencia.

## Dónde empezar

- Diagnóstico: `docs/engineering/initial-assessment.md`
- Arquitectura: `docs/engineering/system-overview.md`
- Contratos: `docs/engineering/contracts.md`
- Catálogos: `docs/agents/catalog.md`, `docs/skills/catalog.md`, `docs/mcp/catalog.md`
- Backlog: `docs/backlog/backlog.md`
- Flujos: `.opencode/commands/engineering-*.md` (feature, research, refactor,
  improvement, release)
