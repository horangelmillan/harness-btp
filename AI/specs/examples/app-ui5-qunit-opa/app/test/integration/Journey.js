/*global QUnit*/
sap.ui.define([
  "sap/ui/test/Opa5",
  "sap/ui/test/opaQunit",
  "qunit/books/test/integration/pages"
], function (Opa5) {
  "use strict";
  var sTitle = "OPA-" + Date.now().toString(36);

  Opa5.extendConfig({
    arrangements: new Opa5({
      arrancoApp: function () {
        return this.iStartMyUIComponent({
          componentConfig: { name: "qunit.books" },
          hash: ""
        });
      }
    }),
    viewNamespace: "qunit.books.view.",
    autoWait: true
  });

  QUnit.module("journey CRUD Books");

  opaTest("carga → lista", function (Given, When, Then) {
    Given.arrancoApp();
    Then.waitFor({
      controlType: "sap.m.Table",
      success: function () { Opa5.assert.ok(true, "tabla lista cargó"); },
      errorMessage: "la tabla de la lista no cargó"
    });
  });

  opaTest("crear (POST) → detalle del nuevo", function (Given, When, Then) {
    When.enLista.voyACrear();
    Then.enCrear.veoVistaCrear();
    When.enCrear.creoLibro(sTitle, 3);
    Then.enDetalle.veoTitulo(sTitle);
  });

  opaTest("editar stock (PATCH) → persiste", function (Given, When, Then) {
    When.enDetalle.cambioStockA(7);
    Then.enDetalle.veoStock(7);
  });

  opaTest("eliminar (DELETE) → lista sin el ID", function (Given, When, Then) {
    When.enDetalle.eliminoLibro();
    Then.enLista.noVeoFilaCon(sTitle);
    Then.iTeardownMyApp();
  });
});
