# Harness MVP SAP BTP — Reglas del proyecto
> Nota portabilidad: verificado en Windows (PowerShell 5.1) y Git Bash; adapta rutas a tu equipo.

> Flujo reutilizable especificación → despliegue en SAP BTP Cloud Foundry,
> orquestado por tu cliente agéntico (verificado con OpenCode). Si tu cliente
> carga un `AGENTS.md` global, en caso de conflicto manda este archivo.

## Herramientas: nombres intocables

| Uso | Comando | Notas |
|---|---|---|
| Cloud Foundry | `cf` (`$env:CF_BIN` si está definido) | CLI estándar de Cloud Foundry (v8). |
| SAP BTP | `btp` (`$env:BTP_BIN` si está definido) | CLI de SAP BTP (solo lectura: `--info`/`get`/`list`; ver skill `btp-cli`). |
| MTA build | `mbt` | Cloud MTA Build Tool (binario recuperado vía su propio `install.js`). |

El mapeo máquina→binario NO se versiona: vive en `~/.harness/local.ps1` (Windows: `$env:CF_BIN="sap_cf.cmd"`) o `$HOME/.harness/local.sh` (Unix). El harness dice `cf`; el skill `cf-cli` resuelve: si existe `$env:CF_BIN` lo usa, si no `cf`, verificado con `Get-Command` una vez por sesión. Nunca transcribir el mapeo en `AGENTS.md` ni en la spec.

Ver skill local `cf-cli` antes del primer comando CF del turno;
ver `mta-build` antes del primer build MTAR.

## Destino Cloud Foundry conocido (sin secretos)

- Endpoint: el de tu paisaje (p. ej. `https://api.cf.<region>.hana.ondemand.com`;
  registrar el valor real en la spec del MVP, nunca aquí).
- Org y espacio objetivo (ver `cf target`;
  no se transcriben aquí por higiene). Antes de **cada despliegue**, el
  orquestador re-verifica endpoint/org/espacio contra la especificación del
  MVP. Si no coinciden o no pueden deducirse, se pide solo el dato
  indispensable y no se despliega.
- Despliegue MTA (`cf deploy *.mtar`) requiere el plugin **multiapps**.
  Antes de asumir su ausencia o instalarlo, verificar con `cf plugins`
  (lección: verificar siempre antes de asumir su ausencia).
  Instalarlo solo cuando un MVP lo requiera (ver `mta-build`).
- Placeholders MTA a credenciales: antes de diseñar un placeholder, verificar
  la forma real con una key temporal borrable (se documenta solo
  instancia/key, nunca el secreto; se borra tras extraer lo necesario). Si el
  deploy-service rechaza placeholders a keys anidadas (p. ej.
  `credentials.oauth`), no reintentar el mismo placeholder: fallback =
  binding nativo (`existing-service`) o destino MANUAL en cockpit registrado
  como pendiente conocido con su causa (cero secretos en repo).
- No-go conocido: una instancia `integration-flow`
  (`it-rt`) NO vale como `TokenServiceInstance` de un destino (`Invalid service
  name [it-rt]...`); no diseñar ni reintentar destino versionado con ella.

## Modelo híbrido MTA + CF CLI (regla irrestricta)

> El `.mta` hace lo suyo; los agentes hacen por CLI lo que el MTA no debe
> poseer. Objetivo: portar un MVP entre espacios/cuentas sin intervención
> humana salvo decisiones de coste/acceso.

