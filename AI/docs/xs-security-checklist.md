# Checklist XSUAA / IAS (OPP-006)

> Problema: MVPs con backend CAP o approuter necesitan autenticación y
> autorización (roles/scopes) sin copiar secretos ni diseñar seguridad ad hoc.
> Diseño (T4-CD): checklist única + `xs-security.json` mínimo de ejemplo;
> validación de scopes delegada a skill existente `sap-verify` (sin skill nueva).
> Dependencias: servicio `xsuaa` (plan `application`), trust opcional a IAS
> para usuarios corporativos; `sap-verify` para clasificar disponibilidad/coste.

## 1. Roles y scopes

- Definir 1–2 roles funcionales del MVP (p. ej. `Viewer`, `Editor`); cada rol
  = 1 scope `$XSAPPNAME.<Rol>` en `xs-security.json → scopes`.
- Asignar scopes a roles vía `role-templates` (`name`, `scope-references`).
- Todo endpoint protegido exige scope; por defecto denegar (handler CAP con
  `@(requires: '<scope>')` o ruta approuter con `scope`).

## 2. `xs-security.json` mínimo

- Solo estructura: `xsappname`, `scopes`, `role-templates`; ver ejemplo en
  `AI/specs/examples/xs-security.json`. Cero secretos (sin `clientid`,
  `clientsecret`, `url`, `uaadomain` — los inyecta el binding/VCAP).
- `xsappname` único por paisaje si hay multi-paisaje (`<app>-<paisaje>`).

## 3. IAS trust (solo si el MVP lo pide)

- Por defecto XSUAA local basta; IAS solo con usuarios corporativos reales.
- Trust = configuración en cockpit/BTP (no versionable); registrar en la spec
  como `Pendiente en cuenta` (`sap-verify`) hasta verificarlo en la subcuenta.

## 4. Verificación

- `sap-verify`: validar que cada scope usado en código/rutas existe en el
  checklist/`xs-security.json` antes de desplegar.
- Nunca afirmar login OK sin E2E con usuario real o mock documentado.

## Fuentes oficiales (verificadas 2026-11-02)

| Tema | URL oficial | Qué cubre |
|---|---|---|
| XSUAA service + `xs-security.json` | https://help.sap.com/docs/btp/sap-business-technology-platform/authorization-and-trust-management-service | Estructura `xs-security.json`, scopes, role-templates |
| IAS trust / IdP | https://help.sap.com/docs/identity-authentication | Trust XSUAA↔IAS, usuarios corporativos |
| CAP auth (`@(requires:)`) | https://cap.cloud.sap/docs/node.js/authentication | Proteger servicios CAP por scope/rol |
