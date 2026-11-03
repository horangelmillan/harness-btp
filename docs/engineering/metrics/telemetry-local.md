---
title: Telemetría mínima local (sin plataforma)
date: 2026-11-03
status: parcial
---

# Telemetría mínima local — formato, garantías, limitaciones

> Sin plataforma de observabilidad (decisión R2.4): wrapper opt-in
> `AI/scripts/log-telemetry.js` (node puro, sin fetch/http/red).
> Relación con `docs/engineering/metrics/baseline-P1.md`: lo complementa
> (tiempos reales desde R2.4 donde se use); NO lo modifica.

## Formato (una línea JSONL por ejecución)

`{ts, phase, task, cmd, duration_ms, exit_code[, steps]}` en
`$HARNESS_TELEMETRY_FILE` o `<cwd>/temp/telemetry/telemetry.jsonl`.
`steps` SOLO con `--steps N` + `--steps-source <fuente>`; si no, se omite.

## Garantías

- Opt-in explícito (`HARNESS_TELEMETRY=1`); sin él, passthrough sin escribir.
- `duration_ms`/`exit_code` reales del proceso envuelto (hereda stdio).
- Aborto sin ejecutar (exit 2, `[REDACTED]`) si un argv huele a clave.
- Sin red, sin dependencias, sin secretos en repo (placeholders `<...>`).

## Limitaciones

- Granularidad ms, aproximada; no mide tokens, coste MCP ni llamadas.
- `steps` es declarado por quien invoca (con fuente obligatoria), no observado.
- `temp/` es transitorio (ignorado); la evidencia que se conserve va a
  `evidencia/` con su referencia.