| En MTA (`mta.yaml`) | Fuera del MTA (agentes por `cf`, una vez por espacio) |
|---|---|
| `managed-service`: xsuaa, destination, html5-repo-host/runtime, todo lo que el deploy puede crear/actualizar | `existing-service`: bindings a instancias pre-existentes (p. ej. DIE trial, `it-rt` integration-flow), espacios, roles `SpaceDeveloper`, entitlements/cuotas |
| Keys DECLARADAS por nombre (`service-key: name:`); el deploy reutiliza la key existente del espacio, nunca la crea con secretos | Creación idempotente de espacio/instancias/roles vía `scripts/provision-<espacio>.ps1` (ver § Paisajes); cero secretos en repo, solo nombres |
| Destinos versionados con referencias por nombre (`TokenServiceInstanceName/KeyName`, `~{srv-api/srv-url}`); ninguna credencial literal | Lo que el deploy-service rechace (p. ej. placeholders a keys anidadas `credentials.oauth`) NO se reintenta igual: fallback = binding nativo o destino MANUAL en cockpit registrado como pendiente conocido con su causa |

- El CLI de Cloud Foundry se invoca siempre como `cf`.
- Keys rotadas por deploy (el deploy-service puede borrar la
  `service-key` en cada deploy): el runtime NUNCA lee keys; solo binding/VCAP.
  Las keys son solo de diseño (temporal borrable, solo nombre documentado).
- Ante URL aún desconocida en paisaje nuevo (p. ej. URL del iFlow de prd antes de desplegarlo): desplegar con placeholder deja la destination inoperativa en runtime pero NO rompe el deploy; se registra como `TODO(<paisaje>)` y se fija tras conocerla.
- `scripts/cf-safe.ps1` es el punto de entrada para toda lectura CF con secreto potencial (ver `docs/cf-safe.md`).

## Paisajes .mtaext y pre-provisión idempotente

- Cada paisaje = un `<paisaje>.mtaext` en la raíz del MVP (`dev.mtaext`, `prd.mtaext`): `extends: <mta-id>`, overrides SOLO por paisaje (nombres de `existing-service`, `service-key`, URL del iFlow). `mta.yaml` guarda el default (= dev vivo). Cero secretos.
- Cadena de deploy: `cf target -s <paisaje>` → `cf deploy mta_archives/<mtar> -e <paisaje>.mtaext`. Sin `-e` no hay deploy multi-paisaje.
- Puerta `/verify` (etapa 7) exige en verde: `mbt mtad-gen -e <paisaje>.mtaext` por cada `.mtaext` afectado + target coincide con spec + instancia/key esperadas existen verificadas (comando o cockpit, nunca heredadas de notas).
- Persistencia efímera (p. ej. SQLite `:memory:` se vacía en cada redeploy/restart): la spec lo declara; el E2E resiembra tras cada deploy y ningún CA exige datos supervivientes salvo que la spec defina persistencia real.
- Pre-provisión: `scripts/provision-<espacio>.ps1` por paisaje no-dev, idempotente (cada paso comprueba y emite `SKIP:` si existe), NO despliega nada. Plantilla obligatoria: preflight de target (endpoint+org, aborta si no coinciden) → crea espacio si falta → guardia de marketplace (aborta antes de crear si falta un offering) → crea instancias solo si faltan → asigna rol solo si falta. Allowlist cerrada: `target, spaces, space-users, services, marketplace, create-space, create-service, set-space-role`. PROHIBIDO: `delete-*`, `unbind-*`, `purge-*`, `restage-*`. Usa `cf`.

## Flujo por etapas (`/flow <ruta-spec>`)

0. Evaluación de la especificación → 1. Investigación → 2. Plan →
3. Preparación → 4. Desarrollo → 5. Pruebas → 6. Correcciones →
7. Revisión de despliegue (`/verify`) → 8. Despliegue →
9. Git → 10. Documentación (+ cosecha de lecciones: `harness-evolution`
   propone, el orquestador aplica tras revisión).

- En etapa 0, si la spec exige builds o despliegues, el orquestador pide al usuario el resultado de `AI/scripts/check-prereqs.ps1` (o `.sh`) antes de planificar.
- En etapa 0 el orquestador copia `AI/VERSION` a la spec (`**Harness BTP:** vX.Y.Z`); si hace upgrade a mitad del MVP, añade línea `Upgrade harness vA → vB (<fecha>)`.
- Cada etapa tiene entregable verificable; el orquestador define el criterio
  de avance en el plan y lo exige antes de continuar.
