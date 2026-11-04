# Backlog

Roadmap: [fuente de verdad del roadmap](../engineering/roadmap/source-of-truth.md)

## Ahora (P-siguiente)

- [x] R3-E IAS + Connectivity (PARCIAL/CONDICIONADA 2026-11-04): IAS
  VERIFICADO (límites trial): trust `sap.default` (Business and platform
  users, origin sap.default) Active, 1 entry, intacto — re-verificado hoy
  vía `btp list security/trust` (cero mutaciones de trust en todo R3);
  IdP del login approuter = IAS (`accounts.sap.com`, `uaa-cf-us10` 2FA,
  observado en sesiones headed R3-F/R3-F-close); propagación principal
  IAS→XSUAA probada funcionalmente (matriz Editor/Viewer R3-F-close:
  201/403 por rol con sesión SSO); sesión BTP CLI caducada → re-login SSO
  interactivo del usuario (sin pedir credenciales) y re-verificación OK.
  Entitlements vigentes: connectivity lite (1) + connectivity_proxy (1),
  destination lite (1), identity application (1), APPLICATION_RUNTIME
  MEMORY 4. Instancias: solo 4 (books-xsuaa, books-destination, books-hana,
  books-db); SIN instancia connectivity, SIN instancia identity
  (tenant-level, esperado). Connectivity cloud-cloud: plan disponible,
  runtime NO VERIFICADO (sin instancia/binding/prueba; crear una sin
  backend no probaría nada — no se creó nada). On-prem: BLOQUEADO — sin
  Cloud Connector (puerto 8443 cerrado, sin dir install, sin servicio) y
  sin sistema backend; la llamada Destination OAuth2 a books-srv (R3-D)
  es cloud-cloud y NO se presenta como prueba de Connector/on-prem.
  Prerrequisito exacto para cerrar Connectivity: Connector instalado +
  backend alcanzable + destino con conectividad + instancia lite; entonces
  test de propagación de principal. Cero mutaciones BTP en R3-E (todo
  lectura + re-login usuario); cero secretos; cuota sin cambios.
  Veredicto: R3-E PARCIAL/CONDICIONADA (IAS verificado; Connectivity
  runtime pendiente de prerrequisitos de entorno, no del harness).
  OPP-009 sigue VALIDATING. Siguiente: R3 cerrada en lo verificable;
  retomar §6. (Salidas observadas en sesión del orquestador 2026-11-04;
  comandos: `btp list security/trust`, `btp list accounts/entitlement`,
  `btp list services/instance`, `cf services`/`marketplace`, check 8443.)

- [x] R3-F integración full-stack (COMPLETADA 2026-11-04): diseño
  T2 harness-architect opción B estáticos en books-srv (+0M, sin
  recursos nuevos) + autorización usuario "Aprobar deploy UI5"
  (org e1156e9atrial/space dev; mismos módulos/recursos; +0M) + 2
  correcciones (CDN 1.120.0→1.120 por 404 del exacto, lección T5.5; base
  href /app/ por resolución de recursos en /). Local: `npm test` 11/11,
  UI5 local 200 (/app/index.html, manifest books.ui5, OData [], health);
  `validate-app -Path` exit 0; `validate-meta` 58 OK; build+deploy OK
  (apps STARTED, bindings intactos). SSO headed: aviso previo al usuario,
  Chrome visible con perfil persistente `~/.harness/browser-profile`,
  login manual solo SSO (sin pedir JWT/código; OPP-021 respetada), PIDs
  propios limpiados, puerto 9222 libre. Diagnóstico $batch con red (CDP +
  playwright network): #23 GET $metadata 200; #24 POST $batch 403
  "Forbidden" (9B, sin token = desafío CSRF); #25 HEAD 200 (token fetch
  automático del modelo); #26 POST $batch 200 con header x-csrf-token y
  cuerpo con HANA Proof + Proof 2; tabla 3 filas con ambos registros.
  Conclusión: handshake CSRF estándar, modelo auto-recuperado, SIN defecto
  (P1 anterior retirado con evidencia). MTAR: `excludes:` ignorado por
  builder npm (empírico 2 sintaxis) → `ignore:` sí honrado; MTAR final
  52.906.918 bytes; data.zip solo prod (app, srv, db, server.js,
  node_modules; sin test/approuter/db.sqlite/gen/.mtaignore/.vscode/
  Makefile). Post-deploy limpio: tabla con Proofs; R3F-UI-mievy9 201→204
  + filtro R3F- []; Proofs intactos (4 redeploys); Component-preload 404
  benigno; screenshot timeout menor. Matriz Editor vía approuter con CSRF:
  GET colección 200 (HANA Proof + Proof 2), $metadata 200, POST 201,
  GET 200, PATCH 200, PATCH inválido 400, DELETE 204, GET 404.
  Persistencia restart (`cf restart`, filter 200) y redeploy verificadas.
  Limpieza: DELETE 204 + filtro R3F- 200 []; HANA Proof* intactos; cero
  secretos en repo; keys temporales 0. Hallazgos: P2 excludes-vs-ignore
  builder npm registrado (lección mta-build, posible mejora futura de
  skill/docs producto — pendiente, no cambio); P3 screenshot timeout +
  403 solo-Viewer no testeable (identidad única con ambos roles). QA APTO
  parcial (re-verificó tests/MTAR/apps/services; no re-verificó SSO por
  presupuesto) + reviewer COMPLETADA (sin bloqueos). Veredicto: R3-F
  COMPLETADA 2026-11-04. R3-E no tocada ni marcada (a fecha R3-F). OPP-009 sigue
  VALIDATING (falta checklist+ejemplo HDI producto). Siguiente: R3-E y
  pendientes §6.

