# Setup del harness BTP (protocolo para agentes)

> Fuente única de instalación. El agente que lea esto OBEDECE todo lo aquí escrito, en orden, sin saltarse verificaciones.

## 0. Datos que te faltan, pregúntalos
- Si la carpeta del proyecto está vacía y no te dieron URL de repo: pregunta la URL antes de suponer.
- Si `AI/` ya existe: pide autorización para `--force` antes de usarlo.

## 1. Clonar (solo si aplica)
- Carpeta vacía + URL dada: `git clone --depth 1 [URL] .` dentro de la carpeta. No clones en subcarpeta.
- Carpeta con proyecto existente: no borres ni muevas nada.

## 2. Instalar (versión exacta del README, nunca otra)
- Lee https://github.com/horangelmillan/harness-btp (README, opción pnpm) y ejecuta el comando `pnpm dlx` EXACTO con la versión que ahí se indique, sin cambiarle la versión.
- Con `--force`: verifica primero que imprima la línea `BACKUP` (respaldo real antes de reemplazar).

## 3. Verificación de adopción (obligatorio)
- Confirma que `orchestrator` aparece entre tus agentes disponibles y que el comando `/flow` existe.
- Si no aparecen: revisa que `<proyecto>/.opencode/` tenga el contenido fusionado desde `AI/.opencode/` (`agents`, `commands`, `skills`). Si falta, reinstala sin fuerza (solo copia faltantes) o copia `AI/.opencode/` a `.opencode/` en la raíz del proyecto sin pisar archivos propios.

## 4. MCP del proyecto (fragmento)
- Fusiona `AI/opencode.fragment.jsonc` en el `opencode.jsonc` raíz del proyecto (créalo si no existe): copia los bloques que falten sin borrar los propios.
- Puede requerir reiniciar el cliente para que los cambios surtan efecto.

## 5. Prohibido
Pisar o borrar: `AGENTS.md` raíz existente, `package.json`, `mta.yaml`, lockfiles, archivos propios de `.opencode/` raíz. Nada de secretos en reportes, prompts ni terminal.

## 6. Verificar lo INSTALADO (obligatorio, no vale `pnpm view` ni `npm view`)
- El archivo `AI/VERSION` debe decir exactamente la versión del comando ejecutado. Si no coincide: dilo y DETENTE, no sigas.
- `.opencode/` raíz debe contener lo fusionado desde `AI/.opencode/` (`agents`, `commands`, `skills`).
- `git status` solo debe mostrar `AI/`, `.opencode/`, `.gitignore` (y `pnpm-lock.yaml` si migraste).

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
