# Guía de inicio — Harness MVP SAP BTP

> Nota portabilidad: verificado en Windows, adapta rutas a [TU_PC].

Entorno local Windows para llevar MVPs SAP de especificación a despliegue en
Cloud Foundry, con OpenCode como orquestador.

## Antes de empezar

Verifica qué tienes instalado **antes** de usar el harness (el flujo asume
que tu máquina cumple los prerrequisitos):

```powershell
powershell -ExecutionPolicy Bypass -File AI/scripts/check-prereqs.ps1
```

Tabla Herramienta | Necesaria para | Estado (OK/FALTA) | Cómo instalarla.
`exit 1` = falta algo REQUERIDO; `exit 0` con avisos = solo faltan opcionales.
Detalle por caso y re-verificación: `docs/prerequisitos.md`.

## Estado verificado (Windows, [TU_PC])

| Herramienta | Resultado |
|---|---|
| `cf --version` | CLI de Cloud Foundry, sesión activa contra `[TU_ENDPOINT_CF]` |
| `mbt --version` | Cloud MTA Build Tool (binario recuperado; el `install.js` del paquete npm pedía `cloud-mta-build-tool`, no `mbt`) |
| `node` / `npm` | versión instalada en [TU_PC] |
| `java` | versión instalada en [TU_PC] — sirve para builds MTA Java si la spec los pide |
| OpenCode | agente `orchestrator` por defecto (este proyecto) |
| MCP heredados (global) | `context7`, `codebase-memory`, `github`, `playwright`, `eslint`, `chrome-devtools` |
| Skill instalada útil | `sapui5` (global) |
| Pendiente (a propósito) | CLIs `cds`/`ui5`, skills SAP externas — se instalan solo si una spec los exige. Plugin CF `multiapps`: verificar con `cf plugins` antes de asumir |

## Cómo proporcionar una especificación

1. Copia `specs/_template.md` a `specs/<nombre-mvp>.md` y rellénala
   (objetivo, tipo UI5/CAP/MTA, destino BTP, servicios, criterios de
   aceptación, fuera de alcance).
2. El destino BTP (endpoint/org/espacio) debe figurar en la spec o
   confirmarse cuando el orquestador lo pida. Sin destino confirmado no hay
   despliegue.

## Cómo iniciar el flujo

```
/flow specs/<nombre-mvp>.md
```

El orquestador ejecuta las etapas 0–10 de `AGENTS.md` (evaluación,
investigación, plan, preparación, desarrollo, pruebas, correcciones,
revisión de despliegue, despliegue, Git, documentación) con rigor
proporcional al tamaño del MVP. Comando de apoyo:

```
/verify   — puerta de despliegue: re-verifica target, artefacto y criterios
            sin desplegar
```

## Comandos locales de referencia

```
cf target            # endpoint/org/espacio actuales (sin secretos)
cf apps              # estado observable tras desplegar
cf logs <app> --recent
mbt build                # genera .mtar en mta_archives/ (requiere mta.yaml)
```

Nunca pegar tokens en terminal ni en specs.

## Lecturas CF seguras (broker cf-safe)

Toda lectura CF con secreto potencial vía `scripts/cf-safe.ps1`
(nunca `cf` directo en agentes/scripts si la salida puede traer
credenciales). Detalle: `docs/cf-safe.md`.

## Skills candidatas (no instaladas)

Inspeccionadas solo por procedencia; adoptar **únicamente** si
una spec las necesita, revisando antes su alcance y scripts de instalación:

- `sap-cap-capire` (sap-ai-skills.com) — CAP/CDS.
- `sap-btp-developer-guide` (secondsky) — fundamentos BTP/CAP.
- AI Skills Library (`skills.cloud.sap`, SAP SE) — CF CLI v8 y despliegue.
- Repositorio `secondsky/sap-skills` — BTP, CAP, Fiori, ABAP.

La skill global `sapui5` ya cubre frontend UI5/Fiori y tiene preferencia.
