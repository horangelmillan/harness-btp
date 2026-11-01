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

## 3. Prohibido
Pisar o borrar: `AGENTS.md` raíz existente, `package.json`, `mta.yaml`, lockfiles. Nada de secretos en reportes, prompts ni terminal.

## 4. Verificar lo INSTALADO (obligatorio, no vale `pnpm view` ni `npm view`)
- El archivo `AI/VERSION` debe decir exactamente la versión del comando ejecutado. Si no coincide: dilo y DETENTE, no sigas.
- `git status` solo debe mostrar `AI/`, `.gitignore` (y `pnpm-lock.yaml` si migraste).

## 5. Migración npm→pnpm (solo si aplica)
Solo con `import + install + test` en verde: borra `package-lock.json`.

## 6. Prerrequisitos y pendientes
- Corre `AI/scripts/check-prereqs` (modo aviso) y reporta faltantes.
- Si `AI/AGENTS.md` trae placeholders por adaptar, dímelos antes de desplegar.

## 7. Cierre limpio (obligatorio)
No dejes servidores ni observadores corriendo: detén lo que hayas iniciado y verifica que no queden procesos parados en la carpeta. Nunca intentes borrar una carpeta con procesos dentro: repórtalos.

## 8. Reporte
Comando ejecutado, salida del instalador, contenido de `AI/VERSION`, `git status` y qué quedó pendiente.
