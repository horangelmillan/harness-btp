# Checklist Destination + Approuter (OPP-008)

> Problema: consumir backends/SaaS desde BTP sin credenciales literales en
> repo ni destinos diseñados ad hoc por MVP.
> Diseño (T4-CD): checklist única + snippets `mta-approuter-snippet.yaml` y
> `xs-app.json`; modelo híbrido MTA+CLI de `AI/AGENTS.md` (managed vs
> existing-service, referencias por nombre).
> Dependencias: servicios `destination` + `xsuaa` (plan `application`) +
> `html5-apps-repo` (host/runtime); instancia XSUAA existente como
> `TokenServiceInstance` del destino (nunca una `it-rt` — ver no-go en
> `AI/AGENTS.md`).

## 1. `managed-service` vs `existing-service`

- En MTA (`mta.yaml`): `managed-service` para `xsuaa`, `destination`,
  `html5-apps-repo-host/runtime` (el deploy los crea/actualiza).
- `existing-service`: solo bindings a instancias pre-existentes (p. ej. DIE
  trial, `it-rt` integration-flow); se crean una vez por espacio vía
  `scripts/provision-<espacio>.ps1`, nunca en el MTA.
- Ejemplo: ver `AI/specs/examples/mta-approuter-snippet.yaml`.

## 2. Destino versionado (sin credenciales)

- Plan `destination:lite` es el default del snippet: válido para trial/dev
  con pocos destinos; `standard` solo si el paisaje lo exige (más destinos,
  alta disponibilidad) — verificar entitlements del espacio con `sap-verify`
  antes de cambiarlo, sin universalizar (trial ≠ productivo).
- `HTML5Runtime_enabled=true` solo en destinos de contenido HTML5; no
  copiarlo a destinos API/ OData genéricos.
- Nivel del destino: instancia (declarado en MTA, portable entre espacios)
  vs subcuenta (manual en cockpit, compartido); preferir instancia salvo que
  la spec exija reutilización cross-espacios.
- Destino por nombre con `TokenServiceInstanceName` (instancia XSUAA) y
  `TokenServiceKeyName` (key declarada por nombre, reutilizada del espacio).
- URL aún desconocida en paisaje nuevo → placeholder que no rompa el deploy,
  registrado como `TODO(<paisaje>)` en la spec; se fija tras conocerla.
- Lo que el deploy-service rechace (placeholders a keys anidadas
  `credentials.oauth`) no se reintenta: fallback = binding nativo
  (`existing-service`) o destino MANUAL en cockpit como pendiente conocido.
- On-prem solo si la spec lo pide: destino con `proxyType: OnPremise`
  (+ servicio `connectivity` ligado al approuter y Cloud Connector
  configurado en el paisaje); en trial sin connector no diseñar ruta
  on-prem (pendiente conocido, no placeholder).
- `Authentication`: `OAuth2ClientCredentials` (técnico) vs
  `OAuth2UserTokenExchange` (propaga usuario) vs `BasicAuthentication`
  (solo dev/trial, nunca productivo); `HTML5.ForwardAuthToken=true` solo si
  el backend valida el JWT de XSUAA. `DynamicDestination=true` solo para
  destinos resueltos en runtime (p. ej. multi-tenant); `csrfProtection`
  según exija el backend OData (fetch de token antes de POST/PUT/DELETE).

## 3. `xs-app.json` routes

- Ruta `/` → `html5-apps-repo-runtime`; rutas API (`/api/*`) → `destination`
  con `destination: <nombre-destino>` y `scope` si exige login.
- Ruta `/` → `html5-apps-repo-runtime` en managed-approuter (MTA con
  `html5-apps-repo-host/runtime`, el deploy sirve el HTML5); `localDir:
  resources/` del ejemplo `xs-app.json` es modo standalone (approuter sirve
  estáticos locales, sin HTML5 repo) — no mezclar: o una u otra según la
  spec, verificado por paisaje.
- Ejemplo mínimo: ver `AI/specs/examples/xs-app.json`.

## 4. Verificación

- Puerta `/verify`: `mbt mtad-gen -e <paisaje>.mtaext` + instancia/key
  esperadas existen (comando o cockpit, nunca heredadas de notas).
- Keys rotadas por deploy: el runtime NUNCA lee keys, solo binding/VCAP.

## Fuentes oficiales (verificadas 2026-11-02)

| Tema | URL oficial | Qué cubre |
|---|---|---|
| Destination service | https://help.sap.com/docs/btp/sap-business-technology-platform/destination-service | Destinos, `TokenServiceInstanceName/KeyName` |
| Application Router | https://help.sap.com/docs/btp/sap-business-technology-platform/application-router | `xs-app.json`, routes, scopes |
| MTA + Cloud Foundry deploy | https://help.sap.com/docs/btp/sap-business-technology-platform/multitarget-applications-in-cloud-foundry | `managed-service` vs `existing-service`, `.mtaext` por paisaje |
