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

## Denylist

- `create`, `update`, `delete`, `deploy` o cualquier verbo con efecto en BTP.
- Cambios de target o de entitlements sin orden explícita del usuario.
- Imprimir credenciales o tokens (nunca citar sus valores, solo nombres).