- [x] R3-B HANA Cloud + HDI (COMPLETADA 2026-11-04): base
  `books-hana` READY (hana-free 16/80/1, systempassword del usuario
  solo en memoria transitoria; calibración: sin `-c`/`{}` falla, 30 GB
  y 32 GB rechazados por límites trial) + HDI `books-db` sin
  `database_id` (broker resuelve la base; Central innecesario) +
  deployer Exit 0 + srv STARTED con HANA (fix: `db.sqlite` fuera del
  MTAR + disk 1G) + POST 201 automatizado (sin pedir código, OPP-021)
  + persistencia tras restart puro (`HANA Proof 2`). Lección: el POST
  previo se perdió por redeploy intermedio, no por restart. OPP-009 →
  VALIDATING. Siguiente: R3-E o R3-F.

- [x] R3-C XSUAA (COMPLETADA 2026-11-04): instancia `books-xsuaa` (application, `books-dev`) creada
  con `-c xs-security.json` (ruta de fichero; JSON inline rechazado por
  el CLI) + binding `existing-service` + `auth: dummy` dev / `xsuaa`
  `[production]` + suite 11/11 + MTAR 20.6 MB + deploy OK. Runtime:
  sin token 401 (colección + $metadata), JWT malformado 401,
  `/health` 200, token client_credentials válido sin scopes 403
  (key temporal `r3c-temp` creada→usada→borrada y verificada en 0 keys,
  cero secretos en repo/logs). Lecciones: dummy ignora el binding
  (exige perfil production); `cds-serve` no sirve SQLite en CF.
  Pendiente guiado resuelto en R3-D: 200 con rol verificado vía approuter
  tras login SSO (ver entrada R3-D).

- [x] Branch protection (RESUELTO 2026-11-04, verificado remoto):
  ruleset `main-requiere-validate` (id 26513554, enforcement active) en
  refs/heads/main exige check `validate` (integración 15368,
  strict=false); repo sin protección previa (protection 404, rulesets [])
  ni otras protecciones alteradas; workflow `Validate meta` job `validate`;
  temp `ruleset-main.json` borrado. Siguiente §6 pendiente: pin SHA.
- [x] Pin SHA acciones (RESUELTO-por-verificación 2026-11-04, sin edición de workflows): 2 workflows (.github/workflows/validate-meta.yml, publish.yml), 4 referencias `uses:`, todas con pin SHA + comentario `# v6`: actions/checkout@d23441a48e516b6c34aea4fa41551a30e30af803 # v6 (2026-07-16) y actions/setup-node@249970729cb0ef3589644e2896645e5dc5ba9c38 # v6 (ambos workflows); verificación upstream (gh api repos/<org>/<repo>/commits/v6): checkout → d23441a48…af803 COINCIDE, setup-node → 24997072…5ba9c38 COINCIDE; sin majors que actualizar (v6 vigente en ambos), sin cambios de comportamiento; alcance: sin reusable workflows, sin imágenes Docker, sin referencias locales en workflows; check `validate`, triggers, permisos y jobs intactos; `validate-meta` 58 OK; versión 0.3.2 intacta. Siguiente §6 pendiente: actualizar columna fecha en AI/docs/fuentes-oficiales.md → 2026-11-03.
- [x] Indexar `harness-btp` en `codebase-memory` → proyecto
  `C-Users-Horan-Desktop-harness-btp`, 726 nodos / 790 aristas,
  `index_status: ready` (2026-11-03).
