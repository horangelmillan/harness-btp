#!/usr/bin/env node
// Telemetria minima local del harness (producto; node puro, sin fetch/http/red).
// Mide duracion y exit REALES de un comando envuelto; opt-in explicito.
// Uso:
//   HARNESS_TELEMETRY=1 node AI/scripts/log-telemetry.js
//     --phase <fase> --task <tarea> [--steps N --steps-source <fuente>] -- <cmd> [args...]
//   Sin HARNESS_TELEMETRY=1: passthrough (ejecuta igual, no escribe nada).
//   node AI/scripts/log-telemetry.js --help
// Salida con opt-in: una linea JSONL por ejecucion en
//   $HARNESS_TELEMETRY_FILE o <cwd>/temp/telemetry/telemetry.jsonl
//   {ts, phase, task, cmd, duration_ms, exit_code[, steps]}.
//   `steps` SOLO aparece con --steps N + --steps-source <fuente>; si no, se omite.
// Seguridad: si algun argv huele a clave (token|secret|passwd|pwd|password|
//   key=|authorization=) NO ejecuta: imprime TELEMETRY: [REDACTED] y aborta (exit 2).
// Cada escritura imprime: TELEMETRY: <ruta> <ms>ms exit=<code>.
const cp = require("child_process");
const fs = require("fs");
const path = require("path");

function help() {
  console.log([
    "Uso: HARNESS_TELEMETRY=1 node AI/scripts/log-telemetry.js --phase <f> --task <t>",
    "       [--steps N --steps-source <fuente>] -- <cmd> [args...]",
    "Sin opt-in: ejecuta el comando sin escribir nada (TELEMETRY: disabled).",
    "NO recoge: stdout/stderr del comando, variables de entorno, claves",
    "  (aborta ante ellas), usuario/host, red ni plataforma externa.",
    "  Solo: ts/phase/task/cmd/duracion_ms/exit_code (+steps con fuente).",
    "Limites: medicion local aproximada (ms); steps sin fuente se omite;",
    "  sin telemetria del cliente no hay metricas de coste ni de tokens.",
  ].join("\n"));
}
const argv = process.argv.slice(2);
if (argv.includes("--help") || argv.includes("-h")) { help(); process.exit(0); }

let phase = "n/d"; let task = "n/d";
let steps = null; let stepsSource = null;
let cmd = null;
for (let i = 0; i < argv.length; i++) {
  const a = argv[i];
  if (a === "--phase") { phase = argv[++i] || "n/d"; }
  else if (a === "--task") { task = argv[++i] || "n/d"; }
  else if (a === "--steps") { steps = argv[++i] || null; }
  else if (a === "--steps-source") { stepsSource = argv[++i] || null; }
  else if (a === "--") { cmd = argv.slice(i + 1); break; }
  else fail("ARG-NO-RECONOCIDO: " + a + " (ver --help)");
}
function fail(m) { console.log("TELEMETRY-ABORT: " + m); process.exit(2); }
if (!cmd || !cmd.length) fail("FALTA-COMANDO (uso: ... -- <cmd> [args])");
for (const t of cmd) {
  if (/token|secret|passwd|pwd|password|key=|authorization=/i.test(t)) {
    console.log("TELEMETRY: [REDACTED] (argv con posible clave; aborto sin ejecutar)");
    process.exit(2);
  }
}
if (steps !== null && stepsSource === null) { steps = null; }
let stepsN = null;
if (steps !== null && stepsSource !== null) {
  stepsN = Number(steps);
  if (!Number.isInteger(stepsN) || stepsN < 0) fail("--steps debe ser entero >= 0");
}

const optIn = process.env.HARNESS_TELEMETRY === "1";
if (!optIn) {
  console.log("TELEMETRY: disabled (opt-in con HARNESS_TELEMETRY=1)");
  const r = cp.spawnSync(cmd[0], cmd.slice(1), { stdio: "inherit", shell: false });
  process.exit(r.status === null || r.status === undefined ? 1 : r.status);
}

const t0 = Date.now();
const r = cp.spawnSync(cmd[0], cmd.slice(1), { stdio: "inherit", shell: false });
const ms = Date.now() - t0;
const exitCode = r.status === null || r.status === undefined ? 1 : r.status;
const rec = { ts: new Date().toISOString(), phase, task, cmd, duration_ms: ms, exit_code: exitCode };
if (stepsN !== null) rec.steps = stepsN;
const file = process.env.HARNESS_TELEMETRY_FILE ||
  path.join(process.cwd(), "temp", "telemetry", "telemetry.jsonl");
fs.mkdirSync(path.dirname(file), { recursive: true });
fs.appendFileSync(file, JSON.stringify(rec) + "\n", "utf8");
console.log("TELEMETRY: " + file + " " + ms + "ms exit=" + exitCode);
process.exit(exitCode);
