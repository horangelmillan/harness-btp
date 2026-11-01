# Upgrade del harness en un MVP sin ensuciar el repo

> Nunca `cp -r AI AI.bak*` dentro del proyecto. El backup va fuera del repo
> o vía git. Ver `AGENTS.md` § Frontera harness/proyecto.

1. Preflight: `git status --porcelain` limpio o con solo cambios del MVP;
   `git stash` si hay trabajo a medias. Anotar `AI/VERSION` actual.
2. Backup FUERA del repo (nunca `AI.bak*` dentro):
   - Windows: `Compress-Archive -Path AI,.opencode,opencode.jsonc -DestinationPath $env:TEMP/harness-bak/<yyyy-MM-dd>/harness-antes-vX.zip`
   - Unix: `tar -czf $HOME/.harness/bak/<yyyy-MM-dd>/harness-antes-vX.tgz AI .opencode opencode.jsonc`

   Alternativa git: `git stash push -m "antes-upgrade-harness-vX"`.
3. Reinstalar/actualizar `AI/` desde el base (o `harness upgrade` cuando
   exista en el instalador).
4. Reaplicar `AI/.gitignore.fragment` al `.gitignore` del MVP (solo añade
   líneas ausentes, nunca duplica); informar líneas añadidas.
5. Regenerar `opencode.jsonc` real solo si falta (desde
   `AI/opencode.jsonc.example`); nunca commitear el real.
6. Verificación: `AI/scripts/check-prereqs` en verde (o con faltantes
   reportados), `git status` sin `AI.bak*`/`.opencode`/`opencode.jsonc`,
   spec con la nueva versión.
7. Registrar en la spec: `Upgrade harness vA → vB (<fecha>)`.

Pendiente-upstream: comando `upgrade` en el instalador
(`harness upgrade [--dry-run]`) que ejecute 1–6 con backup fuera del repo
por defecto y reporte idempotente del `.gitignore`.
