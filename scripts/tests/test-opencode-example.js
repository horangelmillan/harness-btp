#!/usr/bin/env node
// Tests R2.4 (ejemplo opencode por fases): node --test, assert puro.
// T1 parse real, T2 fases reales, T3 fragmento + fixture rota (FRAGMENT-DIFIERE),
// T4 secreto en fixture falla + placeholders del real pasan.
// Fixtures en temp/t24/ (borradas en after).
const { describe, it, after } = require("node:test");
const assert = require("assert");
const cp = require("child_process");
const fs = require("fs");
const path = require("path");
const ROOT = path.join(__dirname, "..", "..");
const T24 = path.join(ROOT, "temp", "t24");
const CHECK = path.join(ROOT, "scripts", "check-opencode-example.js");
const EXAMPLE = path.join(ROOT, "AI", "opencode.jsonc.example");
const FRAGMENT = path.join(ROOT, "AI", "opencode.fragment.jsonc");
const node = process.execPath;

function run(args, extraEnv) {
  try {
    const out = cp.execFileSync(node, args, { encoding: "utf8", env: { ...process.env, ...extraEnv } });
    return { status: 0, out };
  } catch (e) { return { status: e.status, out: (e.stdout || "") + (e.stderr || "") }; }
}
function fx(name, exText, frText) {
  const dir = path.join(T24, name);
  fs.rmSync(dir, { recursive: true, force: true });
  fs.mkdirSync(dir, { recursive: true });
  const exP = path.join(dir, "example.jsonc");
  const frP = path.join(dir, "fragment.jsonc");
  fs.writeFileSync(exP, exText);
  fs.writeFileSync(frP, frText);
  return [exP, frP];
}
after(() => { fs.rmSync(T24, { recursive: true, force: true }); });

describe("opencode-example", () => {
  it("T1: ejemplo real parsea y valida (OK estructural)", () => {
    const r = run([CHECK]);
    assert.strictEqual(r.status, 0, "check debe salir 0:\n" + r.out);
    assert.match(r.out, /ESTRUCTURALMENTE VALIDO/, "mensaje OK esperado");
    assert.match(r.out, /no implica conectado/, "sin conectividad afirmada");
  });
  it("T2: los 6 MCP comentados tienen su FASE con entorno", () => {
    const raw = fs.readFileSync(EXAMPLE, "utf8").replace(/\r\n/g, "\n");
    const lines = raw.split("\n");
    for (const m of ["context7", "codebase-memory", "github", "playwright", "chrome-devtools", "eslint"]) {
      const idx = lines.findIndex((l) => l.trimStart().startsWith("//") && l.includes('"' + m + '"'));
      assert.ok(idx !== -1, m + " debe tener bloque comentado");
      const win = lines.slice(Math.max(0, idx - 12), idx + 1).join("\n");
      assert.match(win, /FASE/i, m + " debe mencionar FASE");
      assert.match(win, /entorno|environment/i, m + " debe declarar entorno");
    }
  });
  it("T3: fragmento C ejemplo real; fixture rota espera FRAGMENT-DIFIERE", () => {
    const rawEx = fs.readFileSync(EXAMPLE, "utf8");
    const rawFr = fs.readFileSync(FRAGMENT, "utf8");
    const rota = rawEx.replace('"enabled": false', '"enabled": true');
    assert.notStrictEqual(rota, rawEx, "fixture rota debe diferir");
    const [exP, frP] = fx("rota", rota, rawFr);
    const r = run([CHECK, exP, frP]);
    assert.notStrictEqual(r.status, 0, "fixture rota debe fallar");
    assert.match(r.out, /FRAGMENT-DIFIERE/, "causa FRAGMENT-DIFIERE esperada");
  });
  it("T4: secreto en fixture falla; placeholders del real pasan", () => {
    const rawEx = fs.readFileSync(EXAMPLE, "utf8");
    const rawFr = fs.readFileSync(FRAGMENT, "utf8");
    const mala = rawEx + "\n// NOTA ghp_falso12345\n";
    const [exP, frP] = fx("secreto", mala, rawFr);
    const r = run([CHECK, exP, frP]);
    assert.notStrictEqual(r.status, 0, "secreto debe fallar");
    assert.match(r.out, /SECRETO-POSIBLE/, "causa SECRETO-POSIBLE esperada");
    assert.match(rawEx, /<[A-Z-]+>/, "el real usa placeholders <...>");
    const ok = run([CHECK]);
    assert.strictEqual(ok.status, 0, "placeholders <...> no son secreto:\n" + ok.out);
  });
});
