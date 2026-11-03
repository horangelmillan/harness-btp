#!/usr/bin/env node
// harness-btp init --dest <dir> [--force] [--ref <tag>] [--client auto|all|opencode,claude,...]
// Copia AI/, crea AGENTS.md puntero, fusiona el árbol del cliente agéntico
// desde AI/clients/<cliente>/ en la raíz (solo faltantes; con --force hace
// backup a <dir>.bak) y fusiona .gitignore. Sin secretos.
// No toca package.json ni mta.yaml del proyecto.
const fs = require("fs");
const path = require("path");

function arg(name, def) {
  const i = process.argv.indexOf(name);
  return i !== -1 && process.argv[i + 1] ? process.argv[i + 1] : def;
}
let cmd = process.argv[2];
if (process.argv.includes("--help") || process.argv.includes("-h")) {
  console.log("Uso: harness-btp init --dest <dir> [--force] [--ref <tag>] [--backup-dir <dir>] [--client auto|all|opencode,claude,...]");
  console.log("  --dest <dir>     proyecto destino (por defecto: .)");
  console.log("  --force          reinstala AI/ con backup (por defecto <dest>/AI.bak)");
  console.log("  --backup-dir <d> backups fuera del destino (recomendado)");
  console.log("  --ref <tag>      informativo (el paquete incluye su propia versión; ver VERSION)");
  console.log("  --client <list>  auto (defecto) | all | opencode,claude,cursor,copilot,aider");
  process.exit(0);
}
if (!cmd || cmd.startsWith("-")) {
  // Sin comando (p. ej. `pnpm dlx create-harness-btp --dest .`): asumir init.
  process.argv.splice(2, 0, "init");
  cmd = "init";
}
function backupPath(cur) {
  if (backupDir) {
    fs.mkdirSync(backupDir, { recursive: true });
    return path.join(backupDir, path.basename(cur) + ".bak");
  }
  return cur + ".bak";
}
const dest = arg("--dest", ".");
const force = process.argv.includes("--force");
const ref = arg("--ref", null);
const backupDir = arg("--backup-dir", "");
const clientSpec = arg("--client", "auto");
const src = path.join(__dirname, "..");

if (cmd !== "init") {
  console.log("Uso: harness-btp init --dest <dir> [--force] [--ref <tag>] [--backup-dir <dir>] [--client auto|all|opencode,claude,...]");
  process.exit(1);
}
if (ref) console.log("REF: " + ref + " (el paquete incluye su propia versión; ver VERSION)");
if (!fs.existsSync(path.join(src, "AI"))) {
  console.log("ABORT: no se encontró AI/ junto al paquete");
  process.exit(1);
}
fs.mkdirSync(dest, { recursive: true });
function readVer(p) {
  try {
    return fs.readFileSync(p, "utf8").split(/\r?\n/)[0].trim() || "desconocida";
  } catch { return "desconocida"; }
}
const harnessVersion = readVer(path.join(src, "AI", "VERSION"));

function movePath(from, to) {
  try { fs.renameSync(from, to); }
  catch (e) {
    if (e && (e.code === "EXDEV" || e.code === "EPERM")) {
      fs.cpSync(from, to, { recursive: true });
      fs.rmSync(from, { recursive: true, force: true });
    } else throw e;
  }
}