- Rigor proporcional al MVP: saltar etapas irrelevantes está permitido y se
  registra; ejecutar builds/despliegues innecesarios, no.
- **Despliegue continuo en MVPs ya desplegados (ciclo
  desplegar→probar→corregir, sin detenerse):** cuando se cumplan TODAS estas
  condiciones, el orquestador NO se detiene en la etapa 7 a pedir orden de
  despliegue, sino que encadena puerta (`/verify`) → despliegue
  (`deploy-cf`) → E2E (`e2e-fiori`) → correcciones, con un máximo de 3
  vueltas y presupuesto explícito por vuelta:
  1. El MVP tiene al menos un despliegue anterior con éxito al MISMO
     endpoint/org/espacio, registrado en la spec;
  2. `cf target` re-verificado coincide con la spec;
  3. El cambio no puede verificarse por completo en local (integraciones
     que solo existen en SAP: DIE, iFlow, XSUAA, HTML5 Repo…) o el usuario
     ordenó el despliegue.
  Si las 3 se cumplen, desplegar es parte del alcance implícito: pararse
  deja la mejora sin probar. El bucle termina en la
  primera vuelta con E2E en verde; si se agotan las 3 vueltas o el
  presupuesto, se entrega lo conseguido con evidencia y pendientes.
  **El bucle se detiene igual y se pide decisión al usuario si:** el target
  no coincide con la spec, la sesión CF caducó y exige re-login, aparece
  coste/cuota fuera de trial/gratuito, el destino es productivo (no
  trial/dev), o el usuario ordena parar. Primeros despliegues (sin
  antecedente en la spec) siguen exigiendo confirmación explícita del
  destino antes de la etapa 8.
- **Portar a otro espacio/cuenta (flujo estándar, sin humanos en el camino):**
  `preflight` (target+spec+entitlements/`sap-verify` del plan en el espacio
  nuevo) → `provision-<espacio>.ps1` (solo con orden explícita o antecedente
  de deploy con éxito al mismo endpoint/org registrado en la spec) →
  `/verify` (con `mtad-gen -e` del paisaje) → `deploy-cf`
  (`-e <paisaje>.mtaext`) → `e2e-fiori`. Presupuesto: máx 15 min provision,
  máx 3 vueltas deploy→e2e→fix como el bucle continuo. Parada con decisión
  al usuario si: target no coincide, sesión exige re-login, falta
  offering/entitlement, coste fuera de trial/gratuito, destino productivo, o
  placeholder `TODO(<paisaje>)` bloquea el CA (se entrega con pendiente, no
  se inventa la URL).
- **Autoridad con efecto:** `deploy-cf` sigue siendo el ÚNICO agente con
  efecto deploy. `provision-<espacio>.ps1` también tiene efecto (crea
  espacio/instancias/roles) y exige orden explícita del usuario O antecedente
  de deploy con éxito al mismo endpoint/org registrado en la spec; sin una de
  las dos, el orquestador solo lo propone, no lo ejecuta. Todo `provision`
  deja evidencia (salida `SKIP:`/`CREATE:`) y registra instancias/keys creadas
  solo por nombre en la spec.
- Paralelo solo en tareas realmente independientes; el orquestador integra y
  revisa todo. No delega decisiones finales ni acepta cambios sin inspección.
- Éxito solo con evidencia observable (salida de comandos, app en estado
  `started`, artefacto MTAR existente). Nunca declarar éxito por haber
  lanzado un comando.
- Nunca imprimir tokens, contraseñas ni secretos en terminal, informes, logs
  o prompts a subagentes. Autenticación por mecanismo interactivo/seguro.

## Local frente a BAS

