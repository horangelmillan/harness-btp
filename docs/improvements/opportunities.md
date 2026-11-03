---
title: Registro de oportunidades de mejora (T3)
date: 2026-11-03
status: vigente
---

# Opportunities — Autonomous Engineering (T3)

Registro trazable de oportunidades del Meta-Harness. Cada entrada conserva
los 12 campos de `§1`. Deduplicación (§2) antes de registrar. Estados (§3).

## 1. Esquema (12 campos)

`ID` · problema · evidencia · componente · impacto · frecuencia ·
causa probable · solución propuesta · esfuerzo · riesgo de regresión ·
prioridad (`Critical|High|Medium|Low|Research`) · estado (§3).

## 2. Deduplicación

Antes de registrar: buscar en `docs/backlog/backlog.md`,
`docs/improvements/improvement-log.md`, este registro y
`docs/research/findings.md`. Coincidencia → reutilizar ID, no crear otro.
Un duplicado detectado se cierra como `REJECTED (duplicada de OPP-xxx)`.

## 3. Estados

`DETECTED` → `INVESTIGATING` → `PROPOSED` → `PRIORITIZED` → `IN_PROGRESS`
→ `VALIDATING` → `COMPLETED` | `DEFERRED` | `REJECTED` (con justificación).

## 4. Registro

### OPP-001 · `validate-meta.js` sin checks de frontmatter en docs canónicos nuevos

- Evidencia: `scripts/validate-meta.js:37-41` solo exige frontmatter en
  mapa/guía/baseline; `docs/mcp/graphify-local.md:1-5` y
  `docs/engineering/knowledge-lifecycle.md:1-5` tienen frontmatter sin
  protección CI. Componente: `scripts/validate-meta.js`.
  Impacto: regresión silenciosa posible. Frecuencia: cada edición de esos
  docs. Causa: checks añadidos en P2 solo para 3 archivos.
  Solución: extender la lista a los 5 docs con frontmatter.
  Esfuerzo: T1 (1 archivo, ~5 líneas). Riesgo: bajo (solo añade fallos ante
  frontmatter ausente). Prioridad: Medium. Estado: COMPLETED (2026-11-03,
  este ciclo; `validate-meta.js` en verde).

### OPP-002 · Flow D de 7 etapas, sin ciclo autónomo de 10

- Evidencia: `.opencode/commands/engineering-improvement.md` (12 líneas,
  `OBSERVAR→…→DOCUMENTAR`). Componente: Flow D.
  Impacto: sin synchronize/gobernanza formal; T3 §5 exige
  `OBSERVE→…→SYNCHRONIZE`. Frecuencia: cada mejora. Causa: Flow D previo a T3.
  Solución: ampliar Flow D a 10 etapas con delegación selectiva y puerta SAP.
  Esfuerzo: T1 (1 archivo). Riesgo: bajo (docs meta, validados por script).
  Prioridad: High. Estado: COMPLETED (2026-11-03, este ciclo).

### OPP-003 · Priorización T3 (este ciclo)

- Evidencia: este registro. Componente: proceso.
  Candidatos evaluados: OPP-001 (impacto medio/esfuerzo T1/riesgo bajo →
  hacer ya), OPP-002 (impacto alto/esfuerzo T1/riesgo bajo → hacer ya),
  OPP-006 (impacto medio/esfuerzo y riesgo desconocidos sin fuentes
  oficiales → RESEARCH, no implementar), nuevo agente autónomo
  (impacto nulo demostrado → REJECTED, reutilizar orquestador).
  Prioridad: High. Estado: COMPLETED (justificación registrada aquí).

### OPP-004 · Implementación autónoma acotada (Escenario D)

- Evidencia: diff de este ciclo (`validate-meta.js` + Flow D + docs).
  Es la materialización de OPP-001+OPP-002. Pruebas:
  `node scripts/validate-meta.js` en verde, `render --check` OK, triple
  versión OK. Revisión independiente: Escenario E (reviewer). Prioridad:
  High. Estado: COMPLETED (2026-11-03: reviewer APTO por muestreo +
  runtime `54 checks` + `render 61 OK` + triple 0.3.2, `AI/` intacto).

### OPP-005 · Prevención de duplicados (Escenario G)

- Evidencia: re-registro intencional de OPP-001 durante este ciclo.
  Búsqueda en backlog + improvement-log + este registro localiza OPP-001 →
  segundo registro cerrado como `REJECTED (duplicada de OPP-001)`.
  Prioridad: Medium. Estado: COMPLETED (mecanismo §2 verificado).

