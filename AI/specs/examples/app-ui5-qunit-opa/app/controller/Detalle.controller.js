sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/m/MessageBox",
  "sap/m/MessageToast"
], function (Controller, MessageBox, MessageToast) {
  "use strict";
  // Autoridad: el servidor valida tipos/existencia (400/404). Aquí solo
  // comprobación mínima de formato antes de enviar.
  function statusOf(oErr) {
    var s = oErr && oErr.status !== undefined ? oErr.status
      : oErr && oErr.error && oErr.error.status;
    return Number(s) || 0;
  }
  return Controller.extend("qunit.books.controller.Detalle", {
    onInit: function () {
      this.getOwnerComponent().getRouter()
        .getRoute("detalle").attachPatternMatched(this._onMatched, this);
    },
    _onMatched: function (oEvent) {
      var sID = oEvent.getParameter("arguments").ID;
      var oView = this.getView();
      var oErr = this.byId("error");
      oErr.setVisible(false);
      oView.unbindElement();
      oView.bindElement("/Books(" + sID + ")");
      try {
        oView.getElementBinding().getBoundContext().requestObject().then(
          function () { oErr.setVisible(false); },
          function () {
            oErr.setText("Libro no existe (404): el servidor manda");
            oErr.setVisible(true);
          });
      } catch (e) {
        oErr.setText("Libro no existe (404): el servidor manda");
        oErr.setVisible(true);
      }
    },
    onNavBack: function () {
      this.getOwnerComponent().getRouter().navTo("lista");
    },
    onGuardar: async function () {
      var oView = this.getView();
      var oModel = oView.getModel();
      var oCtx = oView.getBindingContext();
      var oErrText = this.byId("error");
      if (!oCtx) { MessageToast.show("Sin contexto: recarga la lista"); return; }
      var v = this.byId("stock").getValue();
      if (v === "" || isNaN(Number(v)) || Number(v) < 0 || !Number.isInteger(Number(v))) {
        oErrText.setText("Stock debe ser entero ≥ 0 (validación cliente)");
        oErrText.setVisible(true);
        return;
      }
      oCtx.setProperty("stock", Number(v));
      try {
        await oModel.submitBatch("$auto");
        oErrText.setVisible(false);
        MessageToast.show("Stock actualizado (PATCH)");
      } catch (oErr) {
        var s = statusOf(oErr);
        oErrText.setText("Error PATCH (" + (s || "?") + "): el servidor manda");
        oErrText.setVisible(true);
        if (s === 404) { MessageBox.error("Libro no existe (404)"); }
      }
    },
    onEliminar: async function () {
      var oCtx = this.getView().getBindingContext();
      if (!oCtx) { return; }
      try {
        await oCtx.delete("$auto");
        MessageToast.show("Eliminado (DELETE 204)");
        // La vista Lista queda en caché del App: refresco explícito para
        // que la tabla ya no muestre la fila eliminada al volver.
        this.getOwnerComponent().getModel().refresh();
        this.getOwnerComponent().getRouter().navTo("lista");
      } catch (oErr) {
        MessageBox.error("No se pudo eliminar (" + (statusOf(oErr) || "?") + ")");
      }
    }
  });
});
