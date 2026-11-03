#!/usr/bin/env node
// Valida el Meta-Harness sin dependencias: frontmatter meta, docs, y guardias producto.
// Uso: node scripts/validate-meta.js
const fs = require("fs");
const path = require("path");
const cp = require("child_process");
const ROOT = path.join(__dirname, "..");
const fail = [];
const ok = [];
function need(p, label) {
  if (fs.existsSync(path.join(ROOT, p))) ok.push("OK: " + label);
  else fail.push("FALTA: " + p);
}
function fm(p, keys) {
  const t = fs.readFileSync(path.join(ROOT, p), "utf8").replace(/\r\n/g, "\n");
  const lines = t.split("\n");
  if (lines[0] !== "---") { fail.push("FRONTMATTER: " + p); return; }
  const end = lines.indexOf("---", 1);
  if (end === -1) { fail.push("FRONTMATTER-SIN-CIERRE: " + p); return; }
  const top = lines.slice(1, end).filter((l) => !/^\s/.test(l) && l.includes(":"))
    .map((l) => l.slice(0, l.indexOf(":")).trim());
  for (const k of keys) if (!top.includes(k)) fail.push("SIN-" + k + ": " + p);
  ok.push("OK: fm " + p);
}
const agents = ["engineering-orchestrator", "harness-researcher", "harness-architect",
  "harness-implementer", "harness-qa", "sap-btp-specialist", "security-engineer",
  "documentation-engineer", "mcp-skills-engineer", "performance-engineer", "reviewer"];
