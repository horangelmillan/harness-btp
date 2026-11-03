# Initial Assessment — harness-btp como producto y como objeto de ingeniería

Fecha: 2026-11-03 · Versión base: v0.3.2 · Rama: main

Fuente: auditoría P0 con 3 subagentes (17+11+~15 lecturas) + verificación directa
(`node scripts/render-clients.js --check` → OK 61 archivos,
`node .github/scripts/check-release-versions.js` → OK 0.3.2).

## 1. Arquitectura actual

Producto: harness Markdown + shell que lleva un MVP SAP de spec → deploy CF.
- Canónico: `AI/agents/*.md` (11), `AI/commands/*.md` (flow, verify, prepare),
  `AI/skills/*/SKILL.md` (4). Generado: `AI/clients/<cliente>/` vía
  `scripts/render-clients.js` (sin dependencias, EOL LF, `--check` en CI).
- Distribución: `install.ps1` / `install.sh` / `bin/harness-btp.js` (lógica
  paritaria `SKIP/CREATE/BACKUP/OK`, flag `--client auto|all|lista`,
  fusión `.gitignore` aditiva, nunca toca `package.json`/`mta.yaml`).
- Publicación: `create-harness-btp` en npm, tag `v*` → `publish.yml`
  (OIDC sin secretos) con doble guardia (render `--check` + triple versión
  `package.json=VERSION=AI/VERSION`).
- Orquestación producto: `orchestrator` + puerta `/verify` (solo lectura) +
  `/flow` (etapas 0–10) + `/prepare` (preflight). Presupuesto anti-bloqueo
  obligatorio (time-box, regla 3-fallos=stop, entrega parcial + kill por PID),
  higiene CDP (`cdp-chrome.ps1 status/ensure/cleanup`), `cf-safe.ps1`
  como único punto de salida a `cf`, frontera no-versionado
  (`temp/`, `*.mtar`, `.env`, `*.bak`, `.opencode/` real).

## 2. Fortalezas (reutilizar tal cual en Meta-Harness)

- Protocolo genérico extraíble: orquestación delegante, presupuestos,
  higiene CDP, puerta verify, `SKIP/CREATE/BACKUP/OK` parseables.
- `render-clients.js` + `--check`: patrón fuente-canónica → artefactos
  generados con guardia CI. Modelo para cualquier generación meta.
- `check-prereqs.*`, `check-docs.*`, `pre-commit-check.ps1`, `cf-safe*.ps1`,
  `cdp-chrome.ps1`, `provision-espacio.template.ps1`, `specs/_template.md`,
  `prompts/setup.md`: validadores y plantillas ya probados.
- `INICIO.md` como onboarding ejemplar; matriz compatibilidad honesta
  (solo OpenCode×Windows verificado, resto esperado).

## 3. Debilidades / deuda

- Acoplamiento BTP total en agentes/skills/docs (`cf/mbt/cds`, `mta.yaml`,
  XSUAA/DIE/iFlow, trial). No reutilizable literal fuera de BTP.
- Doble fuente aparente: `AI/.opencode/` (legacy intacto) vs
  `AI/clients/opencode/` (generado). Confunde; conservar por compatibilidad.
- `BACKUP` dentro del destino (`AI.bak`, `<dir>.bak`) contradice
  `AI/AGENTS.md § Frontera` (prohíbe `*.bak` en repo; propone `%TEMP%`/git).
- Fragmento `.gitignore` solo cubre mundo opencode; falta multi-cliente.
- Cero tests del harness (solo gates CI). Sin `opencode.jsonc` real de
  ejemplo, sin evidencia Linux/macOS ni Claude/Cursor/Copilot.
- Triple versión manual; `harness-btp.js --ref` informativo; `all` excluye
  `aider` en silencio; `install.sh` sin `trap`; `appendFileSync` sin `mkdir -p`.

## 4. Oportunidades

- Abstracción `destino` (CF hoy, otros mañana); `skills/<destino>/` como plugin.
- Comandos parametrizados por destino; `specs/_template` agnóstica.
- Catálogos MCP/skills, flujos de ingeniería reutilizables, backlog/ADR
  persistentes, automejora OBSERVAR→…→DOCUMENTAR, métricas de eficiencia.
- `pnpm dlx create-harness-btp` ya publicado (0.3.2); npm muestra 2125
  descargas el 01-11-2026 y 0 después (scanners, no adopción).

## 5. Componentes: reutilizar / evolucionar / crear

| Reutilizar (sin tocar) | Evolucionar (con cuidado) | Crear (faltante meta) |
|---|---|---|
| Presupuestos, higiene CDP, puerta verify, `cf-safe`, `check-*`, `render --check`, plantillas, `SKIP/CREATE/BACKUP/OK` | `AI/.opencode` vs `clients/opencode` (documentar, no romper), backup fuera del repo, `.gitignore` multi-cliente, `bump-version`, CI en PR | Orquestador meta + 10 especialistas internos, contratos, catálogos MCP/skills, 5 flujos, docs persistentes, backlog/ADR, `validate-meta.js`, métricas |

## 6. Propuesta arquitectónica (decisión ADR-001)

- Separación estricta: **producto** (`AI/`, publicado en npm) vs
  **meta interno** (`.opencode/` raíz + `docs/` + `scripts/validate-meta.js`,
  versionado en git, excluido de npm por `files` allowlist).
- Meta solo para OpenCode (cliente de esta sesión); producto sigue
  multi-cliente intacto. Nombres meta prefijados `engineering-*` /
  `harness-*` para no colisionar con `AI/agents`.
- Fases P0→P7 incrementales, cada una deja `render --check` y versiones en verde.
- Eficiencia: contexto mínimo por agente, delegación selectiva, resúmenes
  estructurados, sin reindexación redundante, sin métricas inventadas.

## Addendum P1 (2026-11-03, sin reescribir el diagnóstico)

- La validación P1 confirma la separación ADR-001: `pack` excluye meta,
  `AI/` intacto.
- Deuda confirmada: `eslint` sin config, proyecto sin indexar,
  `pre-commit-check` con `echo` no apto para CI.
- Matriz compat sigue esperada salvo OpenCode×Windows.
