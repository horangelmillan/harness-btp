# cf-safe — broker determinista para Cloud Foundry

Punto único de salida hacia `sap_cf`. Fail-closed: nada ejecuta sin pasar
denylist → allowlist → validación de target.

Fuentes: `scripts/cf-safe.ps1` (cabecera, líneas 1-34), `scripts/cf-safe-patterns.ps1`,
`scripts/cf-safe-client.ps1`, `scripts/pre-commit-check.ps1`;
integración: `doc-extract-lab/scripts/provision-prd.ps1` (líneas 46-50).
Estado QA citado según brief del turno (no re-ejecutado aquí por restricción
de no-ejecución de este turno de documentación): sintaxis 5/5, WhatIf/DENY 7/7,
redacción 24/24. Sin E2E real contra CF todavía (pendiente).

## Qué es

- `scripts/cf-safe.ps1`: broker. Recibe `-CfArgs`, valida, ejecuta solo
  `sap_cf` (`sap_cf.cmd`, ruta fija) y devuelve UNA línea JSON
  `{ok, exit, verb, redacted, rawLog, names, output}`.
- `scripts/cf-safe-patterns.ps1`: tabla central de redacción (6 regex +
  marcador `***REDACTED***`, fail-closed: ante error devuelve el marcador,
  nunca el original). Patrón de referencia: `doc-extract-lab/srv/lib/die-client.js`
  (`redactDieSecrets`).
- `scripts/cf-safe-client.ps1`: cliente para scripts de provisión
  (`Invoke-SapCfSeguro`; `New-TempServiceKey` es esqueleto BLOQUEADO,
  sin efecto en este turno).
- `scripts/pre-commit-check.ps1`: chequeo pre-commit, bloquea secretos fuera
  de `temp/` (whitelist: líneas con `***REDACTED***`).

## Por qué (sin LLM ejecutor)

Ningún agente/LLM invoca `sap_cf` directamente para lecturas con secreto
potencial: el broker aplica las reglas de forma determinista (código, no
criterio del modelo). El LLM solo recibe `output` ya redactado y truncado;
el crudo nunca llega a stdout ni a prompts.

## Uso

Lectura (sin flags):

```powershell
powershell -ExecutionPolicy Bypass -File scripts/cf-safe.ps1 -CfArgs @('services')
# Formas equivalentes (sin comas ni @() bajo -File):
powershell -ExecutionPolicy Bypass -File scripts/cf-safe.ps1 -CfArgs services
powershell -ExecutionPolicy Bypass -File scripts/cf-safe.ps1 services
```

Simulación sin ejecutar (omite validación de target):

```powershell
powershell -ExecutionPolicy Bypass -File scripts/cf-safe.ps1 -CfArgs @('services') -WhatIf
```

Desde un script de provisión (vía cliente, solo nombres, cero secretos):

```powershell
. (Join-Path $PSScriptRoot '..\..\scripts\cf-safe-client.ps1')
Invoke-SapCfSeguro -CfArgs @('services') -ExpectedApi 'https://api.cf.us10-001.hana.ondemand.com'
```

Regla: **toda lectura CF con secreto potencial vía cf-safe** (nunca
`sap_cf` directo en agentes/scripts cuando la salida pueda traer
credenciales: `env`, `service-key` con valores, `logs --recent`).

## Allowlist / denylist y códigos

Orden: 1) binario fijo (`cf` de Cloudflare se rechaza) → 2) denylist →
3) allowlist → 4) target → 5) ejecución.

- Denylist (exit 1): `delete-*`, `unbind-*`, `purge-*`, `restage-*`,
  `set-env` sin `-AllowWrite`, `create-service-key` directo,
  `service-key` con valores sin `-NeedValues` (y sin `-AllowWrite`),
  inyección (`|`, `>`, `;`, backtick, `$()`).
- Allowlist lectura (sin flags): `target`, `apps`, `app`, `services`,
  `service`, `marketplace`, `spaces`, `space-users`, `service-keys`
  (solo nombres), `env` (redactado), `logs --recent` (redactado,
  200 líneas), `plugins`.
- Allowlist escritura (SOLO con `-AllowWrite`): `create-space`,
  `create-service`, `set-space-role`, `target -o/-s`, `set-env`,
  `service-key` con valores (exige además `-NeedValues`).
- Códigos: `0` ok / `1` deny-denylist / `2` fuera-de-allowlist /
  `3` validación-target (endpoint/org no coinciden; `ExpectedOrg` vacío
  = no valida org) / `4` error-ejecución.

## Dónde van los crudos

- `output` (stdout JSON): redactado y truncado a 4000 caracteres.
- Crudo SOLO en `temp/cf-safe/*.raw.log`, nunca a stdout.
- `temp/` está ignorado (artefactos transitorios) y `pre-commit-check.ps1`
  ignora todo bajo `temp/`; fuera de `temp/`, cualquier señal de secreto
  sin `***REDACTED***` bloquea el commit (exit 1).

## Integración provision y /verify

- `doc-extract-lab/scripts/provision-prd.ps1` importa
  `scripts/cf-safe-client.ps1`: todas sus llamadas CF pasan por
  `Invoke-SapCfSeguro` (denylist primero). Allowlist del provision cerrada
  (ver `AGENTS.md` § Paisajes); `New-TempServiceKey` sigue esqueleto
  bloqueado hasta diseño final de keys temporales.
- `/verify`: el broker valida `ExpectedApi`
  (default `https://api.cf.us10-001.hana.ondemand.com`) y `ExpectedOrg`
  antes de ejecutar; con `-WhatIf` la validación se omite (solo simulación).

## Pendientes

- [ ] E2E real contra CF (veredicto con evidencia, sin secretos en repo).
- [ ] Instalación del hook pre-commit (`git config core.hooksPath .githooks`;
      copiar `pre-commit-check.ps1` a `.githooks/pre-commit`).
- [ ] Pasar PSScriptAnalyzer a los 4 scripts.
