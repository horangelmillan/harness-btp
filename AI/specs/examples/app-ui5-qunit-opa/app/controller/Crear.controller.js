sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/m/MessageBox",
  "sap/m/MessageToast"
], function (Controller, MessageBox, MessageToast) {
  "use strict";
  return Controller.extend("qunit.books.controller.Crear", {
    onNavBack: function () {
      this.getOwnerComponent().getRouter().navTo("lista");
    },
    onCrear: async function () {
      var oErrText = this.byId("error");
      var sTitle = (this.byId("title").getValue() || "").trim();
      var vStock = this.byId("stock").getValue();
      // Validación cliente mínima; la autoridad es el servidor (400 si falla).
      if (!sTitle) {
        oErrText.setText("Título obligatorio (validación cliente)");
        oErrText.setVisible(true);
        return;
      }
      if (vStock === "" || isNaN(Number(vStock)) || !Number.isInteger(Number(vStock)) || Number(vStock) < 0) {
        oErrText.setText("Stock debe ser entero ≥ 0 (validación cliente)");
        oErrText.setVisible(true);
        return;
      }
      oErrText.setVisible(false);
      try {
        var oList = this.getView().getModel().bindList("/Books");
        var oCtx = oList.create({ title: sTitle, stock: Number(vStock) });
        await oCtx.created();
        MessageToast.show("Creado (POST 201)");
        this.getOwnerComponent().getRouter().navTo("detalle", { ID: oCtx.getProperty("ID") });
      } catch (oErr) {
        var s = (oErr && (oErr.status || (oErr.error && oErr.error.status))) || "?";
        oErrText.setText("Error POST (" + s + "): el servidor manda");
        oErrText.setVisible(true);
        MessageBox.error("No se pudo crear (" + s + ")");
      }
    }
  });
});