for (const a of agents) {
  need(".opencode/agents/" + a + ".md", "meta agent " + a);
  if (fs.existsSync(path.join(ROOT, ".opencode/agents/" + a + ".md")))
    fm(".opencode/agents/" + a + ".md", ["name", "description"]);
}
for (const c of ["engineering-feature", "engineering-research", "engineering-refactor",
  "engineering-improvement", "engineering-release"]) {
  need(".opencode/commands/" + c + ".md", "meta flow " + c);
}
for (const d of ["docs/engineering/knowledge-map.md",
  "docs/engineering/impact-guide.md", "docs/engineering/metrics/baseline-P1.md",
  "docs/engineering/knowledge-lifecycle.md", "docs/mcp/graphify-local.md",
  "docs/improvements/opportunities.md"]) {
  need(d, d);
  if (fs.existsSync(path.join(ROOT, d))) fm(d, ["title", "date", "status"]);
}
// Gobernanza T3: 11 agentes meta (sin agentes nuevos salvo necesidad
// demostrada) y Flow D autónomo de 10 etapas.
// Fuente verdad: array `agents[11]`; ignorados locales exentos (solo
// lectura fs + ls-files; nunca clean/reset/checkout/stash/borrar).
try {
  const dir = path.join(ROOT, ".opencode", "agents");
  const files = fs.readdirSync(dir).filter((f) => f.endsWith(".md"));
  const want = new Set(agents.map((a) => a.toLowerCase()));
  const seen = new Set(); const dups = new Set();
  for (const f of files) {
    const k = f.toLowerCase();
    if (seen.has(k)) dups.add(f); else seen.add(k);
  }
  for (const d of dups) fail.push("AGENTE-DUPLICADO: " + d);
  const onDisk = new Set(files.map((f) => f.toLowerCase()));
  for (const a of agents)
    if (!onDisk.has((a + ".md").toLowerCase())) fail.push("AGENTE-CANONICO-FALTA: " + a);
  let tracked = null;
  try {
    const out = cp.execSync('git ls-files -- ".opencode/agents/*.md"', { cwd: ROOT, encoding: "utf8", stdio: "pipe" });
    tracked = new Set(out.split("\n").map((s) => s.trim()).filter(Boolean).map((s) => path.basename(s).toLowerCase()));
  } catch (e) { tracked = null; }
  if (tracked === null) {
    ok.push("OK: 11 agentes meta (SIN-GIT: extras no auditables)");
  } else {
    for (const f of files)
      if (!want.has(f.toLowerCase().replace(/\.md$/, "")) && tracked.has(f.toLowerCase()))
        fail.push("AGENTE-NO-REGISTRADO: " + f);
    if (!dups.size && !fail.some((m) => /^AGENTE-/.test(m)))
      ok.push("OK: 11 agentes meta (ignorados locales exentos)");
  }
} catch (e) { fail.push("AGENTES-ILEGIBLE"); }
try {
  const flow = fs.readFileSync(path.join(ROOT, ".opencode/commands/engineering-improvement.md"), "utf8");
  for (const k of ["OBSERVE", "PRIORITIZE", "SYNCHRONIZE", "opportunities.md", "PEND-KNOWLEDGE"])
    if (!flow.includes(k)) fail.push("FLOW-D-SIN-" + k);
  ok.push("OK: Flow D autónomo");
} catch (e) { fail.push("FLOW-D-ILEGIBLE"); }
// Gobernanza: sin dependencias runtime nuevas (meta sin deps).
try {
  const pkg = JSON.parse(fs.readFileSync(path.join(ROOT, "package.json"), "utf8"));
  if (pkg.dependencies && Object.keys(pkg.dependencies).length)
    fail.push("DEPENDENCIAS-NUEVAS: package.json dependencies debe seguir vacío");
  else ok.push("OK: sin dependencias runtime");
} catch (e) { fail.push("PACKAGE-JSON-ILEGIBLE"); }
// Gobernanza: anti-duplicación MCP (todo MCP citado en .opencode/ listado en catálogo).
try {
  const known = ["graphify-code", "context7", "codebase-memory", "github",
    "playwright", "chrome-devtools", "eslint"];
  const cat = fs.readFileSync(path.join(ROOT, "docs/mcp/catalog.md"), "utf8");
  for (const m of known) if (!cat.includes(m)) fail.push("MCP-NO-CATALOGADO: " + m);
  const metaFiles = [];
  for (const sub of ["agents", "commands"]) {
    const dir = path.join(ROOT, ".opencode", sub);
    if (fs.existsSync(dir)) for (const f of fs.readdirSync(dir))
      if (f.endsWith(".md")) metaFiles.push(path.join(dir, f));
  }
  const seen = new Set();
  for (const f of metaFiles) {
    const t = fs.readFileSync(f, "utf8");
    const toks = t.match(/`[a-z0-9][a-z0-9-]*`/g) || [];
    for (const tok of toks) {
      const w = tok.slice(1, -1);
      if (/mcp/i.test(w) && !/engineer|orchestrator|specialist|reviewer|implementer|architect|researcher/i.test(w) && !known.includes(w)) seen.add(w + " en " + path.basename(f));
    }
  }
  if (seen.size) for (const s of seen) fail.push("MCP-NO-LISTADO: " + s);
  else ok.push("OK: MCP meta catalogados");
} catch (e) { fail.push("MCP-CHECK-ERROR: " + e.message); }
for (const d of ["AGENTS.md", "docs/engineering/initial-assessment.md",
  "docs/engineering/system-overview.md", "docs/engineering/contracts.md",
  "docs/agents/catalog.md", "docs/mcp/catalog.md", "docs/skills/catalog.md",
  "docs/backlog/backlog.md", "docs/architecture/decisions/ADR-001-meta-separation.md"])
  need(d, d);
try {
  cp.execSync("node scripts/render-clients.js --check", { cwd: ROOT, stdio: "pipe" });
  ok.push("OK: render --check");
} catch (e) { fail.push("RENDER-DIFIERE (corre node scripts/render-clients.js)"); }
try {
  cp.execSync("node .github/scripts/check-release-versions.js", { cwd: ROOT, stdio: "pipe" });
  ok.push("OK: triple version");
} catch (e) { fail.push("VERSION-DIFIERE (package.json/VERSION/AI/VERSION)"); }
for (const l of ok) console.log(l);
if (fail.length) {
  for (const l of fail) console.log(l);
  console.log("ABORT: meta inválido (" + fail.length + " fallos)");
  process.exit(1);
}
console.log("OK: meta válido (" + ok.length + " checks)");
