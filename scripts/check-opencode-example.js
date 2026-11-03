#!/usr/bin/env node
// Valida AI/opencode.jsonc.example (estructural; no lanza MCP ni usa red).
// Uso: node scripts/check-opencode-example.js [ejemplo] [fragmento]
//   Sin args: AI/opencode.jsonc.example + AI/opencode.fragment.jsonc.
//   Con args: rutas alternas (para fixtures de tests).
// Reglas:
//   - JSONC: strip de comentarios respetando strings -> JSON.parse.
//   - Claves top ⊆ {$schema, mcp}; $schema fijo; servidores ⊆ catálogo;
//     único bloque activo = graphify-code; claves por servidor ⊆ verificadas
//     contra schema https://opencode.ai/config.json (OpenCode v2.0.23).
//   - Cada MCP comentado con su comentario FASE (con entorno declarado).
//   - fragmento ⊂ ejemplo (deepEqual; si no: FRAGMENT-DIFIERE).
//   - Sin claves: quita placeholders <...> y falla ante restos sensibles.
// Sin dependencias (solo fs/path).
const fs = require("fs");
const path = require("path");
const ROOT = path.join(__dirname, "..");
const exampleP = process.argv[2] || path.join(ROOT, "AI", "opencode.jsonc.example");
const fragmentP = process.argv[3] || path.join(ROOT, "AI", "opencode.fragment.jsonc");

const CATALOGO = ["graphify-code", "graphify-local", "context7",
  "codebase-memory", "github", "playwright", "chrome-devtools", "eslint"];
const COMENTADOS = ["context7", "codebase-memory", "github",
  "playwright", "chrome-devtools", "eslint"];
const VERIFICADAS = ["type", "command", "url", "cwd",
  "environment", "enabled", "headers", "timeout"];
const SCHEMA = "https://opencode.ai/config.json";

function strip(src) {
  let out = ""; let i = 0; let q = null;
  while (i < src.length) {
    const c = src[i]; const n = src[i + 1];
    if (q) {
      out += c;
      if (c === "\\") { out += n || ""; i += 2; continue; }
      if (c === q) q = null;
      i++; continue;
    }
    if (c === '"' || c === "'") { q = c; out += c; i++; continue; }
    if (c === "/" && n === "/") { while (i < src.length && src[i] !== "\n") i++; continue; }
    if (c === "/" && n === "*") {
      i += 2;
      while (i < src.length && !(src[i] === "*" && src[i + 1] === "/")) {
        if (src[i] === "\n") out += "\n";
        i++;
      }
      i += 2; continue;
    }
    out += c; i++;
  }
  return out;
}
function fail(m) { console.log("ABORT: " + m); process.exit(1); }

let rawEx; let rawFr;
try { rawEx = fs.readFileSync(exampleP, "utf8"); } catch { fail("EJEMPLO-ILEGIBLE: " + exampleP); }
try { rawFr = fs.readFileSync(fragmentP, "utf8"); } catch { fail("FRAGMENTO-ILEGIBLE: " + fragmentP); }
let ex; let fr;
try { ex = JSON.parse(strip(rawEx)); } catch (e) { fail("EJEMPLO-NO-JSON: " + e.message); }
try { fr = JSON.parse(strip(rawFr)); } catch (e) { fail("FRAGMENTO-NO-JSON: " + e.message); }

for (const k of Object.keys(ex)) if (!["$schema", "mcp"].includes(k)) fail("CLAVE-TOP-NO-VERIFICADA: " + k);
if (ex.$schema !== SCHEMA) fail("$SCHEMA-DIFIERE (esperado " + SCHEMA + ")");
if (!ex.mcp || typeof ex.mcp !== "object") fail("SIN-BLOQUE-MCP");
const activos = Object.keys(ex.mcp);
for (const m of activos) if (!CATALOGO.includes(m)) fail("MCP-NO-CATALOGADO: " + m);
if (activos.length !== 1 || activos[0] !== "graphify-code") fail("ACTIVO-DEBE-SER-SOLO-graphify-code (hay: " + activos.join(",") + ")");
for (const [m, cfg] of Object.entries(ex.mcp)) {
  for (const k of Object.keys(cfg)) if (!VERIFICADAS.includes(k)) fail("CLAVE-NO-VERIFICADA en " + m + ": " + k);
  if (cfg.type === "local" && !Array.isArray(cfg.command)) fail("LOCAL-SIN-COMMAND: " + m);
  if (cfg.type === "remote" && typeof cfg.url !== "string") fail("REMOTE-SIN-URL: " + m);
}

const lines = rawEx.replace(/\r\n/g, "\n").split("\n");
for (const m of COMENTADOS) {
  const idx = lines.findIndex((l) => l.trimStart().startsWith("//") && l.includes('"' + m + '"'));
  if (idx === -1) fail("MCP-SIN-BLOQUE-COMENTADO: " + m);
  const win = lines.slice(Math.max(0, idx - 12), idx + 1).join("\n");
  if (!/fase/i.test(win)) fail("MCP-SIN-FASE: " + m);
  if (!/entorno|environment/i.test(win)) fail("MCP-SIN-ENTORNO-EN-FASE: " + m);
}

if (JSON.stringify(fr.mcp) !== JSON.stringify({ "graphify-code": ex.mcp["graphify-code"] }))
  fail("FRAGMENT-DIFIERE (AI/opencode.fragment.jsonc debe coincidir con el bloque activo)");

const sinPh = rawEx.replace(/<[^<>\n]*>/g, "");
const leak = sinPh.match(/token|secret|passwd|pwd|password|BEGIN PRIVATE|sk-|ghp_|AKIA|authorization\s*=/i);
if (leak) fail("SECRETO-POSIBLE (" + leak[0] + " fuera de placeholder <...>)");

console.log("OK: opencode.jsonc.example ESTRUCTURALMENTE VALIDO (no implica conectado)");
