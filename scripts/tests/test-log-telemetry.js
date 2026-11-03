#!/usr/bin/env node
// Tests R2.4 (telemetria minima local): node --test, assert puro.
// T5 duracion real (>=250ms con sleep 300) + exit 0 y 3 reales.
// T6 sin opt-in no escribe + TELEMETRY impreso + redaccion de secreto (aborto)
//   + steps sin fuente se omite.
// Fixtures en temp/t24/ (borradas en after).
const { describe, it, after } = require("node:test");
const assert = require("assert");
const cp = require("child_process");
const fs = require("fs");
const path = require("path");
const ROOT = path.join(__dirname, "..", "..");
const T24 = path.join(ROOT, "temp", "t24", "tel");
const LOG = path.join(ROOT, "AI", "scripts", "log-telemetry.js");
const node = process.execPath;

function run(args, extraEnv) {
  try {
    const out = cp.execFileSync(node, args, { encoding: "utf8", env: { ...process.env, ...extraEnv } });
    return { status: 0, out };
  } catch (e) { return { status: e.status, out: (e.stdout || "") + (e.stderr || "") }; }
}
function lines(file) {
  return fs.readFileSync(file, "utf8").trim().split("\n").map((l) => JSON.parse(l));
}
after(() => { fs.rmSync(path.join(ROOT, "temp", "t24"), { recursive: true, force: true }); });

describe("log-telemetry", () => {
  it("T5: duracion real >=250ms (sleep 300) y exit 0 y 3 reales", () => {
    const file = path.join(T24, "t5.jsonl");
    fs.rmSync(file, { force: true });
    const env = { HARNESS_TELEMETRY: "1", HARNESS_TELEMETRY_FILE: file };
    let r = run([LOG, "--phase", "F1", "--task", "t5ok", "--", node, "-e", "setTimeout(()=>{},300)"], env);
    assert.strictEqual(r.status, 0, "exit 0 esperado:\n" + r.out);
    assert.match(r.out, /TELEMETRY: .* exit=0/, "linea TELEMETRY con exit=0");
    let recs = lines(file);
    assert.strictEqual(recs.length, 1, "una linea JSONL");
    assert.ok(recs[0].duration_ms >= 250, "duracion real >=250ms (fue " + recs[0].duration_ms + ")");
    assert.strictEqual(recs[0].exit_code, 0, "exit_code 0 real");
    assert.strictEqual(recs[0].phase, "F1", "phase registrada");
    assert.ok(!("steps" in recs[0]), "sin --steps no hay steps");
    r = run([LOG, "--phase", "F1", "--task", "t5fail", "--", node, "-e", "process.exit(3)"], env);
    assert.strictEqual(r.status, 3, "exit 3 del comando propaga:\n" + r.out);
    assert.match(r.out, /exit=3/, "linea TELEMETRY con exit=3");
    recs = lines(file);
    assert.strictEqual(recs.length, 2, "dos lineas JSONL");
    assert.strictEqual(recs[1].exit_code, 3, "exit_code 3 real");
  });
  it("T6: sin opt-in no escribe; secreto aborta; steps sin fuente se omite", () => {
    const file = path.join(T24, "t6.jsonl");
    fs.rmSync(file, { force: true });
    const env = { HARNESS_TELEMETRY_FILE: file };
    delete env.HARNESS_TELEMETRY;
    let r = run([LOG, "--phase", "F1", "--task", "t6off", "--", node, "-e", "console.log(1)"], env);
    assert.strictEqual(r.status, 0, "passthrough exit 0:\n" + r.out);
    assert.match(r.out, /TELEMETRY: disabled/, "TELEMETRY: disabled impreso");
    assert.ok(!fs.existsSync(file), "sin opt-in no escribe fichero");
    const marker = path.join(T24, "debionoejecutarse.txt");
    fs.rmSync(marker, { force: true });
    r = run([LOG, "--", node, "-e", "require('fs').writeFileSync(" + JSON.stringify(marker) + ",'x')", "--api-token=ghp_falso999"], env);
    assert.strictEqual(r.status, 2, "secreto aborta con exit 2:\n" + r.out);
    assert.match(r.out, /\[REDACTED\]/, "[REDACTED] impreso");
    assert.ok(!fs.existsSync(marker), "comando con secreto NO se ejecuta");
    const envOn = { HARNESS_TELEMETRY: "1", HARNESS_TELEMETRY_FILE: file };
    r = run([LOG, "--phase", "F1", "--task", "t6steps", "--steps", "5", "--", node, "-e", "1"], envOn);
    assert.strictEqual(r.status, 0, "exit 0:\n" + r.out);
    const recs = lines(file);
    assert.ok(!("steps" in recs[recs.length - 1]), "steps sin fuente se omite");
    r = run([LOG, "--phase", "F1", "--task", "t6steps2", "--steps", "5", "--steps-source", "manual", "--", node, "-e", "1"], envOn);
    assert.strictEqual(r.status, 0, "exit 0:\n" + r.out);
    const recs2 = lines(file);
    assert.strictEqual(recs2[recs2.length - 1].steps, 5, "steps con fuente se registra");
  });
  it("--help lista lo que NO recoge", () => {
    const r = run([LOG, "--help"]);
    assert.strictEqual(r.status, 0, "--help exit 0");
    assert.match(r.out, /NO recoge/, "--help declara lo no recogido");
  });
});
