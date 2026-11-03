# Contratos entre agentes

## Delegación (orquestador → especialista)

Incluir siempre: `tarea-id`, objetivo (1 línea), contexto mínimo
(rutas absolutas + spec/criterios), restricciones (ficheros prohibidos,
presupuesto en minutos/acciones, sin secretos), resultado esperado,
criterios de aceptación (comando de verificación + salida esperada).

Ejemplo:
`T-042 | objetivo: añadir --backup-dir a install.sh | contexto:
install.sh:1-120, docs/backlog/backlog.md | restricción: no tocar
AI/clients/, presupuesto 15 min | esperado: diff + evidencia
`sh install.sh --help` | aceptación: render --check OK`.

## Respuesta (especialista → orquestador)

Resumen ejecutivo (≤10 líneas), trabajo realizado, archivos
modificados/creados, evidencias (comando + salida real recortada),
problemas, pendientes, recomendaciones. Referencias, no volcados
completos. Sin evidencia observable no hay éxito.

## Reglas

- Paralelo solo independiente; el orquestador integra y revisa (`git diff`).
- `reviewer` verifica por muestreo independiente, no re-ejecuta todo.
- `harness-evolution` del producto solo propone; el orquestador meta aplica.
- Toda tarea con navegador exige evidencia `ensure`/`cleanup` de
  `AI/scripts/cdp-chrome.ps1`.
