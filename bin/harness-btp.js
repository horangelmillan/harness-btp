#!/usr/bin/env node
// harness-btp init --dest <dir> [--force] [--ref <tag>]
// Copia AI/, crea AGENTS.md puntero y fusiona .gitignore. Sin secretos.
// No toca package.json ni mta.yaml del proyecto.
const fs = require("fs");
const path = require("path");

function arg(name, def) {
  const i = process.argv.indexOf(name);
  return i !== -1 && process.argv[i + 1] ? process.argv[i + 1] : def;
}
const cmd = process.argv[2];
const dest = arg("--dest", ".");
const force = process.argv.includes("--force");
const ref = arg("--ref", null);
const src = path.join(__dirname, "..");

if (cmd !== "init") {
  console.log("Uso: harness-btp init --dest <dir> [--force] [--ref <tag>]");
  process.exit(1);
}
if (ref) console.log("REF: " + ref + " (el paquete incluye su propia versión; ver VERSION)");
if (!fs.existsSync(path.join(src, "AI"))) {
  console.log("ABORT: no se encontró AI/ junto al paquete");
  process.exit(1);
}

const aiDst = path.join(dest, "AI");
if (fs.existsSync(aiDst)) {
  if (force) {
    const bak = path.join(dest, "AI.bak");
    fs.rmSync(bak, { recursive: true, force: true });
    fs.renameSync(aiDst, bak);
    console.log("BACKUP: AI/ -> AI.bak");
    fs.cpSync(path.join(src, "AI"), aiDst, { recursive: true });
    console.log("CREATE: AI/ (reinstalado con --force)");
  } else {
    console.log("SKIP: AI/ ya existe (usa --force para reinstalar con backup .bak)");
  }
} else {
  fs.cpSync(path.join(src, "AI"), aiDst, { recursive: true });
  console.log("CREATE: AI/");
}

const agentsDst = path.join(dest, "AGENTS.md");
if (fs.existsSync(agentsDst)) {
  console.log("SKIP: AGENTS.md ya existe");
} else {
  fs.copyFileSync(path.join(src, "templates", "AGENTS.pointer.md"), agentsDst);
  console.log("CREATE: AGENTS.md (puntero a AI/AGENTS.md)");
}

const frag = fs.readFileSync(path.join(src, "AI", ".gitignore.fragment"), "utf8")
  .split(/\r?\n/).map((l) => l.trim()).filter((l) => l && !l.startsWith("#"));
let cur = [];
const giDst = path.join(dest, ".gitignore");
if (fs.existsSync(giDst)) cur = fs.readFileSync(giDst, "utf8").split(/\r?\n/);
const missing = frag.filter((l) => !cur.includes(l));
if (missing.length === 0) {
  console.log("SKIP: .gitignore ya contiene el fragmento");
} else {
  fs.appendFileSync(giDst, (cur.length ? "" : "") + missing.join("\n") + "\n");
  console.log("CREATE: .gitignore (+" + missing.length + " líneas)");
}
console.log("OK: harness instalado en " + dest + " (package.json y mta.yaml intactos)");
