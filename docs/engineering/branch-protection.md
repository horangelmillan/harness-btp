---
title: Protección de rama main
date: 2026-11-03
status: vigente
---

# Branch protection — `main`

El job requerido es `validate` (workflow `Validate meta`,
`.github/workflows/validate-meta.yml`, runner `ubuntu-latest`,
`node scripts/validate-meta.js`).

## Estado

- Código listo: el workflow define el job `validate` con nombre estable,
  actions fijadas por SHA (`checkout`, `setup-node`) y permiso mínimo
  (`contents: read`).
- Configuración remota: **pendiente** (requiere permiso de administración en
  GitHub; no se puede aplicar desde el repo ni simular en CI).

## Activación manual (una vez, con admin)

1. GitHub → Settings → Branches → Add rule → `main`.
2. Require status checks → buscar `validate` (ejecutar el workflow una vez
   en `main` para que aparezca) → marcar como required.
3. Require branches to be up to date before merging (recomendado).
4. No exigir aprobaciones manuales rutinarias (R1: autonomía sin fricción).

## Verificación

`gh api repos/{owner}/{repo}/branches/main/protection --jq .required_status_checks`
debe listar `validate`. Sin admin, este paso queda como pendiente conocido.