Este harness corre en tu máquina local (verificado en Windows + Git Bash). No presuponer que una instalación local
(`cf`, `mbt`, Node, Java, Python) existe en un dev space
remoto de BAS, ni viceversa. `cds` y `ui5` CLIs no están instalados
globalmente: se instalan por proyecto cuando la especificación los exija.

## Presupuesto anti-bloqueo (obligatorio para orquestador y subagentes)

Ninguna tarea puede consumir tiempo ilimitado. Reglas:

- Toda delegación con `subagent` incluye **presupuesto explícito** (minutos
  o nº de acciones) proporcional a la tarea; p. ej. una validación en
  navegador: 15 min.
- **Prohibido reintentar en bucle**: si la misma acción falla 3 veces, se
  para y se reporta como bloqueo de entorno con evidencia, no se insiste.
- Al agotar el presupuesto: **entrega parcial + cierre limpio** (matar solo
  procesos propios por PID, borrar perfiles temporales). El orquestador
  sigue con la evidencia parcial; nunca se deja una sesión "trabajando" sin
  entregable.
- El orquestador que detecte una sesión atascada le envía UNA orden de
  entrega inmediata; si no responde, cierra sus recursos externos por PID y
  continúa sin ella, registrando el incidente.

## Disciplina de shell y CLIs (lecciones 2026-10-29)

PowerShell 5.1, no bash. Prohibidos `ver`, `head`, `tail`, `where <args>`,
`grep` como comando: usar `Get-Command`, `Select-Object -First/-Last`,
`Select-String`. Todo comando con sintaxis nueva se prueba aislado antes de
encadenarlo en pipes.

- `cds` CLI: solo vía `npx -p @sap/cds-dk cds ...` (el paquete del proyecto
  no trae el CLI). Ver skill `cap-cli`. Nunca adivinar nombres de paquetes
  npm: verificar con `context7` o `npm view` antes de `npx`/`npm i`.
- Reparación de `mbt` verificada: `node install.js cloud-mta-build-tool`
  en el directorio del paquete (no `mbt` a secas). Ver skill `mta-build`.
  `mbt` exige además `make` en `%PATH%` (si falla `exec: "make": executable
  file not found`, anteponer un `bin` con `make` al `$env:PATH` solo para
  el comando; no persiste entre sesiones).
- Nunca `npm audit fix --force` sin revisión: reportar vulnerabilidades a
  `qa-review`.
- Artefactos transitorios (regla de entorno): todo lo que
  un agente genere y sirva solo temporalmente (capturas de pruebas, builds,
  dumps de consola/red, perfiles CDP) va en `temp/<tarea>/`, nunca en la raíz
  ni dentro del repo del MVP (`temp/` está ignorado). El orquestador incluye
  la ruta `temp/<tarea>/` en cada delegación que implique tests, builds o
  navegador; la evidencia que deba conservarse se mueve a `evidencia/` con su
  referencia en docs. Al cerrar la tarea se borra lo transitorio.
- El target CF puede cambiar entre sesiones: re-verificar `cf target`
  en cada puerta y registrar el cambio en la spec antes de desplegar.
- Higiene de navegador y CDP (regla irrestricta, ver § Higiene obligatoria de
  navegador y CDP): matar procesos solo por PID con filtro de perfil temporal
  propio (`CommandLine -like '*<perfil>*'`); prohibido `Stop-Process -Name chrome`
  o kills por nombre. Los subagentes llevan time-box explícito y, si lo superan,
  se cierra su navegador y se sigue con su evidencia parcial.
- Índices de conocimiento: `codebase-memory` local antes que lectura amplia;
  `graphify-code` local tras cambios commiteados si está `connected`. Sin
  reindexación redundante en ambos en el mismo turno.

## Higiene obligatoria de navegador y CDP (regla irrestricta)

