---
name: btp-cli
description: Uso estándar del CLI de SAP BTP (btp)
---

# CLI SAP BTP (`btp`)

El CLI de SAP BTP se invoca como `btp`, resuelto por máquina: si
existe `$env:BTP_BIN` (mapeo local en `~/.harness/local.ps1` o
`$HOME/.harness/local.sh`, NO versionado) se usa ese binario; si no, `btp`.
Verificar una vez por sesión con `Get-Command` antes del primer comando BTP
del turno. Nunca transcribir el mapeo en `AGENTS.md` ni en la spec.

## Lectura segura (sin secretos)

```
btp --info                                            # versión, servidor, usuario y target
btp get accounts/global-account --global-account <SUBDOMAIN>
btp list accounts/subaccount --global-account <SUBDOMAIN>
btp get accounts/subaccount <ID>
btp list accounts/environment-instance --subaccount <ID>
btp list accounts/entitlement --subaccount <ID>
btp list services/offering --subaccount <ID>
btp list services/plan --subaccount <ID> --environment cloudfoundry
btp list services/instance --subaccount <ID>
btp list security/trust --subaccount <ID>
```

Todos verificados contra BTP CLI 2.116.3 en R3.0/R3.0.1; no asumir
otros flags (p. ej. no existe `--show-all`).

`--info`, `get` y `list` nunca muestran tokens. Si una salida incluyera un
secreto, redáctalo antes de citarla.

## Mutaciones (ninguna por defecto)

- Este skill es de solo lectura: no crea, modifica ni despliega nada en BTP.
- Cualquier cambio (target, entitlements, servicios) exige orden explícita
  del usuario y se ejecuta fuera de este skill, con evidencia observable.

## Operativa R3-C (verificada en CLI 2.116.3)

### Session-check: `btp --info` no prueba sesión

`btp --info` muestra config local pero NO prueba sesión. Verificar
con lectura real:

```
btp list accounts/subaccount --global-account <SUBDOMAIN>
```

Ante `Unknown session`, pedir re-login SSO interactivo al usuario;
nunca pedir ni registrar credenciales.

### Rol ≠ role collection

XSUAA crea roles, no role collections. Con orden explícita del
usuario y fuera de este skill (solo lectura: aquí NO se ejecuta nada,
solo se documenta la sintaxis para usarla en el turno con autorización):

```
btp create security/role-collection NAME --subaccount ID
btp add security/role NAME --to-role-collection RC --of-app <xsappname!tenant> --of-role-template T --subaccount ID
btp assign security/role-collection RC --to-user EMAIL --subaccount ID
```

`assign` existente devuelve OK = idempotente (no duplicar).

### Alcance aprobado

Agrupar operaciones concretas del plan y continuar sin re-preguntar
dentro del alcance. Ante acción externa nueva/más amplia, presentar
cambio de alcance. Re-login SSO y consentimiento siempre manuales.

## Denylist

- `create`, `update`, `delete`, `deploy` o cualquier verbo con efecto en BTP.
- Cambios de target o de entitlements sin orden explícita del usuario.
- Imprimir credenciales o tokens (nunca citar sus valores, solo nombres).
