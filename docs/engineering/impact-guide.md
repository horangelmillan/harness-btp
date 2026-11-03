---
title: Guía de impacto proporcional
date: 2026-11-03
status: vigente
---

# Impact Guide — esfuerzo proporcional

## 1. Objetivo

Dimensionar cada tarea antes de delegar: lo trivial se hace directo,
lo medio con un especialista, lo grande con diseño previo.

## 2. Niveles

| Nivel | Condición | Modo |
|---|---|---|
| **T0** | ≤5 min, 1 archivo, sin diseño ni MCP nuevo | Directo, **sin delegar** |
| **T1** | 1 especialista, 1–2 archivos, sin cambiar contratos | Delegación simple con presupuesto |
| **T2** | ≥3 archivos, o toca contratos/catálogos/flujos, o producto canónico con render | Diseño (`harness-architect`) + implementación + qa + revisión |

## 3. Procedimiento (intelligence-pack opcional)

1. Consultar `docs/engineering/knowledge-map.md` (qué nodo toca).
2. Responder las preguntas del §4.
3. Clasificar T0/T1/T2 y actuar según nivel.
4. T0 cierra directo con evidencia; T1/T2 delegan con presupuesto explícito.

## 4. Preguntas de impacto

1. ¿Cuántos archivos toca (1 / 2 / ≥3)?
2. ¿Toca producto canónico (`AI/agents|commands|skills`) con render?
3. ¿Cambia contratos, catálogos o flujos meta?
4. ¿Añade MCP, skill o dependencia nueva?
5. ¿Exige navegador/CDP o despliegue CF?
6. ¿Cabe en ≤5 min con evidencia observable?

Regla: todo "sí" en 2–5 sube a T2. "Sí" en 6 con resto "no" = T0.

> Graphify (`docs/mcp/graphify-local.md`) no cambia el dimensionamiento:
> es fuente contextual bajo demanda, nunca paso obligatorio. T2 que toque
> dependencias la consulta el especialista que la ejecuta, con presupuesto
> acotado; T0/T1 no la necesitan (búsqueda directa basta).

## 5. Escenarios A–E resueltos

- **A (T0):** actualizar fecha en `AI/docs/fuentes-oficiales.md` → 1 archivo,
  sin render ni diseño. Directo, evidencia `git diff`.
- **B (T1):** añadir `--backup-dir` a `install.sh` (contrato ejemplo en
  `docs/engineering/contracts.md`) → 1 especialista
  (`harness-implementer`, 15 min), paridad `.ps1` verificada por `harness-qa`.
- **C (T2):** completar `.gitignore.fragment` multi-cliente → toca
  instaladores + fragmento + docs; diseño mínimo (`harness-architect`),
  implementación, `render --check` + instaladores `--help`.
- **D (T2):** tocar `AI/agents/*.md` canónico → exige
  `node scripts/render-clients.js` + `render --check` + triple versión;
  nunca editar `AI/clients/` a mano.
- **E (T0, no promocionar):** cambio de 6 líneas en `.gitignore.fragment`
  (ver backlog "Ahora"): aunque el tema sea P2, el diff acotado no justifica
  ciclo P1 completo → directo con `validate-meta.js` en verde.
