// Lee document.title de una página vía CDP (stdlib Node: fetch + WebSocket
// global). La página escribe su resumen QUnit en <title> (ver QUnit.done en
// las *.qunit.html): "QUNIT <scope>: <n> passed, <m> failed".
// Uso: node cdp-eval.js <cdpPort> <pageUrl> <scope> <timeoutMs>
// Imprime el title y sale 0 si casa /QUNIT <scope>: \d+ passed, 0 failed/.
// Cierra el target creado. Solo habla con el CDP propio ya verificado.
const [cdpPort, pageUrl, scope, timeoutMsArg] = process.argv.slice(2)
const TIMEOUT = Number(timeoutMsArg || 120000)
const CRE = new RegExp(`^QUNIT ${scope}: \\d+ passed, \\d+ failed$`)

if (!cdpPort || !pageUrl || !scope) {
  console.error('uso: node cdp-eval.js <cdpPort> <pageUrl> <scope> [timeoutMs]')
  process.exit(2)
}

const sleep = (ms) => new Promise((r) => setTimeout(r, ms))

async function main () {
  const put = await fetch(`http://localhost:${cdpPort}/json/new?${new URLSearchParams({ url: pageUrl })}`, { method: 'PUT' })
  if (!put.ok) throw new Error(`CDP /json/new → ${put.status}`)
  const target = await put.json()
  const wsUrl = target.webSocketDebuggerUrl
  if (!wsUrl) throw new Error('CDP sin webSocketDebuggerUrl')
  const id = target.id

  const ws = new WebSocket(wsUrl)
  await new Promise((resolve, reject) => {
    ws.addEventListener('open', resolve, { once: true })
    ws.addEventListener('error', reject, { once: true })
  })

  let seq = 0
  const pending = new Map()
  ws.addEventListener('message', (ev) => {
    try {
      const msg = JSON.parse(String(ev.data))
      if (msg.id && pending.has(msg.id)) pending.get(msg.id)(msg)
    } catch { /* ignora eventos */ }
  })
  const evaluate = (expression) => new Promise((resolve, reject) => {
    const mid = ++seq
    pending.set(mid, resolve)
    ws.send(JSON.stringify({ id: mid, method: 'Runtime.evaluate', params: { expression, returnByValue: true } }))
    setTimeout(() => { if (pending.has(mid)) { pending.delete(mid); reject(new Error('timeout evaluate')) } }, 10000)
  })

  const t0 = Date.now()
  let title = ''
  try {
    // /json/new no navega en headless=new (el target queda en
    // about:blank): navegación explícita por CDP.
    await evaluate(`(function(){return location.href})()`)
    await new Promise((resolve, reject) => {
      const mid = ++seq
      pending.set(mid, resolve)
      ws.send(JSON.stringify({ id: mid, method: 'Page.navigate', params: { url: pageUrl } }))
      setTimeout(() => { if (pending.has(mid)) { pending.delete(mid); reject(new Error('timeout navigate')) } }, 15000)
    })
    for (;;) {
      try {
        const res = await evaluate('document.title')
        title = res?.result?.result?.value || ''
      } catch { /* reintenta */ }
      if (CRE.test(title)) break
      if (Date.now() - t0 > TIMEOUT) throw new Error(`timeout esperando resumen QUNIT ${scope} (último title: ${JSON.stringify(title)})`)
      await sleep(1000)
    }
  } finally {
    try { ws.close() } catch { /* cierre best-effort */ }
    try { await fetch(`http://localhost:${cdpPort}/json/close/${id}`) } catch { /* idem */ }
  }
  console.log(title)
  const m = title.match(/(\d+) failed$/)
  process.exit(m && m[1] === '0' ? 0 : 1)
}

main().catch((e) => { console.error(`FALLO cdp-eval: ${e.message}`); process.exit(1) })
