---
description: Ingeniería autónoma del harness (observar → sincronizar)
agent: engineering-orchestrator
---

Flow D — Autonomous Improvement: $ARGUMENTS.

Ciclo reutilizable OBSERVE → DETECT → INVESTIGATE → PRIORITIZE → DESIGN →
IMPLEMENT → TEST → REVIEW → DOCUMENT → SYNCHRONIZE. Sin aprobaciones
manuales nuevas; sin procesos permanentes en segundo plano.

1. OBSERVE: recuperar observaciones existentes (trabajo real, no escaneos
   permanentes). 2. DETECT: ¿oportunidad real? Registrarla en
   `docs/improvements/opportunities.md` (12 campos, §1) tras deduplicar
   (§2: backlog + improvement-log + registro + findings).
3. INVESTIGATE (`harness-researcher` solo si hay docs/MCP implicados;
   `context7` ante afirmación SAP). 4. PRIORITIZE: impacto/esfuerzo/riesgo
   (T0/T1/T2 en `docs/engineering/impact-guide.md`; T0 directo sin delegar).
   Retrieval selectivo según `docs/engineering/knowledge-lifecycle.md` §1.
5. DESIGN (`harness-architect` solo en T2; solución proporcionada, sin
   agentes/MCP/skills nuevos salvo necesidad demostrada). 6. IMPLEMENT
   (`harness-implementer`; `sap-btp-specialist` solo si BTP). 7. TEST
   (`harness-qa`: `validate-meta.js` + `render --check` + triple versión;
   métricas solo observadas, nunca inventadas). 8. REVIEW (`reviewer` por
   muestreo, agente distinto al implementador). 9. DOCUMENT: solo docs
   afectados (log + registro + backlog + mapa si aplica) + puerta SAP BTP:
   ¿capacidad reutilizable (skill/template/comando/flujo/validación)?
   Solo con fuentes oficiales verificadas; separar meta/producto/consumidor.
10. SYNCHRONIZE: checklist `docs/engineering/knowledge-lifecycle.md` §5
    (una sola sync, fallo → `PEND-KNOWLEDGE`, nunca bloqueo).
    Rechazadas conservan justificación. Si empeora, revertir.
