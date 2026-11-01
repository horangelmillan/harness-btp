#!/usr/bin/env node
// Renderiza AI/clients/<cliente>/ desde la fuente canonica AI/agents, AI/commands, AI/skills.
// Uso: node scripts/render-clients.js [--check]
//   sin flags: regenera AI/clients/ (idempotente: solo escribe lo que cambie).
//   --check:   no escribe; exit 0 si el arbol coincide, exit 1 si difiere.
// Sin dependencias (solo fs/path/os). EOL siempre LF.
const fs = require("fs");
const path = require("path");
const os = require("os");

const ROOT = path.join(__dirname, "..", "AI");
const SRC = {
  agents: path.join(ROOT, "agents"),
  commands: path.join(ROOT, "commands"),
  skills: path.join(ROOT, "skills"),
};
const OUT = path.join(ROOT, "clients");

function read(p) {
  return fs.readFileSync(p, "utf8").replace(/\r\n/g, "\n");
}

// Divide "---\nfm\n---\nbody" en {fmLines:[...], body}. Falla si no hay frontmatter.
function parseFm(text, rel) {
  const lines = text.split("\n");
  if (lines[0] !== "---") throw new Error("sin frontmatter: " + rel);
  const end = lines.indexOf("---", 1);
  if (end === -1) throw new Error("frontmatter sin cierre: " + rel);
  return { fmLines: lines.slice(1, end), body: lines.slice(end + 1).join("\n") };
}

// Filtra lineas de frontmatter por clave de primer nivel, conservando
// byte a byte las lineas kept (incluye continuaciones indentadas como
// bloques `permissions:`). `want` = lista de claves o null (todas menos `except`).
function filterFm(fmLines, want, except) {
  const out = [];
  let cur = null;
  for (const l of fmLines) {
    const m = l.match(/^([A-Za-z0-9_-]+):/);
    if (m && !/^\s/.test(l)) cur = m[1];
    const keep = want ? want.includes(cur) : cur !== except;
    if (keep) out.push(l);
  }
  return out;
}

// Extrae pares simples de primer nivel (para validaciones puntuales).
function topKeys(fmLines) {
  return fmLines.filter((l) => !/^\s/.test(l) && l.includes(":"))
    .map((l) => l.slice(0, l.indexOf(":")).trim());
}

function fmText(fmLines, body) {
  return "---\n" + fmLines.join("\n") + "\n---\n" + body;
}

function listMd(dir) {
  return fs.readdirSync(dir).filter((f) => f.endsWith(".md")).sort();
}

// Recolecta archivos (rel -> contenido) copiando un arbol tal cual.
function collectTree(dir, base) {
  const out = new Map();
  const walk = (d) => {
    for (const e of fs.readdirSync(d, { withFileTypes: true }).sort((a, b) => a.name < b.name ? -1 : 1)) {
      const p = path.join(d, e.name);
      if (e.isDirectory()) walk(p);
      else out.set(path.relative(base, p).split(path.sep).join("/"), read(p));
    }
  };
  walk(dir);
  return out;
}

// Construye el mapa esperado: rel (dentro de AI/clients) -> contenido.
function buildExpected() {
  const exp = new Map();
  const put = (rel, content) => exp.set(rel, content);

  // --- opencode: copia exacta de .opencode actual (canonico sin `name`) ---
  for (const f of listMd(SRC.agents)) {
    const { fmLines, body } = parseFm(read(path.join(SRC.agents, f)), "agents/" + f);
    put("opencode/agents/" + f, fmText(filterFm(fmLines, null, "name"), body));
  }
  for (const f of listMd(SRC.commands)) put("opencode/commands/" + f, read(path.join(SRC.commands, f)));
  for (const [rel, c] of collectTree(SRC.skills, SRC.skills)) put("opencode/skills/" + rel, c);

  // --- claude: agents {name,description} (sin mode), resto identico ---
  for (const f of listMd(SRC.agents)) {
    const { fmLines, body } = parseFm(read(path.join(SRC.agents, f)), "agents/" + f);
    put("claude/agents/" + f, fmText(filterFm(fmLines, ["name", "description"]), body));
  }
  for (const f of listMd(SRC.commands)) put("claude/commands/" + f, read(path.join(SRC.commands, f)));
  for (const [rel, c] of collectTree(SRC.skills, SRC.skills)) put("claude/skills/" + rel, c);

  // --- cursor: commands SIN frontmatter (solo cuerpo), skills identicas ---
  for (const f of listMd(SRC.commands)) {
    const { body } = parseFm(read(path.join(SRC.commands, f)), "commands/" + f);
    put("cursor/commands/" + f, body);
  }
  for (const [rel, c] of collectTree(SRC.skills, SRC.skills)) put("cursor/skills/" + rel, c);

  // --- copilot: agents a <n>.agent.md {name,description}, prompts, skills ---
  for (const f of listMd(SRC.agents)) {
    const { fmLines, body } = parseFm(read(path.join(SRC.agents, f)), "agents/" + f);
    put("copilot/agents/" + f.replace(/\.md$/, ".agent.md"), fmText(filterFm(fmLines, ["name", "description"]), body));
  }
  for (const f of listMd(SRC.commands)) {
    put("copilot/prompts/" + f.replace(/\.md$/, ".prompt.md"), read(path.join(SRC.commands, f)));
  }
  for (const [rel, c] of collectTree(SRC.skills, SRC.skills)) put("copilot/skills/" + rel, c);

  // --- aider: nada que generar (usa AGENTS.md raiz) ---
  return exp;
}

function collectActual() {
  const act = new Map();
  if (!fs.existsSync(OUT)) return act;
  const walk = (d) => {
    for (const e of fs.readdirSync(d, { withFileTypes: true }).sort((a, b) => a.name < b.name ? -1 : 1)) {
      const p = path.join(d, e.name);
      if (e.isDirectory()) walk(p);
      else act.set(path.relative(OUT, p).split(path.sep).join("/"), read(p));
    }
  };
  walk(OUT);
  return act;
}

function diffMaps(exp, act) {
  const diffs = [];
  for (const [rel, c] of exp) {
    if (!act.has(rel)) diffs.push("FALTA: " + rel);
    else if (act.get(rel) !== c) diffs.push("DIFIERE: " + rel);
  }
  for (const rel of act.keys()) if (!exp.has(rel)) diffs.push("SOBRA: " + rel);
  return diffs.sort();
}

const check = process.argv.includes("--check");
const expected = buildExpected();
const actual = collectActual();
const diffs = diffMaps(expected, actual);

if (check) {
  if (diffs.length) {
    for (const d of diffs) console.log(d);
    console.log("ABORT: AI/clients/ difiere del canonico (corre node scripts/render-clients.js)");
    process.exit(1);
  }
  console.log("OK: AI/clients/ coincide con el canonico (" + expected.size + " archivos)");
} else {
  let written = 0;
  for (const [rel, c] of expected) {
    const p = path.join(OUT, ...rel.split("/"));
    if (fs.existsSync(p) && read(p) === c) continue;
    fs.mkdirSync(path.dirname(p), { recursive: true });
    fs.writeFileSync(p, c.replace(/\n/g, "\n"), "utf8");
    written++;
  }
  // Borra sobrantes para idempotencia exacta.
  for (const rel of actual.keys()) {
    if (!expected.has(rel)) {
      fs.rmSync(path.join(OUT, ...rel.split("/")), { force: true });
      written++;
    }
  }
  console.log("OK: AI/clients/ renderizado (" + expected.size + " archivos, " + written + " escritos)");
}