Toda tarea que use navegador (`playwright` o `chrome-devtools`, en pruebas o
implementación) cumple este protocolo sin excepciones. Fuente única: esta
sección + `AI/scripts/cdp-chrome.ps1` (en el MVP instalado puede estar copiado como `scripts/cdp-chrome.ps1`; vale cualquiera — resolver con `Test-Path` ambas). Causa raíz conocida: el MCP
`playwright` está configurado con `--cdp-endpoint http://localhost:9222` y
**solo se conecta, no lanza navegador**; nadie levantaba el host CDP, de ahí
el `ECONNREFUSED`. `chrome-devtools` usa canal propio y no necesita `:9222`.

1. **Antes (verificación previa):** comprobar el puerto con
   `AI/scripts/cdp-chrome.ps1 status`. Para `playwright`, ejecutar `ensure`:
   reutiliza el endpoint si responde; si el puerto lo ocupa un proceso
   ajeno, **detenerse, no matarlo**, e informar; si está libre, lanza Chrome
   headless propio con perfil temporal y verifica `/json/version` con
   reintentos (máx 3: 1 s/2 s/4 s). Sin endpoint verificado no hay prueba
   con navegador que dar por hecha: reportarlo y seguir con el resto.
2. **Durante:** trabajar headless por defecto (sin ventana salvo petición
   explícita). No abrir navegadores fuera del protocolo.
   **Excepción — E2E con login de usuario:** si la app exige autenticación
   interactiva (XSUAA/IdP) que solo el usuario puede completar, `e2e-fiori`
   se invoca igual con navegador VISIBLE (`headed`, perfil temporal propio)
   para que el usuario se autentique en su ventana y luego continúa; espera
   acotada al login manual (máximo definido en la delegación, sin reintentos
   en bucle) y el agente nunca pide ni registra credenciales. El orquestador
   avisa al usuario ANTES de abrir el navegador (2026-10-31: avisar tarde
   = 5 min perdidos). Ante muro de
   login, `e2e-fiori` deja veredicto formal `BLOQUEADO`-con-evidencia
   (captura + URL + punto alcanzado) salvo orden contraria del usuario;
   nunca se omite en silencio.
3. **Después (limpieza):** al terminar la sesión de navegador o la tarea,
   ejecutar `AI/scripts/cdp-chrome.ps1 cleanup` (mata **solo** procesos propios
   verificados por PID + perfil, borra el perfil temporal) y, con
   `chrome-devtools`, cerrar las páginas abiertas. Verificar puerto libre.
   Sin limpieza verificada no se cierra la tarea.
4. **Evidencia:** el cierre informa salida de `ensure`/`cleanup` (o de
   `status` si no se usó navegador) + qué quedó pendiente.
   Esperas solo por evento observable con timeout explícito (patrón
   `e2e-fiori` § Espera por evento; cero waits ciegos).

## MCP y skills: selección por fase

- `context7` (`resolve-library-id` → `query-docs`): docs de CAP, UI5, CF CLI,
  MTA y cualquier librería antes de suponer APIs. Lo usan `researcher` y los
  especialistas. En etapa 1 el `researcher` re-verifica con `AI/scripts/check-docs` las fuentes de `AI/docs/fuentes-oficiales.md` que la spec vaya a usar y registra la fecha. Ante un error de servicio con código (p. ej. EP003) o un
  payload dudoso, contrastar el payload contra el tutorial oficial vigente +
  el error real antes de asumir; las docs viejas o el scaffold no mandan.
- `codebase-memory`: contexto del índice cuando el MVP viva en un proyecto
  indexado (`index_status`/`detect_changes` para frescura al arrancar;
  `index_repository` tras cambios si hay novedades); nada que asumir si
  puede recuperarse del grafo. `graphify-code` local como complemento
  cuando esté `connected` (ver fragmento `opencode.fragment.jsonc`, opcional); índice local por defecto,
  sin reindexar redundante en ambos en el mismo turno.
- `github`: solo si la especificación pide repo remoto/PR. Sin spec que lo
  pida, trabajo local.