- [x] Actualizar columna fecha en `AI/docs/fuentes-oficiales.md` (RESUELTO 2026-11-04): `./AI/scripts/check-docs.ps1` exit 0: 7/7 OK (cf-cli, mbt, cap, ui5-cli, opencode, npm-trusted-publishers REQUERIDAS + op-1password OPCIONAL con redirect 308 ya documentado). Fechas registradas: 2026-11-04 real en las 7 celdas (NO la objetivo 2026-11-03); línea 26 actualizada. Cero URLs rotas, cero cambios de contenido que exijan modificar guías → sin trabajo adicional. Gates: render 65 OK (0 escritos), validate-meta 58 OK, triple 0.3.2, check-package 183 limpio. Siguiente §6 pendiente: completar `.gitignore.fragment` multi-cliente (P2, escenario E: sin promocionar a P1).
- [x] P2: completar `.gitignore.fragment` multi-cliente (RESUELTO-por-verificación 2026-11-04, sin edición del fragmento): las 6 entradas YA existían (commit b7a6195 R1 2026-11-03, blame líneas 25-31): `.claude/`, `.cursor/`, `.agents/` (+`.agents/skills/`), `.github/agents/`, `.github/skills/`, `.github/prompts/`; cero ediciones necesarias. Escenario E validado con mecanismo existente: `install.ps1 -Dest temp/s64-install` fusiona las 6 (grep OK); `git check-ignore -v` en repo scratch: ignorados `.claude/c.md`, `.cursor/x.md`, `.github/agents/a.md`, `.github/prompts/p.md`, `.github/skills/s2.md`, `.agents/skills/s.md` (este último vía regla padre `.agents/`); visibles `.github/workflows/ci.yml` y `README.md` (check-ignore vacío). `.github/` completo NO ignorado; workflows intactos. Transitorios borrados. Sin cambios de producto (fragmento intacto); `validate-meta` 58 OK; clasificación P2 conservada (no promocionado a P1, escenario E). Siguiente §6 pendiente: backup fuera del repo (`--backup-dir`, `%TEMP%/harness-bak`) + alinear con AI/AGENTS.md § Frontera.
- [x] P2: backup fuera del repo (RESUELTO 2026-11-04, P2 conservada — NO promocionada a P1): diseño T2 harness-architect + implementación + 2 fixes + QA matriz + reviewer. Cambio: default fuera del proyecto (ps1 `%TEMP%/harness-bak/<yyyy-MM-dd>/`, sh `$HOME/.harness/bak/<yyyy-MM-dd>/`; `-BackupDir`/`--backup-dir` lo sustituye añadiendo fecha salvo que termine en fecha); pre-validación ABORT exit 1 si backup-dir dentro del destino (incluye rutas relativas: fix `canon_path` con prepend cwd en sh; ps1 vía GetFullPath); nombres únicos `<base>-<HHmmss>[-n].bak` tope 100, SIN borrar previos (eliminados Remove-Item/rm -rf de backups); BakLabel = basename real; ayudas actualizadas; mensajes SKIP/CREATE/BACKUP/OK/ABORT intactos. QA: matriz 4 fixtures × ps1/sh 8/8 PASS tras fix (inicial sin backup; update con backup recuperable fuera + 2º force sin borrar; override fechado/no-duplicado; rechazo interno relativo+absoluto exit 1 dest intacto; sh en Git Bash). Reviewer: APTO-CON-PENDIENTES, P1 ninguno; P2 colisión mismo segundo entre árboles con igual basename (`skills` ×3, distinguibles solo por ruta completa del mensaje — sin pérdida de datos, mejora futura de nombre); P3 symlinks/case en canon_path + trap ruidoso (menores, futuros). Gates: validate-meta 58 OK; triple 0.3.2 intacta (sin bump); render N/A justificado (no se toca AI/canónico); check-package N/A (instaladores fuera de npm). Cero secretos; transitorios y .bak de prueba borrados. Siguiente §6 pendiente: P3 `bump-version.js` único (adiós triple edición manual).
- [x] P3: `bump-version.js` único (RESUELTO 2026-11-04, P3 conservada — mecanismo completado, NO bump): el mecanismo YA existía (`scripts/bump-version.js`, R1.2: `<X.Y.Z> [--check]`); §6.6 lo COMPLETA con guarda pre-escritura (+6 líneas): en modo escritura aborta (exit 1, sin escribir) si la triple previa discrepa; interfaz y estilo intactos. Validación: repo real `--check` → OK 0.3.2 exit 0; sandbox temp triple discrepante → `--check` y escritura exit 1 sin escribir; sandbox triple 0.0.0 → escritura 9.9.9 OK + guardia OK; sandbox borrado. Triple real 0.3.2 intacta (SIN bump: la tarea centraliza procedimiento, no versiona). Gates: `validate-meta` 58 OK; sin cambios en AI/, workflows, versions, docs de producto; cero secretos. Siguiente §6 pendiente: paridad `provision-espacio` + `cf-safe.sh` + pre-commit (par `.sh`).
- [x] P3: `provision-espacio` par `.sh` + `cf-safe.sh`/`pre-commit` par (§6.7 RESUELTO 2026-11-04, P3 conservada): diseño
  T2 + implementación F1 (CF_BIN con fallback en ambos provision-templates) + F2 (sh acepta $2/$3) + F3
  (gate service-key+valores→exit 2 sin --allow-write en sh) + fix WhatIf-redactado + fix canon_path relativas
  + 2 micro-edits del orquestador (divergencia NeedValues documentada como intencional; Bearer/JWT en WhatIf sh).
  QA matriz stub-cf 7/7 PASS (PS5.1 + Git Bash, sin BTP real) + re-verificación orquestador (d)-sh
  relativo/absoluto ABORT exit 1, force OK; probes Bearer/JWT redactados, what-if plano intacto. Reviewer
  APTO-CON-PENDIENTES, P1 ninguno; P2 gate 1-flag vs 2-flags (divergencia intencional documentada: sh nunca
  devuelve valores); P3 substring-falso-SKIP y trap ruidoso (aceptados, documentados). Diferencias aceptadas por
  diseño (NO tocadas): P3 match exacto/substring, S2 JSON shape, S3 sed/`set --`, S4 wording, sin dry-run en
  provision, args con espacios no soportados en sh. Gates: validate-meta 58 OK; render N/A justificado
  (AI/scripts no propaga a AI/clients/); triple 0.3.2 intacta; cero secretos; transitorios borrados.
  Siguiente §6 pendiente: granularidad de logs publish (regresión menor P1 — log CI menos granular tras
  unificar publish.yml).
- [x] P1 (mejora no bloqueante): granularidad logs publish (§6.8 RESUELTO
  2026-11-04): historial 9af5d2c steps sin nombre → b7a6195 nombres+pins →
  c1d3f74 guardia check-package; lo que se perdía: límites entre
  validación/preparación/publicación (logs fundidos). Cambio: grupos
  colapsables `::group::1/4..4/4` envolviendo los runs existentes + echo de
  versión en 4/4 (`Publicando create-harness-btp v$(node -p ...)`); triggers/
  permisos/OIDC/pins SHA/nombres/check `validate`/semántica intactos; cero
  secretos (solo versión pública). Validación sin publicar: `gh workflow view`
  parsea el YAML en servidor OK; simulación local de cuerpos (pack dry-run 183
  ficheros, version echo 0.3.2, check-package 183 limpio, validate-meta 58 OK).
  Mejora no bloqueante conservada (no exige re-publicación).
  Siguiente §6 pendiente: §6.9 OPP-006/008/009 COMPLETED 2026-11-04 +
  restantes exactos (ver entrada Siguiente).
- [x] §6.9 OPP-006 COMPLETED (2026-11-04): criterio "despliegue
  CF/XSUAA" cubierto por R3-C (instancia application + binding + matriz
  401/403/200 + roles Viewer/Editor), R3-D (200 con rol), R3-E (trust
  sap.default + propagación IAS→XSUAA), R3-F (integración). Artefactos ya
  existentes: xs-security-checklist + xs-security.json + sap-verify +
  _template. Reviewer APROBAR-CON-CAMBIOS (P3 conteo fuentes aplicado);
  QA APTO. Cero BTP nuevo.
- [x] §6.9 OPP-008 COMPLETED (2026-11-04): criterio "prueba real BTP
  destino/Approuter" cubierto por R3-D (lite OAuth2UserTokenExchange, SSO,
  200 {"value":[]}, PUT 405→recreate, TENANT_HOST_PATTERN) + R3-F (UI5 tras
  approuter). Artefactos: destination-approuter-checklist + 2 ejemplos.
  Reviewer APROBAR-CON-CAMBIOS (P3 conteo fuentes aplicado); QA APTO.
  Cero BTP nuevo.
