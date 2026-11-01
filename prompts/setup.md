# Setup del harness BTP (protocolo para agentes)

> Fuente única de instalación. El agente que lea esto OBEDECE todo lo aquí escrito, en orden, sin saltarse verificaciones.

## 0. Datos que te faltan, pregúntalos
- Si la carpeta del proyecto está vacía y no te dieron URL de repo: pregunta la URL antes de suponer.
- Si `AI/` ya existe: pide autorización para `--force` antes de usarlo.
- Cliente agéntico del proyecto: detecta huellas en la raíz (`CLAUDE.md`/`.claude`→claude, `.cursor`→cursor, `.github`→copilot, `opencode.json*`/`.opencode`→opencode). Si hay huellas de varios o ninguna pista, PREGUNTA al usuario qué cliente usa antes de suponer; el instalador acepta `--client auto|all|opencode,claude,cursor,copilot,aider` (`auto` es el defecto y elige solo con huellas claras, sin huellas usa opencode).

## 1. Clonar (solo si aplica)
- Carpeta vacía + URL dada: `git clone --depth 1 [URL] .` dentro de la carpeta. No clones en subcarpeta.
- Carpeta con proyecto existente: no borres ni muevas nada.

## 2. Instalar (versión exacta del README, nunca otra)
- Lee https://github.com/horangelmillan/harness-btp (README, opción pnpm) y ejecuta el comando `pnpm dlx` EXACTO con la versión que ahí se indique, sin cambiarle la versión.
- Con `--force`: verifica primero que imprima la línea `BACKUP` (respaldo real antes de reemplazar).

## 3. Verificación de adopción (obligatorio)
- Confirma que `orchestrator` aparece entre tus agentes disponibles y que el comando `/flow` existe.
- Si no aparecen: revisa que la raíz tenga el árbol fusionado del cliente que usas (ver tabla; fuente única: `AI/agents/`, `AI/commands/`, `AI/skills/`, renderizado a `AI/clients/`). Si falta, reinstala sin fuerza con el `--client` que corresponda (solo copia faltantes):

| Cliente | Qué debes ver en la raíz | Origen renderizado |
|---|---|---|
| opencode | `.opencode/agents/`, `.opencode/commands/`, `.opencode/skills/` | `AI/clients/opencode/` |
| claude | `.claude/agents/`, `.claude/commands/`, `.claude/skills/` (agents sin `mode`) | `AI/clients/claude/` |
| cursor | `.cursor/commands/`, `.agents/skills/` (commands sin frontmatter) | `AI/clients/cursor/` |
| copilot | `.github/agents/*.agent.md`, `.github/prompts/*.prompt.md`, `.github/skills/` | `AI/clients/copilot/` |
| aider | nada que fusionar: usa el `AGENTS.md` raíz | — |

- Si tu cliente sigue sin ver los agentes tras la fusión, dilo y DETENTE: no inventes rutas ni dupliques archivos a mano.

## 4. MCP del proyecto (fragmento, solo OpenCode)
- Fusiona `AI/opencode.fragment.jsonc` en el `opencode.jsonc` raíz del proyecto (créalo si no existe): copia los bloques que falten sin borrar los propios. Otros clientes lo ignoran sin efecto.
- Puede requerir reiniciar el cliente para que los cambios surtan efecto.

## 5. Prohibido
Pisar o borrar: `AGENTS.md` raíz existente, `package.json`, `mta.yaml`, lockfiles, archivos propios de `.opencode/` raíz. Nada de secretos en reportes, prompts ni terminal.

## 6. Verificar lo INSTALADO (obligatorio, no vale `pnpm view` ni `npm view`)
- El archivo `AI/VERSION` debe decir exactamente la versión del comando ejecutado. Si no coincide: dilo y DETENTE, no sigas.
- La raíz debe contener el árbol fusionado del cliente detectado/elegido (ver tabla del paso 3; `.opencode/` para opencode, `.claude/` para claude, etc.).
- `git status` solo debe mostrar `AI/`, los dirs del cliente (`.opencode/`, `.claude/`, …), `.gitignore` (y `pnpm-lock.yaml` si migraste).

## 7. Migración npm→pnpm (solo si aplica)
Solo con `import + install + test` en verde: borra `package-lock.json`.

## 8. Prerrequisitos y pendientes
- Corre `AI/scripts/check-prereqs` (modo aviso) y reporta faltantes.
- Si `AI/AGENTS.md` trae placeholders por adaptar, dímelos antes de desplegar.

## 9. Cierre limpio (obligatorio)
No dejes servidores ni observadores corriendo: detén lo que hayas iniciado y verifica que no queden procesos parados en la carpeta. Nunca intentes borrar una carpeta con procesos dentro: repórtalos.
Si el usuario va a borrar la carpeta del proyecto: adviértele que PRIMERO debe cerrar esta sesión (quitarla de la lista no apaga sus procesos: siguen vivos, parados en la carpeta, y Windows bloqueará el borrado). Solo cuando resmon no muestre candados puede borrar.

## 10. Reporte
Comando ejecutado, salida del instalador, contenido de `AI/VERSION`, `git status` y qué quedó pendiente.