- `eslint`: calidad estática en código JS/TS del MVP.
- `playwright` / `chrome-devtools`: validación en navegador de UIs Fiori
  cuando el MVP la incluya; `playwright` exige host CDP externo
  (`AI/scripts/cdp-chrome.ps1 ensure` antes, `cleanup` después; nunca dar UI
  por hecha solo porque compila ni sin endpoint verificado).
- Skills globales en su fase, sin cargar todas: `sapui5` con `frontend-ui5` (en diálogos con JSON/trazabilidad, aplicar AI/docs/ui5-dialog-checklist.md);
  `systematic-debugging` ante fallos; `verification-before-completion` con
  `qa-review`; `test-driven-development` si la spec exige TDD; `git-workflow`
  con Git. Skills externas SAP (ver `INICIO.md § Skills candidatas`) solo se
  adoptan si la spec las necesita, tras inspección previa.

## Git

- Regla permanente: **ningún secreto en Git** (credenciales, tokens,
  `.env`, `default-services` con claves, archivos de auth). Revisar diff y
  estado de ignorados antes de cualquier operación Git.
- No inicializar repo ni conectar remotos salvo que la especificación lo pida.
- Commits locales solo cuando correspondan al proyecto. Nunca `push`,
  publicar repos ni abrir PR salvo petición expresa de la especificación o
  del usuario.
- Si el repo del MVP tiene CI con workflows: ningún merge a `main` se da por
  hecho sin CI en verde verificado en terminal (`gh pr checks <n> --watch`).

## Frontera harness/proyecto: lo generado no se versiona (regla irrestricta)

- **Prohibidos los backups dentro del proyecto:** nunca `cp -r AI AI.bak*`
  ni `*.bak`/`*.orig` bajo la raíz del MVP. Backup válido = fuera del repo
  (`%TEMP%/harness-bak/<yyyy-MM-dd>/` en Windows, `$HOME/.harness/bak/`
  en Unix) o vía git (`stash`/`commit`). Motivo: `AI.bak/` y
  `AI.bak-v1.0/` acabaron versionados en doc-extract-lab.
- **Lo que genera el harness/cliente es local:** `opencode.jsonc` real,
  `.opencode/`, `AI/.opencode/`, cachés y transitorios. El base versiona
  solo la plantilla (`AI/opencode.fragment.jsonc` + `AI/opencode.jsonc.example`);
  el real se genera al instalar y está ignorado.
- **Qué SÍ / qué NUNCA / qué vive en el base:**

  | SÍ se versiona en el MVP | NUNCA se versiona en el MVP | Vive solo en el base (`AI/`) |
  |---|---|---|
  | Producto (`app/`, `srv/`, `db/`, `mta.yaml`, `package.json`) | Backups (`AI.bak/`, `AI*.bak/`, `*.bak/`, `*.orig/`) | Agentes (`AI/agents/`, `AI/.opencode/agents/`) |
  | Specs (`AI/specs/<mvp>.md`, con versión del harness) | Cachés de cliente (`.opencode/`, `AI/.opencode/`, `opencode.jsonc` real) | Skills (`AI/skills/`, `AI/.opencode/skills/`) |
  | Paisajes (`dev.mtaext`, `prd.mtaext`), manifiestos, `xs-security.json` | Transitorios (`temp/`, `evidencia/`, `.playwright-mcp/`, `graphify-out/`) | Scripts y docs del harness (`AI/scripts/`, `AI/docs/`, `AI/commands/`, `AI/clients/`) |
  | `.gitignore` del MVP (con el bloque del fragmento aplicado) | Build/deploy (`mta_archives/`, `*.mtar`) y secretos (`.env*`, `default-services.json` con claves) | Plantillas (`AI/opencode.fragment.jsonc`, `AI/opencode.jsonc.example`, `AI/.gitignore.fragment`, `AI/VERSION`) |