- [x] §6.9 OPP-009 COMPLETED (2026-11-04): checklist
  AI/docs/hana-hdi-checklist.md + ejemplo
  AI/specs/examples/mta-hdi-snippet.yaml CREADOS y validados (URLs 4/4
  vivas 2026-11-04, 5ª 404 descartada; requires sin huérfanos; cero
  secretos; render 65 OK, validate-meta 58 OK, triple 0.3.2). Runtime ya
  probado en R3-B (CRUD 201 + restart + Proofs tras 4 redeploys).
  Reviewer APROBAR-CON-CAMBIOS (P3 conteo fuentes aplicado); QA APTO.
  Límite conocido P2: snippet sin validación mtad-gen/mbt (fragmento, no
  app desplegable) — pendiente antes del primer uso real. Cero BTP nuevo.
- [x] §6.9 OPP-023 COMPLETED (2026-11-04): bullet arranque único `cds run`
  en AI/skills/cap-cli/SKILL.md:37 (+ aclaración :35); suite R3-F-close
  11/11 <1s; render 65 OK, meta 58 OK; QA APTO + reviewer APROBAR (tarea
  §6-learnings). Cero BTP nuevo.
- [x] §6.9 OPP-024 COMPLETED (2026-11-04): subsección Exclusión en
  AI/skills/mta-build/SKILL.md:24-25 (`ignore:` honrado, 246MB→52.9MB);
  render 65 OK, meta 58 OK; QA APTO + reviewer APROBAR (tarea
  §6-learnings). Cero BTP nuevo.
- [x] §6.9 OPP-025 COMPLETED (2026-11-04): bullet subruta en
  destination-approuter-checklist.md:61 + quirks (e2e-fiori.md:35) +
  extensión $batch CSRF (e2e-fiori.md:51, L4 fuera de esta OPP por diseño);
  UI5 CF verificada con datos HANA vía $batch real; render 65 OK, meta 58
  OK; QA APTO + reviewer APROBAR (tarea §6-learnings). Cero BTP nuevo.
- [ ] Siguiente §6 pendiente / restantes exactos (2026-11-04, sin mezclar):
  - P2 snippet mtad-gen RESUELTO 2026-11-04 (fixture aislada temp/t611, `mbt mtad-gen` exit 0: mvp-hdb/mvp-srv → mvp-hdi, recursos hana/hdi-shared; sin defectos, sin despliegue)
  - P2 colisión basename `skills` RESUELTO 2026-11-04 (§6.12 nombres backup inequívocos, P2 conservada — NO promocionada a P1): fix tag saneado en Get-UniqueBackupPath/unique_backup_path (`<tag>-<HHmmss>[-n].bak`, tope 100, ABORT al agotar); call sites AI→`AI`, Merge-Tree→label (agents-skills, github-skills, opencode); 1 línea ayuda c/u; paridad ps1/sh; sin rutas personales en el nombre (solo etiqueta); ABORT pre-cambio y mensajes intactos. QA APTO: 3 dests × 2 skills trees × ps1/sh = 12 backups únicos e identificables; colisión real mismo segundo en ps1 (`AI-030523`+`AI-030523-1` vía contador); contenido preservado (markers); update/restore OK (restore=copia manual, sin comando); cero .bak en dests; sh probe contador OK. Reviewer APTO-CON-PENDIENTES, P1/P2 ninguno; P3: race TOCTOU concurrente ínfimo, HHmmss sin fecha (aislado por dir yyyy-MM-dd), heredados symlinks/case + trap (NO reabiertos, siguen separados). Gates: validate-meta 58 OK; triple 0.3.2; render N/A (AI/scripts no propaga); cero secretos; transitorios borrados.
  - P3 symlinks/case canon_path + trap ruidoso RESUELTO 2026-11-04 (§6.13, P3 conservada — NO promocionada; TOCTOU NO reabierto, sigue P3 separado): fix canon_path físico + trap on_exit. QA inicial NO-APTO (junctions intermedias no resueltas: fail-open sh con 2 niveles inexistentes + ps1 solo reparse final); fix: sh baja al ancestro existente + pwd -P, ps1 camina todos los componentes con Resolve-Link (.Target, tope 32); trap on_exit (EXIT preserva código, INT→130/TERM→143 con mensaje stderr, MT_CLEANUP="" tras merge OK). Re-verificación orquestador con junctions reales mklink /J (sin admin): ps1 y sh ABORT exit 1 ante junction→dentro (relativa y absoluta), ACEPTAN e instalan exit 0 ante junction→fuera; exit 0 en éxito-con-avisos en ambos (un "exit 1" intermedio fue artefacto de Select-Object truncando el pipe, verificado en limpio). Reviewer APTO (P1 ninguno; P2 ninguno; P3: TOCTOU separado, symlinks /D sin privilegios NO-VERIFICADO con junctions como cobertura Windows). Symlinks /D reales: NO-VERIFICADO (mklink exige privilegios; causa registrada). Gates: validate-meta 58 OK; triple 0.3.2; render N/A (AI/scripts no propaga); cero secretos; temp/t613 + backups de prueba borrados (incl. $TEMP/harness-bak/<fecha> del orquestador).
  - P3 Component-preload 404 benigno + screenshot timeout TRIADO §6.15 2026-11-04 (ver entrada §6.15; cero fixes)
  - P3 ventana TOCTOU MITIGADA (§6.14 MITIGADO 2026-11-04, P3 conservada — NO eliminada, riesgo residual explícito, nada reabierto): mitigación con mecanismos existentes, sin locks por diseño: Assert-ExternalBackupRoot/assert_external_backup_root llamados justo antes de cada escritura (AI + Merge-Tree), pre-validación intacta; ventana reducida a microsegundos. QA APTO: revalidación detecta reapuntado j→dentro (ABORT exit 1, dest intacto) en ps1+sh; race-loop 30 installs + 80 flips: 22 ABORT, 8 exit 0, 0 .bak dentro; regresión update/restore OK; limpieza hecha. Reviewer APTO (P1 ninguno; P2 opcional: revalidar también el path final $Bak — registrado como mejora futura, NO aplicado). Riesgo residual EXPLÍCITO (NO declarar eliminado): intercalado exacto entre Assert y Move (microsegundos, 0/30 en prueba) sigue teóricamente posible; TOCTOU concurrente real posible aunque no observado; impacto acotado (backup caería dentro del proyecto u otra ruta local; sin secretos en backups más allá del contenido del repo). Siguiente §6 pendiente: P3 symlinks /D sin privilegios (NO-VERIFICADO, intacto) + resto P3 (preload 404, screenshots, 403 solo-Viewer; colisión basename ya resuelta §6.12).
  - 403 solo-Viewer no testeable TRIADO §6.15 2026-11-04 (LIMITACIÓN DE IDENTIDAD; ver entrada §6.15; cero fixes)
  - [x] §6.15 symlink /D + triage P3 R3-F (REGISTRADO 2026-11-04, solo-docs, sin cambios de código): symlink /D `cmd /c mklink /D temp\t615\link-out temp\t615\real` → error "Carece de privilegios suficientes para realizar esta operación", exit 1; sin Developer Mode ni elevación (prohibido elevar/retocar ACLs); resultado: caso symlink /D queda NOT VERIFIED con esa causa; cobertura Windows sigue siendo junctions mklink /J (ya verificadas §6.13/§6.14: ABORT dentro / ACEPTA fuera); fixture temp/t615 borrada. Triage P3 R3-F (clasificación, cero fixes, evidencia ya en R3-F/R3-F-close): a) 404 Component-preload.js → BENIGNO (estándar UI5 sin bundle pregenerado, fallback a individuales; app cargó y tabla mostró datos; observado en múltiples sesiones); b) timeout screenshot Playwright (fuentes) → LIMITACIÓN DE HERRAMIENTA/entorno (evidencia DOM+red ya cubría la verificación; no bloquea); c) 403 solo-Viewer no probado → LIMITACIÓN DE IDENTIDAD (identidad única con ambos roles; requeriría 2ª identidad/paisaje ampliado: NO se hace). Ninguno es defecto reproducible → cero fixes; P2 revalidación path final $Bak intacto como mejora futura opcional (separado); TOCTOU/symlinks/P3 cerrados intactos. Siguiente real: sin pendientes accionables en §6; §6 funcionalmente completo con los límites documentados (symlink /D NO-VERIFICADO, TOCTOU residual MITIGADO, P3 heredados benignos/limitados, P2 $Bak opcional).
  - OPP-006/008/009/023/024/025 COMPLETED 2026-11-04 (fuera de la lista)
  - Granularidad publish RESUELTA §6.8 (fuera de la lista)