### OPP-006 · Skill reutilizable XSUAA/IAS (Escenario H, SAP BTP)
- Problema: auth XSUAA/IAS recurrente sin guía producto verificable.
  Evidencia: `AI/docs/xs-security-checklist.md` + `AI/specs/examples/xs-security.json`
  (T4-E/F) + `AI/skills/sap-verify/SKILL.md` y `AI/specs/_template.md` modificados.
  Componente: `AI/docs|specs|skills` (producto). Impacto: alto (auth recurrente
  en CAP). Frecuencia: cada proyecto con xs-security.
  Causa: conocimiento disperso en consumidores. Solución: 2 docs producto
  + ejemplos + puerta `sap-verify` (no skill nueva).
  Esfuerzo: T1. Riesgo regresión: bajo (solo docs/ejemplos, `AI/clients/` por render).
  Prioridad: High. Estado: VALIDATING (2026-11-03: APTO estático —
  `validate-meta` 54 OK, `render --check` 61 OK, triple 0.3.2; NO `AVAILABLE`
  sin prueba real BTP; pendiente despliegue CF/XSUAA para COMPLETED).

### OPP-007 · Freshness: `detect_changes` no mide desfase del índice (T3.1)

- Evidencia: tras `index_repository` full con probes, `search_code`
  recuperaba `t31CbmProbeZeta` (`findings.md:7`); tras restaurar y
  reindexar, 0 resultados (770/813, ready). Pero `detect_changes`
  siguió `changed_count=8` (compara árbol vs `HEAD`, estilo git).
  Componente: `docs/engineering/knowledge-lifecycle.md` §4.
  Impacto: reindexaciones repetidas innecesarias si se lee el conteo como
  desfase. Frecuencia: cada tarea con cambios sin commitear.
  Solución: 1 párrafo en §4 (semántica git + `built_at_commit`≠frescura
  árbol + `search_code` para `.md`). Esfuerzo: T0. Riesgo: nulo.
  Prioridad: Medium. Estado: COMPLETED (2026-11-03, corrección solo-docs;
  `validate-meta.js` en verde).

### OPP-008 · Guía Destination/Approuter producto (T4-E/F, SAP BTP)
- Problema: consumo de destinos vía Approuter sin patrón producto verificable.
  Evidencia: `AI/docs/destination-approuter-checklist.md` +
  `AI/specs/examples/mta-approuter-snippet.yaml` + `AI/specs/examples/xs-app.json`
  (T4-E/F). Componente: `AI/docs|specs` (producto).
  Impacto: medio-alto (conectividad recurrente). Frecuencia: cada proyecto con
  destinos. Causa: conocimiento disperso en consumidores.
  Solución: checklist + 2 ejemplos producto (no skill nueva).
  Esfuerzo: T1. Riesgo regresión: bajo (solo docs/ejemplos).
  Prioridad: High. Estado: VALIDATING (2026-11-03: APTO estático —
  `validate-meta` 54 OK, `render --check` 61 OK, triple 0.3.2; NO `AVAILABLE`
  sin prueba real BTP con destino/Approuter para COMPLETED).
  Trazabilidad: problema (sin patrón) → implementación (T4-E/F) → validación
  (T4-F estática; T4-G registra).

### OPP-009 · HANA (HDI) diferido (T4-G)
- Problema: guía HANA/HDI pendiente sin fuente verificada en este ciclo.
  Evidencia: este registro + §2 (sin duplicado en backlog/log/findings).
  Componente: `AI/docs|specs` (producto, futuro). Impacto: medio.
  Frecuencia: cada proyecto con HANA. Causa: presupuesto T4 agotado en
  OPP-006/008. Solución: checklist+ejemplo HDI en ciclo futuro con fuente
  oficial. Esfuerzo: T1 estimado. Riesgo: bajo.
  Prioridad: Medium. Estado: DEFERRED (2026-11-03: pospuesto con justificación,
  no descartado).

### OPP-010 · Skill OData dedicada rechazada (T4-G)
- Problema: propuesta de skill OData dedicada.
  Evidencia: §2 — capacidad cubierta por `AI/skills/cap-cli` + `sap-verify`
  (verificación de servicios) y patrones CAP existentes; skill nueva duplicaría.
  Componente: `AI/skills` (producto). Impacto: nulo demostrado.
  Frecuencia: n/a. Causa: solape funcional. Solución: derivar a mejora de
  `cap-cli` si surge caso real (no skill nueva). Esfuerzo: T0.
  Riesgo regresión: medio si se duplica (confusión de triggers).
  Prioridad: Low. Estado: REJECTED (2026-11-03: duplicada/solapada —
  derivado a mejora futura de `cap-cli`, con justificación).
