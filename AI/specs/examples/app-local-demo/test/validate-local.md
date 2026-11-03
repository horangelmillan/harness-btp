# Validación local esperada (app-local-demo)

1. `powershell -ExecutionPolicy Bypass -File AI/scripts/validate-app.ps1 -Path AI/specs/examples/app-local-demo` → exit 0, todo PASS (BLOCKED solo si faltan `cds`/`mbt`).
2. `bash AI/scripts/validate-app.sh AI/specs/examples/app-local-demo` → misma salida, exit 0.
3. `npx -p @sap/cds-dk cds compile srv/service.cds --to edmx` → exit 0, EDMX con `EntitySet Books` (requiere red/npm).
4. `npm test` (`node --test test/books.test.js`) → 8/8 en verde con SQLite en memoria (401 sin auth, CRUD 201/200/404/400/204).
5. `npx -p @sap/cds-dk cds test` → NO aplica sin `@cap-js/cds-test` instalado (falla con `Cannot find module '@cap-js/cds-test/bin/chest.js'`); documentado en README, no es regresión.
