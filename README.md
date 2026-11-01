# harness-btp

[![version](https://img.shields.io/badge/version-v0.1.0-blue)](https://github.com/horangelmillan/harness-btp/releases/tag/v0.1.0)
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
- [Actualizar y desinstalar](#actualizar-y-desinstalar)
- [Adaptadores opcionales](#adaptadores-opcionales)
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
npx -p degit degit horangelmillan/harness-btp#v0.1.0 AI-tmp -- AI-tmp
powershell -ExecutionPolicy Bypass -File AI-tmp/install.ps1 -Dest .
Remove-Item -Recurse -Force AI-tmp
```

bash (Linux, macOS o Git Bash):

```bash
npx -p degit degit horangelmillan/harness-btp#v0.1.0 AI-tmp -- AI-tmp
sh AI-tmp/install.sh --dest .
rm -rf AI-tmp
```

Eso es todo. Abre el proyecto en tu cliente agéntico y el agente ya sabe qué hacer: lee `AGENTS.md` → `AI/AGENTS.md` → `AI/INICIO.md`.

## Instalación

### Opción 1 — degit (recomendado)

Descarga solo lo necesario, sin historial git:

PowerShell:

```powershell
npx -p degit degit horangelmillan/harness-btp#v0.1.0 AI-tmp -- AI-tmp
powershell -ExecutionPolicy Bypass -File AI-tmp/install.ps1 -Dest .
Remove-Item -Recurse -Force AI-tmp
```

bash:

```bash
npx -p degit degit horangelmillan/harness-btp#v0.1.0 AI-tmp -- AI-tmp
sh AI-tmp/install.sh --dest .
rm -rf AI-tmp
```

### Opción 2 — git clone

Clon superficial anclado al tag:

PowerShell:

```powershell
git clone --branch v0.1.0 --depth 1 https://github.com/horangelmillan/harness-btp AI-tmp
powershell -ExecutionPolicy Bypass -File AI-tmp/install.ps1 -Dest .
Remove-Item -Recurse -Force AI-tmp
```

bash:

```bash
git clone --branch v0.1.0 --depth 1 https://github.com/horangelmillan/harness-btp AI-tmp
sh AI-tmp/install.sh --dest .
rm -rf AI-tmp
```

### Opción 3 — pnpm dlx

Sin descargas manuales (requiere publicar `create-harness-btp` en el registry). Igual en todos los SO:

```bash
pnpm dlx create-harness-btp --dest .
```

### Qué hace el instalador

- `CREATE: AI/` o `SKIP: AI/ ya existe` (solo lo reemplaza con `-Force` / `--force`, con backup a `AI.bak`).
- `CREATE: AGENTS.md` o `SKIP: AGENTS.md ya existe` (tu `AGENTS.md` propio se conserva; con `-Force` / `--force` se respalda a `AGENTS.md.bak`).
- Fusiona `.gitignore`: añade las líneas que falten, sin duplicar ni borrar las tuyas.
- **No toca** `package.json` ni `mta.yaml` de tu proyecto, nunca.

Salida típica en proyecto nuevo:

```text
CREATE: AI/
CREATE: AGENTS.md
OK: harness v0.1.0 instalado
```

## Actualizar y desinstalar

**Actualizar:** repite el mismo comando de instalación contra el tag nuevo. Sin `-Force` / `--force` lo existente se conserva (`SKIP:`); con fuerza se reemplaza con backup:

PowerShell:

```powershell
npx -p degit degit horangelmillan/harness-btp#v0.2.0 AI-tmp -- AI-tmp
powershell -ExecutionPolicy Bypass -File AI-tmp/install.ps1 -Dest . -Force
Remove-Item -Recurse -Force AI-tmp
# tu versión anterior queda en AI.bak por si quieres comparar
```

bash:

```bash
npx -p degit degit horangelmillan/harness-btp#v0.2.0 AI-tmp -- AI-tmp
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

Nada del núcleo exige OpenCode, Windows ni ningún modelo concreto.

## Estructura del repo

```text
harness-btp/
├── AI/                        # lo que queda instalado en tu proyecto
│   ├── AGENTS.md              # reglas del harness (parametrizado, sin rutas absolutas)
│   ├── INICIO.md              # punto de entrada para el agente
│   ├── opencode.fragment.jsonc# ADAPTER opcional: ejemplo para opencode.jsonc
│   ├── .opencode/             # ADAPTER opcional: agents + commands + skills de ejemplo
│   ├── scripts/               # pares .ps1 / .sh + provision-espacio.template.ps1
│   ├── docs/                  # flujo-etapas, cf-safe, habilitacion-trial
│   ├── specs/                 # plantilla _template.md
│   └── .gitignore.fragment    # líneas a fusionar en tu .gitignore
├── templates/
│   └── AGENTS.pointer.md      # plantilla del puntero AGENTS.md raíz
├── install.ps1 / install.sh   # instaladores idempotentes (SKIP / CREATE / BACKUP / OK)
├── bin/                       # ejecutable de create-harness-btp (pnpm dlx)
├── package.json               # name create-harness-btp
└── VERSION                    # 0.1.0
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
| Mi `AGENTS.md` propio desapareció | se instaló con fuerza | recupera `AGENTS.md.bak` |
| Líneas duplicadas en `.gitignore` | edición manual tras la fusión | el instalador fusiona sin duplicar; borra el duplicado a mano |
| `ExecutionPolicy` bloquea `install.ps1` | política de PowerShell | `powershell -ExecutionPolicy Bypass -File AI-tmp/install.ps1 -Dest .` (o usa `install.sh` en Git Bash) |
| `ABORT: opción desconocida` en `install.sh` | flag inexistente | `sh install.sh --help` lista `--dest`, `--force` |
| `degit` falla sin Node | `degit` corre sobre Node 18+ | instala Node o usa `git clone --branch v0.1.0` |
| Tu cliente no lee los agentes de `.opencode/` | layout específico de OpenCode | son un adapter opcional; el flujo está en `AI/AGENTS.md` + `AI/INICIO.md` |

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
- Versionado semver: los cambios se publican como tags `vX.Y.Z` (`VERSION` + `package.json` + tag git coinciden).

## Licencia

MIT. Haz lo que quieras con el harness; sin garantía.

## Changelog

- **v0.1.0** — versión inicial: carpeta `AI/` parametrizada, instaladores idempotentes `install.ps1` / `install.sh`, `create-harness-btp` vía `pnpm dlx`, plantilla de puntero, docs de flujo / cf-safe / habilitación trial, plantilla de spec.
