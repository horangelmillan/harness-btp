sap.ui.define([
  "sap/ui/test/Opa5",
  "sap/ui/test/actions/Press",
  "sap/ui/test/actions/EnterText"
], function (Opa5, Press, EnterText) {
  "use strict";
  var sView = "Lista";
  Opa5.createPageObjects({
    enLista: {
      viewName: sView,
      actions: {
        voyACrear: function () {
          return this.waitFor({
            controlType: "sap.m.Button",
            matchers: { properties: { text: "Crear" } },
            actions: new Press(),
            errorMessage: "botón Crear no encontrado"
          });
        },
        abroDetalleDe: function (sTitle) {
          return this.waitFor({
            controlType: "sap.m.ColumnListItem",
            matchers: function (oItem) {
              return oItem.getCells()[0].getText() === sTitle;
            },
            actions: new Press(),
            errorMessage: "fila con título " + sTitle + " no encontrada"
          });
        }
      },
      assertions: {
        veoFilaCon: function (sTitle) {
          return this.waitFor({
            controlType: "sap.m.ColumnListItem",
            matchers: function (oItem) {
              return oItem.getCells()[0].getText() === sTitle;
            },
            success: function () { Opa5.assert.ok(true, "fila visible: " + sTitle); },
            errorMessage: "fila con título " + sTitle + " no visible"
          });
        },
        noVeoFilaCon: function (sTitle) {
          // Sobre la tabla (no sobre filas): si la vista Lista aún no
          // cargó, el waitFor espera; si cargó, exige ausencia del título.
          // Buscar filas sueltas falla cuando ya no queda ninguna (el
          // pipeline OPA se salta sin controles y expira el timeout).
          return this.waitFor({
            controlType: "sap.m.Table",
            viewName: "Lista",
            check: function (aTables) {
              if (aTables.length === 0) { return false; }
              return aTables[0].getItems().every(function (oItem) {
                var aCells = oItem.getCells();
                return aCells.length === 0 || aCells[0].getText() !== sTitle;
              });
            },
            success: function () { Opa5.assert.ok(true, "fila ausente: " + sTitle); },
            errorMessage: "fila con título " + sTitle + " aún visible"
          });
        }
      }
    },
    enCrear: {
      viewName: "Crear",
      actions: {
        creoLibro: function (sTitle, iStock) {
          return this.waitFor({
            id: "title",
            viewName: "Crear",
            actions: new EnterText({ text: sTitle }),
            success: function () {
              this.waitFor({
                id: "stock",
                viewName: "Crear",
                actions: new EnterText({ text: String(iStock) }),
                success: function () {
                  this.waitFor({
                    controlType: "sap.m.Button",
                    matchers: { properties: { text: "Crear (POST)" } },
                    actions: new Press(),
                    errorMessage: "botón Crear (POST) no encontrado"
                  });
                },
                errorMessage: "input stock no encontrado"
              });
            },
            errorMessage: "input title no encontrado"
          });
        }
      },
      assertions: {
        veoVistaCrear: function () {
          return this.waitFor({
            id: "title",
            viewName: "Crear",
            success: function () { Opa5.assert.ok(true, "vista Crear visible"); },
            errorMessage: "vista Crear no cargó"
          });
        }
      }
    },
    enDetalle: {
      viewName: "Detalle",
      actions: {
        cambioStockA: function (iStock) {
          return this.waitFor({
            id: "stock",
            viewName: "Detalle",
            actions: new EnterText({ text: String(iStock) }),
            success: function () {
              this.waitFor({
                controlType: "sap.m.Button",
                matchers: { properties: { text: "Guardar stock (PATCH)" } },
                actions: new Press(),
                errorMessage: "botón Guardar no encontrado"
              });
            },
            errorMessage: "input stock no encontrado"
          });
        },
        eliminoLibro: function () {
          return this.waitFor({
            controlType: "sap.m.Button",
            matchers: { properties: { text: "Eliminar (DELETE)" } },
            actions: new Press(),
            errorMessage: "botón Eliminar no encontrado"
          });
        }
      },
      assertions: {
        veoTitulo: function (sTitle) {
          return this.waitFor({
            id: "title",
            viewName: "Detalle",
            matchers: { properties: { text: sTitle } },
            success: function () { Opa5.assert.ok(true, "detalle muestra: " + sTitle); },
            errorMessage: "detalle sin título " + sTitle
          });
        },
        veoStock: function (iStock) {
          return this.waitFor({
            id: "stock",
            viewName: "Detalle",
            matchers: function (oInput) { return String(oInput.getValue()) === String(iStock); },
            success: function () { Opa5.assert.ok(true, "stock visible: " + iStock); },
            errorMessage: "stock " + iStock + " no visible"
          });
        }
      }
    }
  });
});
