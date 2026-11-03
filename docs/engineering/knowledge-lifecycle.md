---
title: Ciclo de vida del conocimiento (retrieve → verify)
date: 2026-11-03
status: vigente
---

# Knowledge Lifecycle

Ciclo transversal `RETRIEVE → ENGINEER → DETECT → SYNCHRONIZE → VERIFY`
integrado en los 5 flujos (`engineering-feature|research|refactor|
improvement|release`). Punto único de verdad: esta página. Los flujos solo
la referencian (1 línea); la matriz y el checklist viven aquí una sola vez.

## 1. Retrieval selectivo (antes de la tarea)

El orquestador decide según T0/T1/T2 (`impact-guide.md` §4):

| Nivel | Retrieval | Regla |
|---|---|---|
| T0 (1 archivo, trivial) | Ninguno | Lectura directa + `knowledge-map.md` (coste 0). |
| T1 (1 especialista) | Máximo 1 fuente, 1–2 llamadas acotadas | Solo si hay dependencias/contratos implicados. |
| T2 (diseño previo) | Hasta 2 fuentes, secuenciales y justificadas | Nunca ambas para la misma pregunta. |

Matriz de selección (Knowledge Map siempre primero, coste 0):

- **Graphify** (`docs/mcp/graphify-local.md`): ¿qué depende de qué a nivel
  archivo/símbolo — `graph_stats` → `query_graph`/`get_node`/`get_neighbors`
  /`shortest_path`, `token_budget` 600–2000. `.md` = nodos de archivo sin
  aristas de llamada (vacío ≠ ausencia); `affected` exige símbolo, no ruta.
- **Codebase Memory** (proyecto `C-Users-Horan-Desktop-harness-btp`):
  búsqueda semántica, quién usa un concepto, patrones similares —
  `search_graph`/`trace_path`. `index_status` = ready 726/790 (2026-11-03).
- **Ninguno**: cambio narrativo de 1 archivo, contexto ya disponible,
  búsqueda directa suficiente.
- **Anti-doble-consulta**: el segundo grafo solo si el primero devolvió
  vacío/ambiguo, registrado en 1 línea. Prohibido consultar ambos "por si acaso".

## 2. Detección de cambios (al cierre)

```powershell
git status --short; git diff --name-only HEAD; git diff --stat HEAD
```

Clasificar (orquestador o qa):

- **A (narrativa)**: solo `.md` de `docs/` narrativa, README, CHANGELOG →
  sin sync de índices.
- **B (estructural)**: `*.js|ps1|sh|yml|json|jsonc` en `scripts/`, `bin/`,
  `.github/`, `.opencode/`, `AI/` canónico, instaladores, templates →
  candidato a sync.
- **C (mixto)**: A+B → tratar como B.

**Exclusión** (nunca dispara sync): `temp/`, `evidencia/` sin referencia,
`*.log`, `graphify-out/` (generado), `AI/clients/` (generado por render),
`node_modules/`, perfiles CDP temporales. `.md` persistente SÍ:
`docs/engineering|mcp|agents|skills|architecture/decisions`,
`AI/agents|commands|skills` canónicos; NO: borradores, notas de sesión.

## 3. Sincronización (una sola vez por tarea, no bloqueante)

- **Graphify**: `graph_stats` (leer `built_at_commit`) → `graphify check-update .`
  (silencio = fresco, basta registrarlo) → si clase B/C y stale, **un**
  `graphify update .` → releer `graph_stats.commit == HEAD`. Clase A/T0/
  release sin cambios estructurales: prohibido actualizar.
- **Codebase Memory**: puerta `detect_changes` (`changed_count==0` → saltar);
  reindex completo (`index_repository`) solo en B/T2 con presupuesto explícito
  y evidencia de duración; nunca en T0/T1, nunca 2 veces por tarea.
- **Conjunta**: cada índice una vez; paralelo solo si preguntas disjuntas.
- **Fallo**: no bloquea el cierre. Registrar
  `PEND-KNOWLEDGE: <qué> | <causa> | <reintento: próxima tarea B/C>`
  en `docs/backlog/backlog.md` (1 línea); la tarea cierra APTO-CON-PENDIENTE
  con evidencia del error. Sin evidencia no hay "sincronizado".

## 4. Freshness (3 campos, 1 línea por cierre)

`head=<HEAD corto>` · `graphify.commit=<built_at_commit corto> stale=sí/no`
· `cbm=<index_status.status>/<detect_changes.changed_count>`.
Sin metadatos redundantes (`last_sync`, timestamps manuales): el commit ya
vive en `graph_stats`. "MCP responde" ≠ actualizado; solo `commit == HEAD`
prueba frescura.
Límites verificados en vivo (T3.1): `detect_changes` compara el árbol de
trabajo contra `HEAD` (estilo `git status`): tras reindexar con cambios sin
commitear sigue `>0` → no reindexar dos veces por tarea por ese conteo;
una sola sync por tarea basta. `built_at_commit` registra el commit, no el
contenido: con cambios sin commitear indexados, `commit == HEAD` no prueba
frescura del árbol. `search_graph` (BM25) no recupera contenido `.md`
documental; para `.md` usar `search_code` (verificado).

## 5. Checklist de cierre (referenciado por los 5 flujos)

1. `git status --short` + `git diff --stat HEAD` (evidencia recortada).
2. Clasificar A/B/C + exclusión (§2). Si A o excluido → ir a 6.
3. Freshness (§4, solo lectura).
4. Si B/C y stale → una sola actualización (§3) → re-verificar commit.
5. Gates que apliquen: `validate-meta.js`; si tocó canónico,
   `render --check` + triple versión.
6. Docs/backlog/ADR que corresponda.
7. Fallo → `PEND-KNOWLEDGE` + APTO-CON-PENDIENTE (nunca bloqueo).

## 6. Escenarios validados (2026-11-03, resumen; detalle en testing-strategy)

A README/T0 sin MCP · B feature/T1 1 fuente + 1 update · C arquitectónico/T2
estructural+semántica justificadas · D instaladores + `--help` en `AI-tmp` ·
E research SAP `context7` + un grafo · F narrativa sin updates · G caída →
pendiente sin bloqueo · H fresco → cero indexaciones (verificado:
`detect_changes.changed_count=0`, `check-update` en silencio con HEAD por
delante del grafo en 2 commits solo-docs).