## Después

## Hecho

- [x] Release 0.4.0 (PUBLICADA 2026-11-04): flujo E completo. QA APTO
  (render 65, triple, installers smoke, validate-meta 58, check-package
  185, pack dry-run), docs README (backups externos + v0.4.0 +
  changelog), bump-version.js 0.3.2→0.4.0 triple OK, gates verdes,
  PR #4 (check validate verde) mergeado 4a7728e, tag v0.4.0 pusheado,
  workflow Publish to npm OIDC success (run 41802784727, 18s, tarball
  0.4.0 185 ficheros), npm confirma create-harness-btp@0.4.0
  2026-11-04T08:53:27Z. Ramas release-0.4.0 borradas (local+remoto).
  Cero secretos.

- [x] Perfil navegador persistente opt-in COMPLETED 2026-11-04 (OPP-022):
  `HARNESS_BROWSER_PROFILE` reutiliza SSO (temporal por defecto
  intacto); QA APTO + reviewer con P2/P3 aplicados; gates 65/58/183;
  activación: 1 línea en `~/.harness/local.ps1` (fuera del repo).

- [x] Mejora E2E interactivo COMPLETED 2026-11-04 (OPP-020): `e2e-fiori`
  con espera por evento + monitoreo activo + pre-chequeo visible +
  anti-atasco (lección R3-D: navegador abierto observable, espera al
  SSO por evento, sin waits ciegos); QA APTO + reviewer
  APTO-CON-PENDIENTES (P3 aplicado); gates 65/58/183/0.3.2; sin
  commit/push.

- [x] R3-D Approuter + Destination (COMPLETADA 2026-11-04, 200 con rol
  verificado en navegador del usuario): `books-approuter` + `books-srv`
  STARTED, `books-destination` lite, destino `books-srv`
  (OAuth2UserTokenExchange + credenciales del token-service, keys
  temporales borradas). Fixes: `logout` objeto, `.mtaignore` + limpiar
  `mta_archives` (anidado), sin `methods` en approuter 23.x (Viewer en
  ruta, Editor vía CAP 403), `TENANT_HOST_PATTERN` (update a dedicated
  imposible), `redirect-uris` registradas, destino con Name/KeyName y
  luego con credenciales (path API válido:
  `destination-configuration/v1/instanceDestinations`; `PUT` 405,
  recrear por DELETE+POST). Matriz: sin login redirect/401, token sin
  scopes 403, login SSO + rol → 200 `{"value":[]}`. Incidente e2e-fiori
  (espera ciega + cierre por PID, lección registrada). Pendiente menor:
  403 solo-Viewer (usuario con ambos roles) y arranque E2E headed desde
  sub-sesión (sin desktop app). Siguiente: R3-B o R3-E.

