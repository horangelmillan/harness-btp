#!/usr/bin/env node
// Mecanismo único de versionado (R1.2): sincroniza package.json, VERSION y AI/VERSION.
// Uso: node scripts/bump-version.js <X.Y.Z> [--check]
//   <X.Y.Z>: semver a establecer en los 3 archivos (no se ejecuta en R1; 0.4.0 solo al cierre).
//   --check: no escribe; exit 0 si la triple coincide, exit 1 si difiere.
//   En modo escritura aborta (§6.6) si la triple previa discrepa, sin escribir nada.
// Sin dependencias (solo fs/path/child_process). No toca AI/clients/.
const fs = require("fs");
const path = require("path");
const cp = require("child_process");
const ROOT = path.join(__dirname, "..");
const want = process.argv[2];
const checkOnly = process.argv.includes("--check");

function firstLine(p) {
  return fs.readFileSync(p, "utf8").split(/\r?\n/)[0].trim();
}
function triple() {
  const p = JSON.parse(fs.readFileSync(path.join(ROOT, "package.json"), "utf8")).version.trim();
  const v = firstLine(path.join(ROOT, "VERSION"));
  const a = firstLine(path.join(ROOT, "AI", "VERSION"));
  return { p, v, a };
}
if (checkOnly) {
  const t = triple();
  if (t.p === t.v && t.p === t.a) {
    console.log("OK: versiones coinciden " + t.p);
    process.exit(0);
  }
  console.error("ABORT: versiones no coinciden package.json=" + t.p + " VERSION=" + t.v + " AI/VERSION=" + t.a);
  process.exit(1);
}
if (!want || !/^\d+\.\d+\.\d+$/.test(want)) {
  console.error("Uso: node scripts/bump-version.js <X.Y.Z> [--check]");
  process.exit(1);
}
const cur = triple();
if (cur.p !== cur.v || cur.p !== cur.a) {
  console.error("ABORT: triple con discrepancia previa package.json=" + cur.p + " VERSION=" + cur.v + " AI/VERSION=" + cur.a + "; sincroniza a mano antes del bump");
  process.exit(1);
}
const pkgPath = path.join(ROOT, "package.json");
const pkg = JSON.parse(fs.readFileSync(pkgPath, "utf8"));
pkg.version = want;
fs.writeFileSync(pkgPath, JSON.stringify(pkg, null, 2) + "\n");
fs.writeFileSync(path.join(ROOT, "VERSION"), want + "\n");
fs.writeFileSync(path.join(ROOT, "AI", "VERSION"), want + "\n");
console.log("OK: versión fijada a " + want + " (package.json, VERSION, AI/VERSION)");
try {
  cp.execSync("node .github/scripts/check-release-versions.js", { cwd: ROOT, stdio: "inherit" });
} catch {
  console.error("ABORT: guardia triple falló tras el bump");
  process.exit(1);
}
