#!/usr/bin/env node
// harness-btp init --dest <dir> [--force] [--ref <tag>]
// Copia AI/, crea AGENTS.md puntero, fusiona AI/.opencode/ en .opencode/
// raíz (solo faltantes; con --force hace backup a .opencode.bak) y fusiona .gitignore. Sin secretos.
// No toca package.json ni mta.yaml del proyecto.
const fs = require("fs");
const path = require("path");

function arg(name, def) {
  const i = process.argv.indexOf(name);
  return i !== -1 && process.argv[i + 1] ? process.argv[i + 1] : def;
}
let cmd = process.argv[2];
if (!cmd || cmd.startsWith("-")) {
  // Sin comando (p. ej. `pnpm dlx create-harness-btp --dest .`): asumir init.
  process.argv.splice(2, 0, "init");
  cmd = "init";
}
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
function readVer(p) {
  try {
    return fs.readFileSync(p, "utf8").split(/\r?\n/)[0].trim() || "desconocida";
  } catch { return "desconocida"; }
}
const harnessVersion = readVer(path.join(src, "AI", "VERSION"));

const aiDst = path.join(dest, "AI");
if (fs.existsSync(aiDst)) {
  if (force) {
    const oldVersion = readVer(path.join(aiDst, "VERSION"));
    const bak = path.join(dest, "AI.bak");
    fs.rmSync(bak, { recursive: true, force: true });
    fs.renameSync(aiDst, bak);
    fs.cpSync(path.join(src, "AI"), aiDst, { recursive: true });
    console.log("BACKUP: AI/ (v" + oldVersion + ") -> AI.bak; CREATE: AI/ (v" + harnessVersion + ")");
  } else {
    console.log("SKIP: AI/ ya existe (usa --force para reinstalar con backup .bak)");
  }
} else {
  fs.cpSync(path.join(src, "AI"), aiDst, { recursive: true });
  console.log("CREATE: AI/ (v" + harnessVersion + ")");
}

const agentsDst = path.join(dest, "AGENTS.md");
if (fs.existsSync(agentsDst)) {
  console.log("SKIP: AGENTS.md ya existe");
} else {
  fs.copyFileSync(path.join(src, "templates", "AGENTS.pointer.md"), agentsDst);
  console.log("CREATE: AGENTS.md (puntero a AI/AGENTS.md)");
}

const opSrc = path.join(src, "AI", ".opencode");
const opDst = path.join(dest, ".opencode");
function listFilesRec(dir, base) {
  let out = [];
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) out = out.concat(listFilesRec(p, base));
    else out.push(path.relative(base, p));
  }
  return out;
}
if (fs.existsSync(opSrc)) {
  if (force) {
    if (fs.existsSync(opDst)) {
      const opBak = path.join(dest, ".opencode.bak");
      fs.rmSync(opBak, { recursive: true, force: true });
      fs.renameSync(opDst, opBak);
      console.log("BACKUP: .opencode/ -> .opencode.bak");
    }
    fs.cpSync(opSrc, opDst, { recursive: true });
    console.log("CREATE: .opencode/ (+" + listFilesRec(opDst, opDst).length + " archivos)");
  } else {
    let opCount = 0;
    for (const rel of listFilesRec(opSrc, opSrc)) {
      const tgt = path.join(opDst, rel);
      if (fs.existsSync(tgt)) {
        console.log("SKIP: .opencode/" + rel.split(path.sep).join("/") + " ya existe");
      } else {
        fs.mkdirSync(path.dirname(tgt), { recursive: true });
        fs.copyFileSync(path.join(opSrc, rel), tgt);
        opCount++;
      }
    }
    console.log("CREATE: .opencode/ (+" + opCount + " archivos)");
  }
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
console.log("OK: harness v" + harnessVersion + " instalado en " + dest + " (package.json y mta.yaml intactos)");
