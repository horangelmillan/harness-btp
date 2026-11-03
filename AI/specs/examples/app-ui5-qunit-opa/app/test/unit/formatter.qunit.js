/*global QUnit*/
sap.ui.define(["qunit/books/model/formatter"], function (formatter) {
  "use strict";
  QUnit.module("formatter: filtro contains(title)");
  QUnit.test("query simple genera $filter válido", function (assert) {
    assert.strictEqual(
      formatter.containsFilter("title", "QUnit"),
      "$filter=contains(title,'QUnit')",
      "filtro esperado");
  });
  QUnit.test("comilla simple se escapa (OData '')", function (assert) {
    assert.strictEqual(
      formatter.containsFilter("title", "l'arbre"),
      "$filter=contains(title,'l''arbre')",
      "escape OData");
  });
  QUnit.test("query vacía genera contains vacío", function (assert) {
    assert.strictEqual(
      formatter.containsFilter("title", ""),
      "$filter=contains(title,'')",
      "sin query");
  });

  QUnit.module("formatter: formatError distingue 400/404");
  QUnit.test("400 dato inválido", function (assert) {
    assert.ok(formatter.formatError({ status: 400 }).indexOf("400") !== -1, "400 visible");
  });
  QUnit.test("404 anidado en error.error", function (assert) {
    assert.ok(formatter.formatError({ error: { status: 404 } }).indexOf("404") !== -1, "404 visible");
  });
  QUnit.test("estado desconocido no miente", function (assert) {
    assert.strictEqual(formatter.formatError({}), "Error ?", "sin estado");
  });

  QUnit.module("formatter: stockState (semáforo)");
  QUnit.test("0 → Error, 1-4 → Warning, ≥5 → Success", function (assert) {
    assert.strictEqual(formatter.stockState(0), "Error", "cero");
    assert.strictEqual(formatter.stockState(3), "Warning", "bajo");
    assert.strictEqual(formatter.stockState(5), "Success", "ok");
    assert.strictEqual(formatter.stockState(99), "Success", "alto");
  });
  QUnit.test("negativo/no-entero → None (no clasifica)", function (assert) {
    assert.strictEqual(formatter.stockState(-1), "None", "negativo");
    assert.strictEqual(formatter.stockState(2.5), "None", "decimal");
    assert.strictEqual(formatter.stockState("mucho"), "None", "texto");
  });
});