const aiDst = path.join(dest, "AI");
if (fs.existsSync(aiDst)) {
  if (force) {
    const oldVersion = readVer(path.join(aiDst, "VERSION"));
    const bak = backupPath(aiDst);
    fs.rmSync(bak, { recursive: true, force: true });
    movePath(aiDst, bak);
    fs.cpSync(path.join(src, "AI"), aiDst, { recursive: true });
    console.log("BACKUP: AI/ (v" + oldVersion + ") -> " + bak + "; CREATE: AI/ (v" + harnessVersion + ")");
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

const KNOWN = ["opencode", "claude", "cursor", "copilot", "aider"];
function resolveClients(spec, destDir) {
  const s = (spec + "").trim().toLowerCase();
  if (s === "auto") {
    const d = [];
    if (fs.existsSync(path.join(destDir, "CLAUDE.md")) || fs.existsSync(path.join(destDir, ".claude"))) d.push("claude");
    if (fs.existsSync(path.join(destDir, ".cursor"))) d.push("cursor");
    if (fs.existsSync(path.join(destDir, ".github"))) d.push("copilot");
    if (fs.readdirSync(destDir, { withFileTypes: true }).some((e) => e.isFile() && e.name.startsWith("opencode.json")) || fs.existsSync(path.join(destDir, ".opencode"))) d.push("opencode");
    if (!d.length) d.push("opencode");
    console.log("CLIENT: auto -> " + d.join(","));
    return d;
  }
  if (s === "all") return ["opencode", "claude", "cursor", "copilot"];
  const list = s.split(",").map((x) => x.trim().toLowerCase()).filter(Boolean);
  for (const c of list) {
    if (!KNOWN.includes(c)) {
      console.log("ABORT: cliente desconocido '" + c + "' (usa auto|all|opencode,claude,cursor,copilot,aider)");
      process.exit(1);
    }
  }
  if (!list.length) {
    console.log("ABORT: --client vacío (usa auto|all|opencode,claude,cursor,copilot,aider)");
    process.exit(1);
  }
  return list;
}

function mergeTree(treeSrc, treeDst, label) {
  if (!fs.existsSync(treeSrc)) {
    console.log("AVISO: no existe " + treeSrc + " (regenera con node scripts/render-clients.js)");
    return;
  }
  const bakLabel = label.replace(/\/$/, "") + ".bak";
  if (force) {
    if (fs.existsSync(treeDst)) {
      const bak = backupPath(treeDst);
      fs.rmSync(bak, { recursive: true, force: true });
      movePath(treeDst, bak);
      console.log("BACKUP: " + label + " -> " + bakLabel + " (" + bak + ")");
    }
    fs.cpSync(treeSrc, treeDst, { recursive: true });
    console.log("CREATE: " + label + " (+" + listFilesRec(treeDst, treeDst).length + " archivos)");
  } else {
    let count = 0;
    for (const rel of listFilesRec(treeSrc, treeSrc)) {
      const tgt = path.join(treeDst, rel);
      if (fs.existsSync(tgt)) {
        console.log("SKIP: " + label + rel.split(path.sep).join("/") + " ya existe");
      } else {
        fs.mkdirSync(path.dirname(tgt), { recursive: true });
        fs.copyFileSync(path.join(treeSrc, rel), tgt);
        count++;
      }
    }
    console.log("CREATE: " + label + " (+" + count + " archivos)");
  }
}

const clientsSrc = path.join(src, "AI", "clients");
for (const c of resolveClients(clientSpec, dest)) {
  if (c === "opencode") mergeTree(path.join(clientsSrc, "opencode"), path.join(dest, ".opencode"), ".opencode/");
  else if (c === "claude") mergeTree(path.join(clientsSrc, "claude"), path.join(dest, ".claude"), ".claude/");
  else if (c === "cursor") {
    mergeTree(path.join(clientsSrc, "cursor", "commands"), path.join(dest, ".cursor", "commands"), ".cursor/commands/");
    mergeTree(path.join(clientsSrc, "cursor", "skills"), path.join(dest, ".agents", "skills"), ".agents/skills/");
  } else if (c === "copilot") {
    mergeTree(path.join(clientsSrc, "copilot", "agents"), path.join(dest, ".github", "agents"), ".github/agents/");
    mergeTree(path.join(clientsSrc, "copilot", "skills"), path.join(dest, ".github", "skills"), ".github/skills/");
    mergeTree(path.join(clientsSrc, "copilot", "prompts"), path.join(dest, ".github", "prompts"), ".github/prompts/");
  } else if (c === "aider") console.log("SKIP: aider usa AGENTS.md raiz (nada que fusionar)");
}
function listFilesRec(dir, base) {
  let out = [];
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) out = out.concat(listFilesRec(p, base));
    else out.push(path.relative(base, p));
  }
  return out;
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
