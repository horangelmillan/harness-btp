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
