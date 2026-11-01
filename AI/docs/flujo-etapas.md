# Flujo por etapas — entregables y criterios de avance

> Referencia única del ciclo. `AGENTS.md` manda; este documento lo detalla.
> El progreso de cada MVP se registra en su spec (§6) y en su informe de cierre.

| Etapa | Nombre | Ejecuta | Entregable verificable | Criterio de avance |
|---|---|---|---|---|
| 0 | Evaluación | `analyst` | Veredicto + supuestos + CA verificables | Spec completable; bloqueos con dato mínimo pedido |
| 1 | Investigación | `researcher` | Tabla fuente\|fecha\|evidencia (documentado/pendiente/coste) | Ninguna API/servicio supuesto sin fuente |
| 2 | Plan/Arquitectura | `architect` | Topología + esqueleto `mta.yaml` + planes verificados | Decisiones y descartes registrados; persistencia fijada |
| 3 | Preparación | orquestador | Scaffold + facets + deps instaladas + target CF confirmado | `cds version` OK; `cf target` coincide con spec |
| 4 | Desarrollo | `backend-cap` + `frontend-ui5` | Modelo/servicios CAP + UI + mocks DIE/iFlow corriendo en local | CA1–CA3 observables con `cds watch` |
| 5 | Pruebas | `qa-review` | Resultado por CA (comando + salida real) | Sin rojo; vulnerabilidades del scaffold dictaminadas |
| 6 | Correcciones | especialistas | Fixes verificados | Plan de pruebas en verde |
| 7 | Revisión despliegue | `/verify` | Veredicto apto/no apto (target + artefacto + CA + Git limpio) | Solo "apto" permite etapa 8 |
| 8 | Despliegue | `deploy-cf` | Apps `started` + logs + evidencia (cockpit/URL) | CA4–CA5 con evidencia observable |
| 9 | Git | orquestador | Commits locales; remoto solo con autorización expresa | Sin secretos en diff; push/PR solo si la spec lo pide |
| 10 | Documentación | `documentarian` | Spec, inventario e informe de cierre al día | Hechos con fuente; pendientes marcados |

Rigor proporcional: en MVPs pequeños se pueden aligerar 5 (pruebas manuales
guiadas por CA) y diferir 9; nunca se saltan 0, 2, 7 ni 8. Paralelo solo en
tareas independientes; el orquestador integra y revisa todo cambio.
