# Improvement Log

| Fecha | Observación | Cambio | Antes → Después | Estado |
|---|---|---|---|---|
| — | (sin mejoras registradas aún) | — | — | — |
| 2026-11-03 (P1) | Gate CI <1min sin matriz; 4 subagentes P1 en paralelo sin conflictos; metodología eficiencia: contar delegaciones + ficheros leídos + tiempo pared por fase, sin telemetría de tokens disponible | Gate `validate-meta.yml` + `publish.yml` unificado documentado en testing-strategy/backlog/assessment | Sin gate CI → 38 checks exit 0 en local | Registrado |
| 2026-11-03 (P2) | Project Intelligence sin duplicar catálogos; esfuerzo proporcional T0/T1/T2; métricas solo observado (tokens n/d, sin telemetría) | `knowledge-map.md` + `impact-guide.md` (referencias, no copias) + `metrics/baseline-P1.md` + checks mapa/governance en `validate-meta.js` + intelligence-pack opcional en 3 flujos; QA APTO 0 FP (2×T0 1×T1 2×T2) | Sin mapa/guía → 46 checks exit 0, render 61 OK, triple 0.3.2 | Registrado |
