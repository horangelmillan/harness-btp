---
title: ADR-003 — Graphify local como fuente estructural opt-in
date: 2026-11-03
status: vigente
---

# ADR-003 — Graphify local como fuente estructural opt-in

## Contexto

El Meta-Harness necesitaba respuestas "¿qué depende de qué?" sin leer el
repo entero. Opciones: solo Knowledge Map + `codebase-memory` (estado
previo), o añadir Graphify. Condiciones: 100% local (sin Hosted/OAuth),
sin tocar `AI/`, sin obligar a otros devs, sin regresión si falta.

## Decisión

Integrar Graphify Open Source (`graphifyy[mcp]` 0.9.97, uv tool) como
fuente estructural **opt-in y bajo demanda**:

- Grafo: `graphify extract . --code-only` + `graphify update .` bajo demanda.
- Servidor MCP STDIO `graphify-local`, configurado **solo a nivel usuario**.
- Referencia única: `docs/mcp/graphify-local.md`. Knowledge Map sigue
  canónico; orden de consulta: Knowledge Map → Graphify → codebase-memory.

## Alternativas descartadas

- Graphify Hosted / HTTP / OAuth: envía código fuera, exige secretos.
- `graphify install` / `watch` / `hook install`: muta otros clientes,
  vigilancia permanente y rebuilds innecesarios.
- Extracción semántica con LLM: exige API key; 100% EXTRACTED basta.
- Config MCP versionada activa: obligaría a todos a instalar Graphify.
- Llamadas obligatorias en agentes: fricción y tokens sin retorno en T0/T1.

## Consecuencias

- `graphify-out/` excluido de git (`.gitignore` raíz) y de npm (`files`
  allowlist ya lo excluye). `AI/` intacto.
- Cobertura honesta: `.md` = nodos de archivo sin aristas de llamada;
  vacío ≠ ausencia (documentado en `graphify-local.md`).
- Mantenimiento: `graphify update .` tras cambios relevantes; si el grafo
  falta o está obsoleto, el harness sigue verde.