- [x] R3-A CF + CAP + OData V4 + MTA (2026-11-04, DESPLEGADO y verificado):
  app Books en `temp/r3a/books` (OData V4, SQLite efímero declarado,
  `mta.yaml` 256M sin servicios gestionados): `cds compile` exit 0, suite
  local 6/6, `validate-app` sin FAIL, `mbt build` OK (MTAR final 14.6 MB).
  Despliegue autorizado → 3 ciclos: (1) crash por auth JWT sin XSUAA (fix:
  `cds.requires.auth.kind: dummy`); (2) 500 por SQLite sin esquema (fix:
  `cds deploy --to sqlite` en build + `server.js` ESM con esquema en el
  MTAR); (3) VERDE: `books-srv` started web:1/1 en
  `e1156e9atrial-dev-books-srv.cfapps.us10-001.hana.ondemand.com`, CRUD
  HTTP 200/201/200/204/404 con registro de prueba eliminado, 0 servicios
  creados. Lecciones: builder `npm` sin `commands`; `cds-serve` no sirve
  SQLite en CF (requiere `server.js` + esquema desplegado); SQLite
  efímero ante restage. Siguiente: R3-B; sin commit/push.

- [x] R3.0.1 preparación operativa local (2026-11-04): skill producto
  `btp-cli` (solo lectura `--info/get/list`, convención `$env:BTP_BIN`,
  espejo de `cf-cli`) + `cf-safe.ps1` honra `$env:CF_BIN` con guardia
  fail-closed basename (nombres `cf`/`sap_cf`) + `check-prereqs.ps1/.sh` resuelven `CF_BIN` con
  hint de mapeo + `cf-safe.sh` guardia basename y quote de binario con
  espacios + fila `btp-cli` en catálogo + `BTP_BIN` en tabla `AI/AGENTS.md`;
  `AI/clients/` vía render (65 archivos); validación viva: `btp --info` +
  `get subaccount` vigentes, broker ps1/sh `target` OK contra
  `api.cf.us10-001` con binario real v8.19.0 (mapeo local no versionado
  `sap_cf.cmd` → `cf.exe`; el otro `cf` en PATH es ajeno, sin renombrar ni
  reinstalar CLIs), `npx -p @sap/cds-dk` operativo
  (10.2.0 en npm), `check-prereqs` FALTA+hint sin mapeo y OK con mapeo en
  ps1/sh; gates `render --check` 65 OK, `check-package` 183 limpio, triple
  0.3.2, `validate-meta` 58 OK; QA APTO-CON-PENDIENTES (pendiente cubierto
  por evidencia viva del orquestador) + reviewer APTO-CON-PENDIENTES
  (P1-P3 paridad sh/AGENTS aplicados y re-verificados, incl. fix quote de
  ruta con espacios); decisiones: sin bump de versión, `cap-cli`
  (`npx -p`) y `sap-verify` (solo clasifica) intactos, `AI/.opencode/`
  espejo local no tocado, raw logs transitorios borrados; siguiente: R3-A;
  sin commit/push, sin provisión/despliegue BTP.

- [x] R2.4 `opencode.jsonc` por fases + telemetría local (2026-11-03):
  `AI/opencode.jsonc.example` extendido (1 activo `graphify-code` byte-igual
  fragment + 6 MCP comentados por fase, placeholders `<...>`, claves
  verificadas schema OpenCode v2.0.23 incl. `timeout`) +
  `scripts/check-opencode-example.js` (estructural, "no implica conectado") +
  `AI/scripts/log-telemetry.js` (opt-in `HARNESS_TELEMETRY=1`, JSONL `temp/`,
  duración+exit reales, `steps` omitido sin fuente, redacción
  `token|secret|passwd|pwd|password|key=|authorization=`) +
  `scripts/tests/test-*.js` 7 pass/0 fail + `AI/docs/opencode-fases.md` +
  `docs/engineering/metrics/telemetry-local.md` (`baseline-P1.md` intacto);
  `validate-meta` 58 OK (+3 checks), `docs/mcp/catalog.md` +1 línea; QA APTO
  (58 checks, render 61, pack 178 limpio, versiones 0.3.2, tests 7/0,
  redacción OK); reviewer APTO-CON-PENDIENTES (P2-1 `timeout` en header y
  P2-3 regex ampliada aplicados y re-verificados en verde; P2-2 duplicación
  `stripJsonc` queda como deuda documentada, sin refactor); decisiones:
  lockfile no aplica, placeholders `<...>` solo en real local, `steps`
  omitido sin fuente del cliente, conectividad no afirmada; capacidad parcial
  honesta en métricas (duración+exit reales, steps/tokenomics n/d sin fuente
  del cliente); sin commit/push, sin version bump, `AI/clients/` intacto.

- [x] R2.3 matriz compatibilidad OS×cliente (2026-11-03): canónica
  `docs/engineering/compatibility-matrix.md` (12 celdas: 1 VERIFIED + 11
  NOT VERIFIED, leyenda + alcance); Windows×OpenCode VERIFIED
  (install.ps1 -Dest temp/r23/win-opencode + Test-Path, validate-meta 55 OK,
  render --check 61 OK, check-docs OK, fixture R2.2 defecto HTTP 4/4 +
  QUnit 13/0 + OPA5 5/0 con cleanup puertos 4022/9222 libres, logs en
  temp/r23/logs/); `check-prereqs` exit 1 solo por `cf` ajeno en PATH
  (1.0.0-beta.25, no CF CLI v8; resto REQ OK); README 3 frases a lenguaje
  condicional + puntero a la matriz (línea 10, línea 151, § Compatibilidad:
  Git Bash≠Linux); QA APTO; sin commit/push, sin version bump,
  `AI/clients/` intacto.


