
Deja lo mínimo listo antes de `/flow`. Guía interactiva para el
desarrollador: conversación + shell portátil (`AI/scripts/check-prereqs`,
`AI/scripts/check-docs`, `cf target`). No usa APIs de ningún cliente.

Protocolo, en orden:

1. Corre `AI/scripts/check-prereqs` (y un `check-docs` rápido si la spec
   trae enlaces) y muestra la tabla en lenguaje normal: qué hay, qué falta
   y para qué sirve cada cosa.
2. Por cada FALTA requerido: explica qué es en 1 línea, da el enlace
   oficial de instalación y PREGUNTA al desarrollador (input) cómo
   resolver: instalarlo / definir un alias (si `cf` lo ocupa otra
   herramienta: pregunta qué comando invoca al CF real y verifícalo
   corriendo `<alias> target`) / marcarlo no-necesario si la spec no lo
   exige.
3. Verifica acceso legible a Cloud Foundry: `target` responde
   (endpoint/org/espacio visibles, sin secretos por pantalla).
4. Si no hay spec (solo `AI/specs/_template.md`): ofrece andamiarla
   preguntando los campos (*) uno por uno y crea `AI/specs/<nombre>.md`.
   NUNCA escribas config de la máquina en el repo: cero secretos, cero
   rutas personales.
5. Cierra con lista de listo/pendiente y siguiente paso: `/flow` si todo
   está listo, `/verify` si el MVP ya está construido.

PROHIBIDO mutar el proyecto salvo la spec andamiada, y solo con
confirmación explícita del desarrollador.
