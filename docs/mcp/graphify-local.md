---
title: Graphify local (motor estructural del Meta-Harness)
date: 2026-11-03
status: vigente
---

# Graphify local

Motor estructural **local y bajo demanda** del Meta-Harness. No sustituye al
Knowledge Map (canónico en `docs/`) ni a `codebase-memory`; los complementa.

## Propósito

Responder "¿qué depende de qué?" a nivel archivo/símbolo sin leer el repo
entero: relaciones entre `.opencode/`, `AI/`, `bin/`, `scripts/`,
`installers/`, `.github/`, dependencias de comandos, impacto de un cambio.

## Instalación (una vez, aislada, sin tocar otros clientes)

```powershell
uv tool list | Select-String graphify   # reutilizar si ya está
uv tool install "graphifyy[mcp]"        # solo si falta
graphify --version; graphify-mcp --help # 0.9.97 verificado 2026-11-03
```

Prohibido `graphify install`: registra skills en otros clientes de IA.
`python -m graphify` NO funciona (paquete aislado en uv); usar los
binarios `graphify` / `graphify-mcp`.

## Grafo (offline, sin API key, sin Hosted/OAuth)

```powershell
graphify extract . --code-only  # base: AST local, 152 nodos iniciales
graphify update .               # refresco: añade nodos de archivo .md (517 nodos / 381 aristas / 159 comunidades, verificado)
graphify check-update .         # cron-safe, solo avisa si hay cambios
```

Cobertura real: 161 archivos (JS/SH/PS1/YML + nodos de archivo `.md`).
Los `.md` aportan nodos de **archivo**, no símbolos: un resultado vacío
NO prueba ausencia de dependencia (ver Limitaciones).

## Configuración OpenCode (solo nivel usuario, nada versionado)

Activa en `~/.config/opencode/opencode.jsonc` (esta máquina), fusión aditiva:

```json
{ "mcp": { "graphify-local": {
  "type": "local",
  "command": ["graphify-mcp", "C:/Users/Horan/Desktop/harness-btp/graphify-out/graph.json"],
  "enabled": true } } }
```

STDIO siempre; nunca HTTP, nunca Hosted. Reiniciar OpenCode tras añadirlo.
Sin Graphify todo sigue verde (opt-in). La plantilla de producto
(`AI/opencode.fragment.jsonc`, `graphify-code`, `enabled:false`) no cambia.

## Herramientas MCP (10, servidor `graphify` 0.9.97)

`query_graph` (BFS/DFS + `token_budget`), `get_node`, `get_neighbors`,
`get_community`, `god_nodes`, `graph_stats`, `shortest_path`,
`list_prs`, `get_pr_impact`, `triage_prs`.

## Actualización

Manual/bajo demanda tras cambios relevantes: `graphify update .`.
Sin watcher (`watch`), sin hooks (`hook install`), sin rebuild por consulta.
Empezar por `graph_stats` y presupuestos acotados (`token_budget` 600–2000).

## Cuándo usar cada fuente

1. Knowledge Map primero (decisiones/arquitectura canónicas).
2. `graphify-local` para dependencias estructurales/archivo-símbolo offline.
3. `codebase-memory` para búsqueda semántica indexada.
4. Nunca Graphify + codebase-memory para lo mismo sin justificar.

## Limitaciones

- `--code-only` + `update` sin LLM: sin aristas INFERRED semánticas (100% EXTRACTED).
- `.md` = nodos de archivo, sin símbolos ni llamadas: escenarios A–F
  parcialmente a nivel archivo (B: comandos `.md` sin aristas de llamada).
- `affected` espera nombre de símbolo, no ruta de archivo.
- Respuestas truncan por `token_budget`: estrechar con `context_filter` o `get_node`.
- Grafo obsoleto si no se corre `update` tras refactor (ver `graph_stats`: commit).

## Agentes consumidores

Orquestador (decide cuándo aporta), architect (dependencias/impacto),
researcher (complemento estructural), implementer (antes de modificar),
qa (componentes afectados), performance (menos lecturas redundantes).
Sin llamadas obligatorias en ningún agente; sin instrucciones repetidas:
esta página es la referencia única.