- [x] R2.2 fixture QUnit+OPA5 con runner default VERDE (2026-11-03):
  fixture nueva `AI/specs/examples/app-ui5-qunit-opa/` (CAP+SQLite Books,
  UI5 freestyle OData V4 CDN 1.120.x, QUnit unit 13 asserts puros, OPA5
  journey CRUD carga→lista→crear→detalle→editar→eliminar, runners ps1/sh
  ensure→CAP→HTTP→QUnit→OPA5→cleanup finally/trap, helper
  `scripts/cdp-eval.js`); fixes R1+R2 (`cdp-chrome.ps1` Get-Listener excluye
  TimeWait+PID 0, `.npmignore` +2 `**/node_modules`, `package.json` files
  +2 negaciones, README 13 asserts, `run-ui5-tests.sh` comentario
  cdp-eval.js, fixture engines node>=22, `node_modules` borrado); QA2 APTO
  (HTTP 4/4 + QUnit 13/0 + OPA5 5/0, cleanup puertos libres,
  `validate-meta` 55 OK, `render` 61 OK, triple 0.3.2) + reviewer
  APTO-CON-PENDIENTES (solo P2, aplicados arriba); decisiones:
  `package-lock.json` fixture SE CONSERVA en repo y tgz (reproducibilidad,
  bloat menor asumido), `node_modules` nunca se versiona (gitignore) ni se
  distribuye (doble negación), CDN 1.120.x sin patch fijo (no congelar
  parches seguridad), paridad sh/ps1 vía cdp-eval.js (no dump-dom);
  sin commit/push, sin version bump, `AI/clients/` intacto.

- [x] T5.5-CLOSE E2E + paridad + OPP-014 (2026-11-03): E2E navegador real
  18/18 vía CDP (`ensure` operativo, pestaña propia, `cleanup` pendiente al
  cierre) — lista, crear→detalle, PATCH 7→12, DELETE→404, 404 directo con
  texto, filtro contains + 4 PNG en `temp/`; fixes solo-temp (CDN 1.120,
  contenedor ComponentSupport, App raíz mínima, 404 vía requestObject);
  paridad approuter exacta (ps1 fallback conteo→WARNING, caso normal
  PASS/PASS ambos, exit 0); OPP-014 COMPLETED (`node_modules/` en fragment,
  `install.ps1 -Dest temp/` lo fusiona); QUnit/OPA5 NO ejecutado (solo stub);
  BTP N-A (sin entorno real); `validate-meta` 54 OK, `render --check` 61 OK,
  triple 0.3.2, `npm test` 8/8, originales intactos, `temp/` ignorado;
  sin commit/push/release.

- [x] T5.5 Demo full-stack Books+UI5 + fix `Test-JsonValid`: auditoría
  T5.5-A + diseño T5.5-B (3 mejoras trazables) + demo `temp/t55-demo`
  T5.5-C (backend 8/8, EDMX `Books`, CRUD manual, UI freestyle) + QA
  T5.5-D (integración HTTP verde; E2E/BTP no ejecutados, no afirmados) +
  fix T5.5-E (`AI/scripts/validate-app.ps1` `Test-JsonValid`, 1 archivo,
  `validate-app` ps1 exit 0 en `app-local-demo` y `temp/t55-demo`) +
  reviewer APTO-CON-PENDIENTES (P1 approuter conteo, P2 `node_modules`→OPP-014,
  P3 trazabilidad 3 mejoras, P4 evidencia aportada, P5 duplicado opp:296+299
  colapsado); `validate-meta` 54 OK, `render --check` 61 OK, triple 0.3.2;
  `git status` solo `M AI/scripts/validate-app.ps1`, originales intactos,
  `temp/` ignorado, secret scan 0; OPP-018 COMPLETED; OPP-014 PROPOSED y
  OPP-006/008 VALIDATING intactos. Sync no requerida: solo `.md`
  backlog/improvements + 1 archivo producto ya validado (clase B/C);
  sin PEND-KNOWLEDGE (sin stale verificado); sin commits (2026-11-03).
- [x] T5 Application Engineering & Verification: auditoría A/B real
  (research T5-C + diseño T5-D reutilizando `/flow`+`/verify`+`qa-review`,
  sin agentes/comandos/skills nuevos) + `AI/scripts/validate-app.ps1/.sh`
  (OPP-011, condicional PASS/WARNING/FAIL/N-A/BLOCKED, 22 PASS + 1 BLOCKED
  en demo, paridad ps1/sh, FAIL→exit 1 con diagnóstico) + demo
  `AI/specs/examples/app-local-demo` (OPP-012, CAP+SQLite local, mta.yaml
  CF válido, `@(requires:'Viewer')`) + revisión SAP (tipos MTA corregidos)
  + QA APTO + reviewer APTO-CON-PENDIENTES; `render --check` 61 OK,
  `validate-meta` 54 OK, triple 0.3.2; OPP-013 PROPOSED (cds-dk);
  OPP-006/008 siguen VALIDATING (sin BTP real); sin commits (2026-11-03).
- [x] T5.1 Application Runtime Verification: demo CAP ejecuta de verdad
  (`npm install` 72 pkgs + lockfile; `cds compile` exit 0; `npm test`
  8/8: 401/CRUD 201/200/404/400/204 con SQLite `:memory:` y mocks
  reader/writer solo-[development]) + validate-app 9 escenarios A–J
  (paridad ps1/sh 9/9 tras fix BOM en `json_ok`, 0 mutaciones,
  limitación honesta: sintaxis CDS la captura `cds compile`)
  + OPP-005 aclarada (REJECTED era el duplicado, historial `da66d5c`)
  + OPP-013 COMPLETED; `cds test` nativo documentado no aplicable sin
  `@cap-js/cds-test`; sin commits (2026-11-03).
- [x] T5.2 E2E Generation ServiceDesk: NL→spec (analyst+documentarian,
  12 CAs) → diseño (architect: association, plan, UI5 diferido) →
  generación (backend-cap: 6 archivos+lockfile, compile 0) → 16/16 tests
  (qa-review APTO + gaps sap corregidos) → validate-app exit 0 con N-A
  correctos → Fase H real (defecto R5 inyectado 12/14, fix producto 1/3,
  R6-masking documentado) → independencia (%TEMP%, install+14/14+compile)
  → OPP-015 (nota SQLite en cap-cli + render) ; `render` 61 OK,
  `validate-meta` 54 OK, triple 0.3.2; sin commits (2026-11-03).

