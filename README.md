# harness-btp

[![version](https://img.shields.io/badge/version-v0.3.0-blue)](https://github.com/horangelmillan/harness-btp/releases/tag/v0.3.0)
[![license](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![platform](https://img.shields.io/badge/platform-windows%20%7C%20linux%20%7C%20macos-lightgrey)](https://github.com/horangelmillan/harness-btp)
[![agent](https://img.shields.io/badge/agent-any%20AGENTS.md--compatible-purple)](https://github.com/horangelmillan/harness-btp)

Reglas, agentes y scripts reutilizables para llevar un MVP SAP de la especificación al despliegue en Cloud Foundry, con cualquier cliente agéntico que lea `AGENTS.md`.

Para quien construye MVPs SAP BTP y quiere empezar cada proyecto con el mismo flujo probado, sin copiar y pegar. Funciona en Windows, Linux y macOS, con OpenCode, Claude Code o cualquier otro cliente que lea `AGENTS.md` y ejecute scripts del proyecto.

## Contenidos

- [Features](#features)
- [Requisitos](#requisitos)
- [Quickstart](#quickstart)
- [Instalación](#instalación)
- [Instalación asistida por agente](#instalación-asistida-por-agente)
- [Actualizar y desinstalar](#actualizar-y-desinstalar)
- [Adaptadores opcionales](#adaptadores-opcionales)
- [Multi-cliente](#multi-cliente)
- [Estructura del repo](#estructura-del-repo)
- [Cómo lo descubre el agente](#cómo-lo-descubre-el-agente)
- [Troubleshooting](#troubleshooting)
- [Compatibilidad](#compatibilidad)
- [Contribuir](#contribuir)
- [Licencia](#licencia)
- [Changelog](#changelog)

## Features

- **Carpeta `AI/` sin envolver:** se instala dentro de tu proyecto (nuevo o existente) sin mover ni renombrar nada de lo que ya tienes.
- **Idempotente con `SKIP` / `-Force` + backup:** repetir la instalación no pisa nada; solo reemplaza con `-Force` (`.ps1`) o `--force` (`.sh`) y guarda copia en `AI.bak`.
- **Sin secretos:** el repo no contiene credenciales, tokens ni rutas de máquina; solo nombres y placeholders por paisaje.
- **Tres formas de instalar:** `degit`, `git clone` o `pnpm dlx`, todas ancladas a un tag versionado.
- **Versionado por tags:** cada versión es un tag `vX.Y.Z`; actualizar es repetir el comando contra el tag nuevo.
- **Instaladores pares:** `install.ps1` (PowerShell) e `install.sh` (bash/sh) con la misma lógica (`SKIP` / `CREATE` / `BACKUP` / `OK`). Elige el de tu shell.
- **Agnóstico al cliente:** el núcleo es Markdown + shell (`AI/AGENTS.md`, `AI/INICIO.md`, `AI/docs/`, `AI/scripts/`). `AI/.opencode/` y `AI/opencode.fragment.jsonc` son adaptadores opcionales de ejemplo, no requisitos (ver [Adaptadores opcionales](#adaptadores-opcionales)).
- **El agente se adapta solo:** deja un puntero `AGENTS.md` en la raíz y el cliente encuentra `AI/AGENTS.md`, `INICIO.md`, agentes, skills y plantilla de spec.

## Requisitos

| Necesitas | Versión | Para qué |
|---|---|---|
| PowerShell 5.1+ o bash/sh | incluido en el SO | ejecutar `install.ps1` / `install.sh` |
| Node.js 18+ | solo si usas `degit` o `pnpm dlx` | descargar e instalar el harness |
| `gh` (opcional) | cualquiera reciente | clonar repo privado o crear PRs |
| Cliente agéntico | cualquiera reciente que lea `AGENTS.md` (OpenCode, Claude Code, etc.) | leer `AGENTS.md` y orquestar el flujo |

> Sin Node también puedes instalar vía `git clone`, que no lo necesita.

## Quickstart

El camino de 30 segundos en un proyecto nuevo. Elige tu shell:

PowerShell (Windows):

```powershell
npx -p degit degit horangelmillan/harness-btp#v0.3.0 AI-tmp -- AI-tmp
powershell -ExecutionPolicy Bypass -File AI-tmp/install.ps1 -Dest .
Remove-Item -Recurse -Force AI-tmp
```

bash (Linux, macOS o Git Bash):

```bash
npx -p degit degit horangelmillan/harness-btp#v0.3.0 AI-tmp -- AI-tmp
sh AI-tmp/install.sh --dest .
rm -rf AI-tmp
```

Eso es todo. Abre el proyecto en tu cliente agéntico y el agente ya sabe qué hacer: lee `AGENTS.md` → `AI/AGENTS.md` → `AI/INICIO.md`.

## Instalación

### Opción 1 — degit (recomendado)

Descarga solo lo necesario, sin historial git:

PowerShell:

```powershell
npx -p degit degit horangelmillan/harness-btp#v0.3.0 AI-tmp -- AI-tmp
powershell -ExecutionPolicy Bypass -File AI-tmp/install.ps1 -Dest .
Remove-Item -Recurse -Force AI-tmp
```

bash:

```bash
npx -p degit degit horangelmillan/harness-btp#v0.3.0 AI-tmp -- AI-tmp
sh AI-tmp/install.sh --dest .
rm -rf AI-tmp
```

### Opción 2 — git clone

Clon superficial anclado al tag:

PowerShell:

```powershell
git clone --branch v0.3.0 --depth 1 https://github.com/horangelmillan/harness-btp AI-tmp
powershell -ExecutionPolicy Bypass -File AI-tmp/install.ps1 -Dest .
Remove-Item -Recurse -Force AI-tmp
```

bash:

```bash
git clone --branch v0.3.0 --depth 1 https://github.com/horangelmillan/harness-btp AI-tmp
sh AI-tmp/install.sh --dest .
rm -rf AI-tmp
```

### Opción 3 — pnpm dlx

Sin descargas manuales (requiere publicar `create-harness-btp` en el registry). Igual en todos los SO:

```bash
pnpm dlx create-harness-btp@0.3.0 --dest .
```

### Qué hace el instalador

- `CREATE: AI/` o `SKIP: AI/ ya existe` (solo lo reemplaza con `-Force` / `--force`, con backup a `AI.bak`).
- `CREATE: AGENTS.md` o `SKIP: AGENTS.md ya existe` (tu `AGENTS.md` propio se conserva; con `-Force` / `--force` se respalda a `AGENTS.md.bak`).
- Fusiona el árbol del cliente agéntico (`--client`, por defecto `auto`) desde `AI/clients/<cliente>/` en la raíz (ver [Multi-cliente](#multi-cliente)): sin fuerza solo copia los archivos que falten (`SKIP: <dir>/<ruta> ya existe` por cada uno conservado); con `-Force` / `--force` respalda cada dir a `<dir>.bak` (`BACKUP: <dir>/ -> <dir>.bak`) y copia todo.
- Fusiona `.gitignore`: añade las líneas que falten, sin duplicar ni borrar las tuyas.
- **No toca** `package.json` ni `mta.yaml` de tu proyecto, nunca.

Salida típica en proyecto nuevo:

```text
CREATE: AI/ (v0.3.0)
CREATE: AGENTS.md
CLIENT: auto -> opencode
CREATE: .opencode/ (+17 archivos)
OK: harness v0.3.0 instalado
```

## Instalación asistida por agente

Si prefieres que tu agente lo haga todo (clonar + instalar), pégale esta línea. Solo crea la carpeta vacía y vincúlala a tu cliente:

```text
Déjame este proyecto listo con el harness BTP: lee https://raw.githubusercontent.com/horangelmillan/harness-btp/main/prompts/setup.md y síguelo al pie de la letra. Si te falta un dato (p. ej. la URL del repo a clonar), pregúntamelo antes de suponer.
```

Vale para proyecto nuevo (con URL), existente, Windows/Linux/macOS y cualquier cliente que lea este README. El archivo `prompts/setup.md` vive versionado con el harness: siempre está al día sin que cambies tu línea.

## Actualizar y desinstalar

**Actualizar:** repite el mismo comando de instalación contra el tag nuevo. Sin `-Force` / `--force` lo existente se conserva (`SKIP:`); con fuerza se reemplaza con backup:

PowerShell:

```powershell
npx -p degit degit horangelmillan/harness-btp#v0.3.0 AI-tmp -- AI-tmp
powershell -ExecutionPolicy Bypass -File AI-tmp/install.ps1 -Dest . -Force
Remove-Item -Recurse -Force AI-tmp
# tu versión anterior queda en AI.bak por si quieres comparar
```

bash:

```bash
npx -p degit degit horangelmillan/harness-btp#v0.3.0 AI-tmp -- AI-tmp
sh AI-tmp/install.sh --dest . --force
rm -rf AI-tmp
# tu versión anterior queda en AI.bak por si quieres comparar
```

**Desinstalar:** borra la carpeta y el puntero. No deja servicios ni hooks:

PowerShell:

```powershell
Remove-Item -Recurse -Force AI
Remove-Item -Force AGENTS.md  # solo si es el puntero al harness
```

bash:

```bash
rm -rf AI
rm -f AGENTS.md  # solo si es el puntero al harness
```

> Si tu `AGENTS.md` tenía contenido propio antes del harness, el instalador lo respaldó en `AGENTS.md.bak`: restáuralo en vez de borrarlo.

## Adaptadores opcionales

El harness funciona con **cualquier** cliente agéntico que lea `AGENTS.md`. Estos archivos son ayudas para un cliente concreto, no requisitos:

- **`AI/.opencode/`** — agentes, comandos y skills de ejemplo con el layout de OpenCode. Si tu cliente usa otro layout, ignóralos o adaptalos: el flujo vive en `AI/AGENTS.md`, `AI/INICIO.md`, `AI/docs/` y `AI/scripts/`, que son Markdown + shell portátil.
- **`AI/opencode.fragment.jsonc`** — fragmento de ejemplo para fusionar en tu `opencode.jsonc` (p. ej. el bloque MCP `graphify-code`, deshabilitado por defecto). Solo aplica a OpenCode; otros clientes lo ignoran sin efecto.
- **`install.ps1` / `install.sh`** — elige el de tu shell; ambos aplican la misma lógica idempotente. Los scripts de `AI/scripts/` también vienen en par `.ps1` / `.sh`.
- **Multi-cliente:** desde v0.3.0 la fuente única es `AI/agents/`, `AI/commands/`, `AI/skills/` y cada cliente recibe su árbol renderizado en `AI/clients/<cliente>/` (ver [Multi-cliente](#multi-cliente)). `AI/.opencode/` se conserva intacto por compatibilidad.

Nada del núcleo exige OpenCode, Windows ni ningún modelo concreto.

## Multi-cliente

El harness se configura para el cliente agéntico de turno desde UNA sola definición canónica:

- **Canónico (`AI/`):** `AI/agents/*.md` (11 agentes), `AI/commands/*.md` (`flow`, `verify`), `AI/skills/*/SKILL.md` (4 skills). Es la única fuente que se edita a mano.
- **Render (`AI/clients/`):** generado con `node scripts/render-clients.js` (sin dependencias); `node scripts/render-clients.js --check` solo verifica. El CI lo exige en verde antes de publicar (ver `.github/workflows/publish.yml`). No edites `AI/clients/` a mano: tus cambios se pierden en el próximo render.

| Cliente | `--client` | Rutas generadas en la raíz | Adaptación |
|---|---|---|---|
| OpenCode | `opencode` | `.opencode/agents/`, `.opencode/commands/`, `.opencode/skills/` | copia exacta de `AI/.opencode/` |
| Claude Code | `claude` | `.claude/agents/`, `.claude/commands/`, `.claude/skills/` | agents con `{name,description}` (sin `mode`) |
| Cursor | `cursor` | `.cursor/commands/`, `.agents/skills/` | commands sin frontmatter (solo cuerpo) |
| Copilot | `copilot` | `.github/agents/*.agent.md`, `.github/prompts/*.prompt.md`, `.github/skills/` | renombrados a su convención |
| Aider (y genéricos) | `aider` | nada que generar | usan el `AGENTS.md` raíz |

Flag `--client` en `install.ps1` (`-Client`), `install.sh` y `bin/harness-btp.js`:

- `auto` (defecto): detecta por huellas (`CLAUDE.md`/`.claude`→claude, `.cursor`→cursor, `.github`→copilot, `opencode.json*`/`.opencode`→opencode); sin huellas usa opencode por compatibilidad histórica. Si hay huellas de varios clientes, fusiona los detectados.
- `all`: fusiona los cuatro árboles.
- Lista explícita (`-Client claude,cursor` / `--client claude,cursor`): solo esos.
- Fusión idempotente con mensajes `CREATE:`/`SKIP:` por archivo y `BACKUP` a `<dir>.bak` con fuerza (mismo patrón que `AI/`).

## Estructura del repo

```text
harness-btp/
├── AI/                        # lo que queda instalado en tu proyecto
│   ├── AGENTS.md              # reglas del harness (parametrizado, sin rutas absolutas)
│   ├── INICIO.md              # punto de entrada para el agente
│   ├── agents/                # CANÓNICO: 11 agentes (única fuente, se edita a mano)
│   ├── commands/              # CANÓNICO: flow + verify (única fuente)
│   ├── skills/                # CANÓNICO: 4 skills (única fuente)
│   ├── clients/               # RENDERIZADO por scripts/render-clients.js (no editar a mano)
│   ├── opencode.fragment.jsonc# ADAPTER opcional: ejemplo para opencode.jsonc
│   ├── .opencode/             # ADAPTER opcional: se conserva intacto (compatibilidad)
│   ├── scripts/               # pares .ps1 / .sh + provision-espacio.template.ps1
│   ├── docs/                  # flujo-etapas, cf-safe, habilitacion-trial
│   ├── specs/                 # plantilla _template.md
│   └── .gitignore.fragment    # líneas a fusionar en tu .gitignore
├── scripts/
│   └── render-clients.js      # genera AI/clients/ desde el canónico (--check en CI)
├── templates/
│   └── AGENTS.pointer.md      # plantilla del puntero AGENTS.md raíz
├── install.ps1 / install.sh   # instaladores idempotentes (SKIP / CREATE / BACKUP / OK)
├── bin/                       # ejecutable de create-harness-btp (pnpm dlx)
├── package.json               # name create-harness-btp
└── VERSION                    # 0.3.0
```

## Cómo lo descubre el agente

1. Tu cliente agéntico abre el proyecto y lee `AGENTS.md` en la raíz (el puntero que deja el instalador).
2. El puntero lo lleva a `AI/AGENTS.md`: reglas, herramientas (`cf`, `mbt`) y presupuestos.
3. Desde ahí sigue a `AI/INICIO.md` para el flujo por etapas (`/flow`), descubre los agentes de ejemplo en `.opencode/`, skills y scripts, y usa `AI/specs/_template.md` para nuevas especificaciones.
4. Antes del primer despliegue adapta los dos placeholders a tu destino (ver `AI/INICIO.md`).

Tú no configuras nada: el agente se adapta solo.

## Troubleshooting

| Problema | Causa | Comando |
|---|---|---|
| `SKIP: AI/ ya existe` y quería actualizar | reinstalación sin fuerza conserva lo existente | repite con `-Force` (`.ps1`) o `--force` (`.sh`); guarda `AI.bak` |
| No aparece `orchestrator` / no existe `/flow` | fusión a `.opencode/` raíz ausente (OpenCode solo descubre `.opencode/` en la raíz del proyecto, no `AI/.opencode/`) | reinstala sin fuerza (copia solo faltantes) o copia `AI/.opencode/` a `.opencode/` en la raíz sin pisar archivos propios |
| Mi `AGENTS.md` propio desapareció | se instaló con fuerza | recupera `AGENTS.md.bak` |
| Líneas duplicadas en `.gitignore` | edición manual tras la fusión | el instalador fusiona sin duplicar; borra el duplicado a mano |
| `ExecutionPolicy` bloquea `install.ps1` | política de PowerShell | `powershell -ExecutionPolicy Bypass -File AI-tmp/install.ps1 -Dest .` (o usa `install.sh` en Git Bash) |
| `ABORT: opción desconocida` en `install.sh` | flag inexistente | `sh install.sh --help` lista `--dest`, `--force` |
| `degit` falla sin Node | `degit` corre sobre Node 18+ | instala Node o usa `git clone --branch v0.3.0` |
| Tu cliente no lee los agentes de `.opencode/` | layout específico de OpenCode | son un adapter opcional; el flujo está en `AI/AGENTS.md` + `AI/INICIO.md` |
| Mi cliente no ve los agentes (claude/cursor/copilot) | instalaste sin el `--client` que usa tu proyecto (`auto` no encontró sus huellas) | reinstala sin fuerza con `--client <tu-cliente>` (p. ej. `--client claude`) y verifica la tabla de [Multi-cliente](#multi-cliente): `.claude/`, `.cursor/commands/` + `.agents/skills/`, o `.github/agents\|prompts\|skills` según cliente; si sigue sin verlos, revisa la fusión y no dupliques archivos a mano |
| No se deja borrar la carpeta del proyecto ("Carpeta en uso") | procesos huérfanos parados dentro (shells/MCPs de una sesión ya cerrada) | resmon → CPU → Identificadores asociados → busca la carpeta y termina solo esos PIDs; nunca fueron del instalador (solo copia archivos y termina) |

## Compatibilidad

Matriz honesta cliente × SO (`verificado` = probado con evidencia; `esperado` = sin bloqueo conocido, pendiente de evidencia):

| Cliente agéntico | Windows | Linux | macOS |
|---|---|---|---|
| OpenCode | verificado | esperado (`install.sh` par verificado en Git Bash) | esperado |
| Claude Code, otros que lean `AGENTS.md` | esperado | esperado | esperado |

- Instaladores y `check-prereqs` / `check-docs` verificados en Windows (`.ps1` nativo, `.sh` vía Git Bash, paridad CREATE/SKIP/BACKUP/OK + mismos `exit`).
- SAP BTP Cloud Foundry solo cuando el MVP lo pida: el harness no crea cuentas ni espacios por sí solo.

## Contribuir

- Abre un issue antes que un PR si el cambio afecta reglas o scripts.
- PRs pequeños, en español, con evidencia del comando corrido.
- Versionado semver: los cambios se publican como tags `vX.Y.Z` (`package.json` + `VERSION` + `AI/VERSION` + tag git coinciden; el workflow lo verifica).

## Licencia

MIT. Haz lo que quieras con el harness; sin garantía.

## Changelog

- **v0.3.0** — multi-cliente: definición canónica única en `AI/agents/`, `AI/commands/`, `AI/skills/`; render a `AI/clients/<cliente>/` con `scripts/render-clients.js` (opencode byte-idéntico a `AI/.opencode/`, que se conserva intacto); instaladores con flag `--client auto|all|<lista>` (detección por huellas, fusión idempotente con `SKIP`/`BACKUP` por dir); `prompts/setup.md` pregunta el cliente si es ambiguo y verifica adopción por cliente; CI exige `render-clients.js --check` antes de la guardia de versiones.

- **v0.3.0** — fusión a `.opencode/` raíz: el instalador sincroniza `AI/.opencode/` (agents + commands + skills) en `.opencode/` del proyecto para que OpenCode descubra `orchestrator` y `/flow` (SKIP sin fuerza, `.opencode.bak` con fuerza); `prompts/setup.md` verifica adopción y fusiona el fragmento MCP.
- **v0.2.4** — estilo Neon: una línea que lee `prompts/setup.md` (versionado, siempre al día) en vez de un bloque que caduca.
- **v0.2.3** — prompt universal todo-en-uno: clona + instala con la versión que indique el README (nunca caduca), verifica AI/VERSION instalado.
- **v0.2.2** — anti-huérfanos: bloque de agente con regla de cierre limpio (no dejar servidores corriendo, no borrar carpetas con procesos dentro) + troubleshooting de carpeta bloqueada (resmon → Identificadores asociados).
- **v0.2.1** — trazabilidad y versión visible: `AI/VERSION` viaja en el paquete, los instaladores imprimen la versión (`OK: harness vX.Y.Z…`, `BACKUP` con vieja→nueva) y el workflow exige que `package.json`, `VERSION` y `AI/VERSION` coincidan. Comandos fijados a `@0.2.1` / `#v0.2.1` / `--branch v0.2.1`.
- **v0.2.0** — versión inicial: carpeta `AI/` parametrizada, instaladores idempotentes `install.ps1` / `install.sh`, `create-harness-btp` vía `pnpm dlx`, plantilla de puntero, docs de flujo / cf-safe / habilitación trial, plantilla de spec.