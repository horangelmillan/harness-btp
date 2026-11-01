
Ejecuta solo la puerta de despliegue (etapa 7) para $ARGUMENTS
(spec o nombre de app; si se omite, el MVP en curso).

Verificaciones (delegables en `qa-review` + `deploy-cf` en solo lectura):

1. `cf target` coincide con el destino de la spec (endpoint/org/espacio).
2. El artefacto existe y es reciente (`.mtar` en `mta_archives/` o bundle
   para `push`).
3. Todos los criterios de aceptación están en verde con evidencia.
4. Diff/Git sin secretos ni archivos que debieran estar ignorados.

Veredicto: apto / no apto con motivos concretos. Este comando nunca
despliega ni muta nada en Cloud Foundry.