- [x] T5.3 Aislamiento fixtures + matriz terminales R6/R7:
  `AI/agents/backend-cap.md` (fixtures + fix paquete `@sap/cds` vía
  `cap-cli`) + `AI/agents/qa-review.md` (matriz terminales) +
  `AI/skills/cap-cli/SKILL.md` (TRANSITIONS) → OPP-016 COMPLETED;
  evidencia `temp/t52-servicedesk` test:119-150 + srv:78-90; QA
  APTO-CON-PENDIENTES (`npm test` t52 bloqueado entorno npx 90s,
  16 cancelados) + reviewer APTO-CON-PENDIENTES (fix paquete ya aplicado);
  `render --check` 61 OK, `validate-meta` 54 OK, triple 0.3.2; Tests
  pendiente entorno; sin commits (2026-11-03). Sync no requerida: solo
  `.md` producto, sin cambios estructurales (clase B); sin PEND-KNOWLEDGE.

- [x] T5.4 Orden-independencia + matriz condicional + WARNINGs aislamiento:
  `AI/agents/qa-review.md` (orden-independencia + matriz condicional) +
  `AI/skills/cap-cli/SKILL.md` (patrón suite aislada) +
  `AI/scripts/validate-app.ps1/.sh` (3 WARNING test-aislamiento) →
  OPP-017 COMPLETED; estática `validate-meta` 54 OK, `render --check` 61 OK,
  triple 0.3.2; runtime local QA multi-app Books 8/8 x2 + SD 16/16 x2 +
  matriz 6/6; randomize Books 7/8 y SD 8/16 por diseño (no regresión);
  reviewer APTO-CON-PENDIENTES (pendiente approuter sh paridad objeto vs
  conteo); E2E/BTP N-A; solo `.md` producto + validador solo-lectura,
  `AI/clients/` intacto; sin commits (2026-11-03).

- [x] T5.4-CLOSE Cierre deuda orden (solo-docs, sin tocar código):
  fixes sobre pendientes reviewer inicial — DEP0190 eliminado vía
  `cmd.exe shell:false`, approuter `.sh` por objeto, `check-prereqs -NeedUi5`
  + `cds` vía `npx`, subshell `sh` corregido, `backend-cap` alineado;
  copias `temp/t54c-books` 8/8 x4 + `temp/t54c-sd` 16/16 x4
  (2 normal + 2 randomize); `validate-meta` 54 OK, `render --check` 61 OK,
  triple 0.3.2; OPP-017 conserva COMPLETED (nota cierre añadida, sin nueva
  OPP); OPP-014 PROPOSED, OPP-006/008 VALIDATING, OPP-009 DEFERRED,
  OPP-015/016 COMPLETED intactos; `AI/clients/`, `temp/` y originales
  intactos; sin commits (2026-11-03).

- [x] T4-E/F/G conocimiento: OPP-006→VALIDATING (xs-security, APTO estático
  54/61/0.3.2, sin BTP real) + OPP-008 VALIDATING (approuter) + OPP-009
  DEFERRED (HANA) + OPP-010 REJECTED (OData→mejora `cap-cli`); mapa/catálogos
  intactos; sin reindex (2026-11-03).
- [x] T3.1 Operational Validation: B1–B3 + C1–C2 + D1–D6 en vivo
  (grafo 557/417 = HEAD 57d3bf2; CBM 770/813 ready; probes restaurados) +
  OPP-007 (1 párrafo §4 lifecycle) + reviewer APTO; `AI/` intacto,
  sin commits (2026-11-03).
- [x] T3 Autonomous Engineering: Flow D 10 etapas
  (`OBSERVE→…→SYNCHRONIZE`) + `docs/improvements/opportunities.md`
  (OPP-001…006, escenarios A–H verificados) + checks T3 en
  `validate-meta.js` (54 en verde) + delegación selectiva en orquestador;
  11 agentes (sin nuevos), `AI/` intacto (2026-11-03).

- [x] P0 auditoría + `docs/engineering/initial-assessment.md` (2026-11-03).
- [x] P1-P5 meta mínimo: orquestador + 10 especialistas, 5 flujos, contratos,
  catálogos, ADR-001, backlog (2026-11-03).
- [x] P1 gate CI `validate-meta.yml` + `publish` unificado (2026-11-03).
- [x] T-P2-04 Project Intelligence: `knowledge-map.md` + `impact-guide.md`
  (T0/T1/T2, escenarios A–E) + `metrics/baseline-P1.md` + checks
  mapa/governance en `validate-meta.js` + intelligence-pack en 3 flujos
  (2026-11-03).
- [x] T-P2-05 QA Project Intelligence: APTO, 0 falsos positivos,
  2×T0 + 1×T1 + 2×T2 verificados (2026-11-03).
- [x] T-P2-06 cierre P2: `testing-strategy.md` § P2 + `improvement-log.md` +
  ADR-002 (inteligencia por referencias) (2026-11-03).
- [x] Graphify local: `graphifyy[mcp]` 0.9.97 (uv, reutilizado), grafo
  `graphify-out/graph.json` 517 nodos / 381 aristas (100% EXTRACTED,
  commit = HEAD), MCP STDIO `graphify-local` (10 herramientas) a nivel
  usuario, escenarios A–F verificados CLI + MCP, estrategia
  `extract --code-only` + `update` bajo demanda; docs
  `docs/mcp/graphify-local.md` + catálogo + knowledge-map +
  system-overview + impact-guide + ADR-003; `AI/` intacto, npm limpio
  (2026-11-03).
- [x] Knowledge Lifecycle: ciclo retrieve → verify transversal
  (`docs/engineering/knowledge-lifecycle.md` canónico + punteros de 1 línea
  en 5 flujos y orquestador, sin flujo/agentes/aprobaciones nuevos);
  matriz Graphify vs Codebase Memory vs ninguno + anti-doble-consulta;
  detect A/B/C + exclusión; sync `graphify update` bajo demanda con puerta
  `check-update` y `detect_changes` para Codebase Memory; freshness 3 campos;
  checklist cierre §5 con fallo no bloqueante (`PEND-KNOWLEDGE`);
  escenarios A–H verificados (F/H: cero indexaciones con árbol limpio);
  `AI/` intacto (2026-11-03).
