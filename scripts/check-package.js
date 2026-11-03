#!/usr/bin/env node
// Guardia de distribución npm (R1-FINAL-CLOSE): inspecciona el contenido
// real que npm empaquetaría y falla si hay fugas. No modifica ni borra nada.
// Uso: node scripts/check-package.js
//   HARNESS_BTP_ROOT=<dir> para probar réplicas/fixtures en temp.
// Reglas explícitas por ruta (sin bloquear nombres legítimos por coincidencia
// parcial): segment worlds exactos. AI/.opencode/ legacy: permitido
// (compatibilidad demostrada en initial-assessment §3/§5).
const fs = require("fs");
const path = require("path");
const cp = require("child_process");
const ROOT = process.env.HARNESS_BTP_ROOT || path.join(__dirname, "..");

function packList() {
  try {
    const out = cp.execSync("npm pack --dry-run --json", { cwd: ROOT, encoding: "utf8", stdio: "pipe" });
    const arr = JSON.parse(out);
    const listed = Array.isArray(arr) ? (arr[0].files || arr) : [];
    return listed.map((e) => ((e && e.path) || e).replace(/\\/g, "/"));
  } catch {
    // Fallback: parseo de texto del dry-run.
    const out = cp.execSync("npm pack --dry-run", { cwd: ROOT, encoding: "utf8", stdio: "pipe" });
    return out.split("\n").map((l) => {
      const m = l.match(/notice\s+\S+\s+(\S+)\s*$/);
      return m ? m[1] : null;
    }).filter(Boolean);
  }
}

const BANNED = [
  { re: /(^|\/)node_modules\//, why: "node_modules/ (deps reproducibles, no se distribuyen)" },
  { re: /(^|\/)temp\//, why: "temp/ (transitorios)" },
  { re: /\.raw\.log$/, why: "*.raw.log (crudos con secretos potenciales)" },
  { re: /(^|\/)graphify-out\//, why: "graphify-out/ (índice local)" },
  { re: /(^|\/)evidencia\//, why: "evidencia/ (artefactos de tarea)" },
  { re: /(^|\/)\.playwright-mcp\//, why: ".playwright-mcp/ (caché de navegador)" },
  { re: /^\.opencode\//, why: ".opencode/ (Meta-Harness interno)" },
  { re: /^docs\//, why: "docs/ (Meta-Harness interno)" },
  { re: /^scripts\//, why: "scripts/ (Meta-Harness interno)" },
  { re: /^\.github\//, why: ".github/ (CI interna)" },
  { re: /(^|\/)\.env($|\.)/, why: ".env* (secretos potenciales)" },
  { re: /(^|\/)default-services\.json$/, why: "default-services.json (claves)" },
  { re: /\.pem$/, why: "*.pem (claves)" },
  { re: /(^|\/)id_rsa/, why: "claves ssh" },
];
const REQUIRED = [
  "AI/AGENTS.md", "AI/VERSION", "AI/.gitignore.fragment",
  "AI/scripts/validate-app.ps1", "AI/scripts/validate-app.sh",
  "bin/harness-btp.js", "templates/AGENTS.pointer.md",
  "install.ps1", "install.sh", "package.json", "README.md", "VERSION",
];

const files = packList();
const bad = [];
for (const f of files) {
  // AI/.opencode/ legacy: permitido explícitamente (compatibilidad).
  if (f.startsWith("AI/.opencode/")) continue;
  for (const b of BANNED) {
    if (b.re.test(f)) { bad.push(f + "  <= " + b.why); break; }
  }
}
const missing = REQUIRED.filter((r) => !files.includes(r));
if (bad.length) {
  console.log("FUGAS detectadas en el paquete (" + bad.length + "):");
  for (const b of bad) console.log("  " + b);
  process.exit(1);
}
if (missing.length) {
  console.log("FALTAN archivos de producto en el paquete (" + missing.length + "):");
  for (const m of missing) console.log("  " + m);
  process.exit(1);
}
console.log("OK: paquete limpio (" + files.length + " archivos, 0 fugas, producto completo)");
