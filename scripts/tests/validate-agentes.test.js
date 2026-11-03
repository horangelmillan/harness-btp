#!/usr/bin/env node
// Tests T4.1-FIX: auditoría de agentes meta con fixtures aisladas en temp/t41.
// Sin dependencias (node assert puro). El repo real solo lo valida validate-meta.js.
// Uso: node scripts/tests/validate-agentes.test.js
const assert = require("assert");
const fs = require("fs");
const path = require("path");
const ROOT = path.join(__dirname, "..", "..");
const WANT = ["engineering-orchestrator", "harness-researcher", "harness-architect",
  "harness-implementer", "harness-qa", "sap-btp-specialist", "security-engineer",
  "documentation-engineer", "mcp-skills-engineer", "performance-engineer", "reviewer"];

// Réplica exacta del algoritmo de scripts/validate-meta.js (bloque agentes),
// operando sobre un directorio fixture + set tracked simulado (o null = sin git).
function auditFiles(files, tracked) {
  const fail = []; const okMsg = [];
  const want = new Set(WANT.map((a) => a.toLowerCase()));
  const seen = new Set(); const dups = new Set();
  for (const f of files) {
    const k = f.toLowerCase();
    if (seen.has(k)) dups.add(f); else seen.add(k);
  }
  for (const d of dups) fail.push("AGENTE-DUPLICADO: " + d);
  const onDisk = new Set(files.map((f) => f.toLowerCase()));
  for (const a of WANT)
    if (!onDisk.has((a + ".md").toLowerCase())) fail.push("AGENTE-CANONICO-FALTA: " + a);
  if (tracked === null) {
    okMsg.push("OK: 11 agentes meta (SIN-GIT: extras no auditables)");
  } else {
    for (const f of files)
      if (!want.has(f.toLowerCase().replace(/\.md$/, "")) && tracked.has(f.toLowerCase()))
        fail.push("AGENTE-NO-REGISTRADO: " + f);
    if (!dups.size && !fail.some((m) => /^AGENTE-/.test(m)))
      okMsg.push("OK: 11 agentes meta (ignorados locales exentos)");
  }
  return { fail, okMsg };
}
function audit(dir, tracked) {
  return auditFiles(fs.readdirSync(dir).filter((f) => f.endsWith(".md")), tracked);
}

function fixture(name, files) {
  const dir = path.join(ROOT, "temp", "t41", name, ".opencode", "agents");
  fs.rmSync(path.join(ROOT, "temp", "t41", name), { recursive: true, force: true });
  fs.mkdirSync(dir, { recursive: true });
  for (const f of files) fs.writeFileSync(path.join(dir, f), "---\nname: x\ndescription: y\n---\n");
  return dir;
}
const canon = WANT.map((a) => a + ".md");
const canonTracked = new Set(canon.map((f) => f.toLowerCase()));

// A: 11 canónicos PASS
let dir = fixture("caso-a", canon);
let r = audit(dir, canonTracked);
assert.deepStrictEqual(r.fail, [], "A debe pasar sin fallos");
assert.ok(r.okMsg.some((m) => m.includes("(ignorados locales exentos)")), "A mensaje exentos");
console.log("OK A: 11 canonicos PASS");

// B: +ignorados no-versionados PASS (extras en disco, no en tracked)
dir = fixture("caso-b", canon.concat(["analyst.md", "orchestrator.md"]));
r = audit(dir, canonTracked);
assert.deepStrictEqual(r.fail, [], "B extras no-versionados no deben fallar");
assert.ok(r.okMsg.some((m) => m.includes("(ignorados locales exentos)")), "B mensaje exentos");
console.log("OK B: +ignorados no-versionados PASS");

// C: falta canónico FAIL
dir = fixture("caso-c", canon.filter((f) => f !== "reviewer.md"));
r = audit(dir, new Set(canonTracked).delete("reviewer.md") && new Set([...canonTracked].filter((x) => x !== "reviewer.md")));
assert.ok(r.fail.some((m) => m === "AGENTE-CANONICO-FALTA: reviewer"), "C debe marcar AGENTE-CANONICO-FALTA");
console.log("OK C: falta canonico FAIL");

// D: añadido versionado no registrado FAIL
dir = fixture("caso-d", canon.concat(["nuevo-local.md"]));
r = audit(dir, new Set([...canonTracked, "nuevo-local.md"]));
assert.ok(r.fail.some((m) => m === "AGENTE-NO-REGISTRADO: nuevo-local.md"), "D debe marcar AGENTE-NO-REGISTRADO");
console.log("OK D: versionado no registrado FAIL");

// E: sin git comportamiento explícito
dir = fixture("caso-e", canon.concat(["analyst.md"]));
r = audit(dir, null);
assert.ok(r.okMsg.some((m) => m.includes("SIN-GIT")), "E debe declarar SIN-GIT explícito");
assert.ok(!r.fail.some((m) => /^AGENTE-NO-REGISTRADO/.test(m)), "E no audita extras sin git");
console.log("OK E: sin git comportamiento explicito");

// Duplicado case-insensitive (cobertura extra del mismo bloque).
// Nota: en FS case-insensitive (Windows) no pueden coexistir Reviewer.md y
// reviewer.md en disco; se inyecta la lista directamente sin pasar por fs.
r = auditFiles(canon.concat(["Reviewer.md"]), canonTracked);
assert.ok(r.fail.some((m) => m.startsWith("AGENTE-DUPLICADO")), "duplicado case-insensitive debe fallar");
console.log("OK F: duplicado case-insensitive FAIL");

console.log("OK: validate-agentes 5+1 casos en verde (fixtures temp/t41)");
