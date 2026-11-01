// Guardia de release: package.json, VERSION y AI/VERSION deben coincidir.
// Uso: node .github/scripts/check-release-versions.js (exit 0 OK, exit 1 ABORT).
// CI-only: no se publica en npm (files no incluye .github/).
const fs = require("fs");
function firstLine(p) {
  return fs.readFileSync(p, "utf8").split(/\r?\n/)[0].trim();
}
const p = JSON.parse(fs.readFileSync("package.json", "utf8")).version.trim();
const v = firstLine("VERSION");
const a = firstLine("AI/VERSION");
if (p !== v || p !== a) {
  console.error("ABORT: versiones no coinciden package.json=" + p + " VERSION=" + v + " AI/VERSION=" + a);
  process.exit(1);
}
console.log("OK: versiones coinciden " + p);
