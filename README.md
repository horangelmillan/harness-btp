# harness-btp

[![version](https://img.shields.io/badge/version-v0.1.0-blue)](https://github.com/horangelmillan/harness-btp/releases/tag/v0.1.0)
[![license](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![platform](https://img.shields.io/badge/platform-windows%20%7C%20linux-lightgrey)](https://github.com/horangelmillan/harness-btp)
[![opencode](https://img.shields.io/badge/agent-OpenCode-purple)](https://opencode.ai)

Reglas, agentes y scripts reutilizables para llevar un MVP SAP de la especificación al despliegue en Cloud Foundry con OpenCode.

Para quien construye MVPs SAP BTP en equipo Windows con OpenCode y quiere empezar cada proyecto con el mismo flujo probado, sin copiar y pegar.

## Contenidos

- [Features](#features)
- [Requisitos](#requisitos)
- [Quickstart](#quickstart)
- [Instalación](#instalación)
- [Actualizar y desinstalar](#actualizar-y-desinstalar)
- [Estructura del repo](#estructura-del-repo)
- [Cómo lo descubre el agente](#cómo-lo-descubre-el-agente)
- [Troubleshooting](#troubleshooting)
- [Compatibilidad](#compatibilidad)
- [Contribuir](#contribuir)
- [Licencia](#licencia)
- [Changelog](#changelog)

## Features

- **Carpeta `AI/` sin envolver:** se instala dentro de tu proyecto (nuevo o existente) sin mover ni renombrar nada de lo que ya tienes.
- **Idempotente con `SKIP` / `-Force` + backup:** repetir la instalación no pisa nada; solo reemplaza con `-Force` y guarda copia en `AI.bak`.
- **Sin secretos:** el repo no contiene credenciales, tokens ni rutas de máquina; solo nombres y placeholders por paisaje.
- **Tres formas de instalar:** `degit`, `git clone` o `pnpm dlx`, todas ancladas a un tag versionado.
- **Versionado por tags:** cada versión es un tag `vX.Y.Z`; actualizar es repetir el comando contra el tag nuevo.
- **El agente se adapta solo:** deja un puntero `AGENTS.md` en la raíz y OpenCode encuentra `AI/AGENTS.md`, `INICIO.md`, agentes, skills y plantilla de spec.

## Requisitos

| Necesitas | Versión | Para qué |
|---|---|---|
| Windows PowerShell 5.1 / bash | incluido en el SO | ejecutar `install.ps1` / `install.sh` |
| Node.js 18+ | solo si usas `degit` o `pnpm dlx` | descargar e instalar el harness |
| `gh` (opcional) | cualquiera reciente | clonar repo privado o crear PRs |
| OpenCode | cualquiera reciente | leer `AGENTS.md` y orquestar el flujo |

> Sin Node también puedes instalar vía `git clone`, que no lo necesita.

## Quickstart

El camino de 30 segundos en un proyecto nuevo (Windows, recomendado):

```powershell
npx -p degit degit horangelmillan/harness-btp#v0.1.0 AI-tmp -- AI-tmp
powershell -ExecutionPolicy Bypass -File AI-tmp/install.ps1 -Dest .
Remove-Item -Recurse -Force AI-tmp
```

Eso es todo. Abre el proyecto en OpenCode y el agente ya sabe qué hacer: lee `AGENTS.md` → `AI/AGENTS.md` → `AI/INICIO.md`.

## Instalación

> En Linux/macOS sustituye `install.ps1 -Dest .` por `install.sh --dest .` en todos los ejemplos.

### Opción 1 — degit (recomendado)

Descarga solo lo necesario, sin historial git:

```powershell
npx -p degit degit horangelmillan/harness-btp#v0.1.0 AI-tmp -- AI-tmp
powershell -ExecutionPolicy Bypass -File AI-tmp/install.ps1 -Dest .
Remove-Item -Recurse -Force AI-tmp
```

### Opción 2 — git clone

Clon superficial anclado al tag:

```powershell
git clone --branch v0.1.0 --depth 1 https://github.com/horangelmillan/harness-btp AI-tmp
powershell -ExecutionPolicy Bypass -File AI-tmp/install.ps1 -Dest .
Remove-Item -Recurse -Force AI-tmp
```

### Opción 3 — pnpm dlx

Sin descargas manuales (requiere publicar `create-harness-btp` en el registry):

```powershell
pnpm dlx create-harness-btp --dest .
```

### Qué hace el instalador

- `CREATE: AI/` o `SKIP: AI/ ya existe` (solo lo reemplaza con `-Force`, con backup a `AI.bak`).
- `CREATE: AGENTS.md` o `SKIP: AGENTS.md ya existe` (tu `AGENTS.md` propio se conserva; con `-Force` se respalda a `AGENTS.md.bak`).
- Fusiona `.gitignore`: añade las líneas que falten, sin duplicar ni borrar las tuyas.
- **No toca** `package.json` ni `mta.yaml` de tu proyecto, nunca.

Salida típica en proyecto nuevo:

```text
CREATE: AI/
CREATE: AGENTS.md
OK: harness v0.1.0 instalado
```

## Actualizar y desinstalar

**Actualizar:** repite el mismo comando de instalación contra el tag nuevo. Sin `-Force` lo existente se conserva (`SKIP:`); con `-Force` se reemplaza con backup:

```powershell
npx -p degit degit horangelmillan/harness-btp#v0.2.0 AI-tmp -- AI-tmp
powershell -ExecutionPolicy Bypass -File AI-tmp/install.ps1 -Dest . -Force
Remove-Item -Recurse -Force AI-tmp
# tu versión anterior queda en AI.bak por si quieres comparar
```

**Desinstalar:** borra la carpeta y el puntero. No deja servicios ni hooks:

```powershell
Remove-Item -Recurse -Force AI
Remove-Item -Force AGENTS.md  # solo si es el puntero al harness
```

> Si tu `AGENTS.md` tenía contenido propio antes del harness, el instalador lo respaldó en `AGENTS.md.bak`: restáuralo en vez de borrarlo.

## Estructura del repo

```text
harness-btp/
├── AI/                        # lo que queda instalado en tu proyecto
│   ├── AGENTS.md              # reglas del harness (parametrizado, sin rutas absolutas)
│   ├── INICIO.md              # punto de entrada para el agente
│   ├── opencode.fragment.jsonc# fragmento relativo para tu opencode.jsonc
│   ├── .opencode/             # 11 agents + 2 commands + 4 skills
│   ├── scripts/               # 5 scripts .ps1 + provision-espacio.template.ps1
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

1. OpenCode abre tu proyecto y lee `AGENTS.md` en la raíz (el puntero que deja el instalador).
2. El puntero lo lleva a `AI/AGENTS.md`: reglas, herramientas (`cf`, `mbt`) y presupuestos.
3. Desde ahí sigue a `AI/INICIO.md` para el flujo por etapas (`/flow`), descubre agentes en `.opencode/`, skills y scripts, y usa `AI/specs/_template.md` para nuevas especificaciones.
4. Antes del primer despliegue adapta los dos placeholders a tu máquina y destino (ver `AI/INICIO.md`).

Tú no configuras nada: el agente se adapta solo.

## Troubleshooting

| Problema | Causa | Comando |
|---|---|---|
| `SKIP: AI/ ya existe` y quería actualizar | reinstalación sin `-Force` conserva lo existente | repite con `-Force` (guarda `AI.bak`) |
| Mi `AGENTS.md` propio desapareció | se instaló con `-Force` | recupera `AGENTS.md.bak` |
| Líneas duplicadas en `.gitignore` | edición manual tras la fusión | el instalador fusiona sin duplicar; borra el duplicado a mano |
| `ExecutionPolicy` bloquea `install.ps1` | política de PowerShell | `powershell -ExecutionPolicy Bypass -File AI-tmp/install.ps1 -Dest .` |
| `degit` falla sin Node | `degit` corre sobre Node 18+ | instala Node o usa `git clone --branch v0.1.0` |

## Compatibilidad

- Windows 10/11 + PowerShell 5.1 verificado.
- Linux/macOS vía `install.sh` (mismo comportamiento `SKIP` / `--force` + backup).
- OpenCode como orquestador del flujo.
- SAP BTP Cloud Foundry solo cuando el MVP lo pida: el harness no crea cuentas ni espacios por sí solo.

## Contribuir

- Abre un issue antes que un PR si el cambio afecta reglas o scripts.
- PRs pequeños, en español, con evidencia del comando corrido.
- Versionado semver: los cambios se publican como tags `vX.Y.Z` (`VERSION` + `package.json` + tag git coinciden).

## Licencia

MIT. Haz lo que quieras con el harness; sin garantía.

## Changelog

- **v0.1.0** — versión inicial: carpeta `AI/` parametrizada, instaladores idempotentes `install.ps1` / `install.sh`, `create-harness-btp` vía `pnpm dlx`, plantilla de puntero, docs de flujo / cf-safe / habilitación trial, plantilla de spec.
