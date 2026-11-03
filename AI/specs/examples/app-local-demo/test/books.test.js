// Pruebas CRUD + auth de app-local-demo (T5.1).
// Uso: `npm test` (= `node --test test/`) desde AI/specs/examples/app-local-demo.
// Arranca su propio `cds serve --in-memory` (SQLite volatil) y lo detiene al
// cerrar. Sin BTP, sin credenciales reales: usuarios mock solo-[development]
// (`reader`/`writer`) declarados en package.json. Nivel de evidencia: LOCAL.
const { describe, it, before, after } = require('node:test')
const assert = require('node:assert')
const { spawn } = require('node:child_process')
const path = require('node:path')
const { randomUUID } = require('node:crypto')

const PORT = 4004
const BASE = `http://localhost:${PORT}/odata/v4/catalog`
const basic = (u, p) => 'Basic ' + Buffer.from(`${u}:${p}`).toString('base64')
const READER = { Authorization: basic('reader', 'reader') }
const WRITER = { Authorization: basic('writer', 'writer') }

async function req (method, p, { headers = {}, body } = {}) {
  const res = await fetch(BASE + p, {
    method,
    headers: { 'Content-Type': 'application/json', ...headers },
    body: body === undefined ? undefined : JSON.stringify(body)
  })
  const text = await res.text()
  let json = null
  try { json = text ? JSON.parse(text) : null } catch { /* cuerpo no-json */ }
  return { status: res.status, json }
}

let srv
before(async () => {
  srv = spawn('npx',
    ['-p', '@sap/cds-dk', 'cds', 'serve', '--port', String(PORT), '--in-memory'],
    { cwd: path.join(__dirname, '..'), stdio: 'ignore', shell: process.platform === 'win32' })
  const t0 = Date.now()
  for (;;) {
    try {
      // Se exige el servidor correcto (no uno rancio): writer debe listar 200.
      const r = await req('GET', '/Books', { headers: WRITER })
      if (r.status === 200 && r.json && Array.isArray(r.json.value)) return
    } catch { /* aún arrancando */ }
    if (Date.now() - t0 > 90000) throw new Error('timeout esperando cds serve con usuarios mock (writer→200)')
    await new Promise((r) => setTimeout(r, 500))
  }
})

after(() => {
  if (!srv || srv.exitCode !== null) return
  if (process.platform === 'win32') spawn('taskkill', ['/pid', String(srv.pid), '/t', '/f'])
  else srv.kill('SIGTERM')
})

describe('auth (mock local, @(requires:Viewer))', () => {
  it('sin credenciales → 401', async () => {
    const r = await req('GET', '/Books')
    assert.strictEqual(r.status, 401)
  })
  it('reader lista vacío → 200 []', async () => {
    const r = await req('GET', '/Books', { headers: READER })
    assert.strictEqual(r.status, 200)
    assert.deepStrictEqual(r.json.value, [])
  })
})

describe('Books CRUD', () => {
  let id
  it('crear libro → 201 con ID', async () => {
    const r = await req('POST', '/Books', { headers: WRITER, body: { title: 'T5.1', stock: 3 } })
    assert.strictEqual(r.status, 201)
    assert.ok(r.json.ID, 'sin ID en respuesta')
    assert.strictEqual(r.json.title, 'T5.1')
    id = r.json.ID
  })
  it('leer libro → 200 coherente', async () => {
    const r = await req('GET', `/Books(${id})`, { headers: READER })
    assert.strictEqual(r.status, 200)
    assert.strictEqual(r.json.title, 'T5.1')
    assert.strictEqual(r.json.stock, 3)
  })
  it('actualizar stock → persiste', async () => {
    const u = await req('PATCH', `/Books(${id})`, { headers: WRITER, body: { stock: 7 } })
    assert.strictEqual(u.status, 200)
    const r = await req('GET', `/Books(${id})`, { headers: READER })
    assert.strictEqual(r.json.stock, 7)
  })
  it('id inexistente → 404', async () => {
    const r = await req('GET', `/Books(${randomUUID()})`, { headers: WRITER })
    assert.strictEqual(r.status, 404)
  })
  it('dato inválido (stock texto) → 400', async () => {
    const r = await req('POST', '/Books', { headers: WRITER, body: { title: 'X', stock: 'mucho' } })
    assert.strictEqual(r.status, 400)
  })
  it('eliminar → 204 y posterior 404', async () => {
    const d = await req('DELETE', `/Books(${id})`, { headers: WRITER })
    assert.strictEqual(d.status, 204)
    const r = await req('GET', `/Books(${id})`, { headers: WRITER })
    assert.strictEqual(r.status, 404)
  })
})
