// Pruebas HTTP backend de app-ui5-qunit-opa (categoría 1: HTTP backend).
// Categorías separadas: QUnit unit puro vive en app/test/unit (0 fetch) y el
// journey OPA5 en app/test/integration (navegador). Este archivo solo toca
// el OData V4 del CAP local: CRUD + 400/404, con fixtures propias UUID y
// cleanup en finally. Patrón spawn cap-cli (win32 vía cmd.exe, shell:false).
// Uso: `npm test` desde esta carpeta. Puerto propio 4022 (env PORT).
const { describe, it, before, after } = require('node:test')
const assert = require('node:assert')
const { spawn } = require('node:child_process')
const path = require('node:path')
const { randomUUID } = require('node:crypto')

const PORT = Number(process.env.PORT || 4022)
const BASE = `http://localhost:${PORT}/odata/v4/catalog`

async function req (method, p, { body } = {}) {
  const res = await fetch(BASE + p, {
    method,
    headers: { 'Content-Type': 'application/json' },
    body: body === undefined ? undefined : JSON.stringify(body)
  })
  const text = await res.text()
  let json = null
  try { json = text ? JSON.parse(text) : null } catch { /* cuerpo no-json */ }
  return { status: res.status, json }
}

async function cleanup (id) {
  if (!id) return
  try { await req('DELETE', `/Books(${id})`) } catch { /* tolerante a fallos */ }
}

let srv
before(async () => {
  const args = ['-p', '@sap/cds-dk', 'cds', 'serve', '--port', String(PORT), '--in-memory']
  srv = process.platform === 'win32'
    ? spawn('cmd.exe', ['/d', '/s', '/c', 'npx', ...args], { cwd: path.join(__dirname, '..'), stdio: 'ignore', shell: false })
    : spawn('npx', args, { cwd: path.join(__dirname, '..'), stdio: 'ignore', shell: false })
  const t0 = Date.now()
  for (;;) {
    try {
      const r = await req('GET', '/Books')
      if (r.status === 200 && r.json && Array.isArray(r.json.value)) return
    } catch { /* aún arrancando */ }
    if (Date.now() - t0 > 90000) throw new Error('timeout esperando cds serve (GET /Books → 200)')
    await new Promise((r) => setTimeout(r, 500))
  }
})

after(() => {
  if (!srv || srv.exitCode !== null) return
  if (process.platform === 'win32') spawn('taskkill', ['/pid', String(srv.pid), '/t', '/f'])
  else srv.kill('SIGTERM')
})

describe('Books CRUD (HTTP backend)', () => {
  it('lista vacía aislada → 200 []', async () => {
    const r = await req('GET', `/Books?$filter=title eq 'NOEXISTE-${randomUUID()}'`)
    assert.strictEqual(r.status, 200)
    assert.deepStrictEqual(r.json.value, [])
  })

  it('POST → 201, GET coherente, PATCH persiste, DELETE → 204 + 404', async () => {
    const title = `HTTP-${randomUUID()}`
    let id = null
    try {
      const c = await req('POST', '/Books', { body: { title, stock: 3 } })
      assert.strictEqual(c.status, 201)
      assert.ok(c.json.ID, 'sin ID en respuesta')
      id = c.json.ID
      const g = await req('GET', `/Books(${id})`)
      assert.strictEqual(g.status, 200)
      assert.strictEqual(g.json.title, title)
      assert.strictEqual(g.json.stock, 3)
      const u = await req('PATCH', `/Books(${id})`, { body: { stock: 7 } })
      assert.strictEqual(u.status, 200)
      const g2 = await req('GET', `/Books(${id})`)
      assert.strictEqual(g2.json.stock, 7)
      const d = await req('DELETE', `/Books(${id})`)
      assert.strictEqual(d.status, 204)
      const g3 = await req('GET', `/Books(${id})`)
      assert.strictEqual(g3.status, 404)
      id = null // ya eliminado: cleanup no-op
    } finally {
      await cleanup(id)
    }
  })

  it('id inexistente → 404', async () => {
    const r = await req('GET', `/Books(${randomUUID()})`)
    assert.strictEqual(r.status, 404)
  })

  it('dato inválido (stock texto) → 400', async () => {
    const r = await req('POST', '/Books', { body: { title: 'X', stock: 'mucho' } })
    assert.strictEqual(r.status, 400)
  })
})
