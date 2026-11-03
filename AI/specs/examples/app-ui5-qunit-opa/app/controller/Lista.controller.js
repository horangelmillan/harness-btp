sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator"
], function (Controller, Filter, FilterOperator) {
  "use strict";
  return Controller.extend("qunit.books.controller.Lista", {
    onSearch: function (oEvent) {
      var sQuery = oEvent.getParameter("query") || oEvent.getParameter("newValue") || "";
      var oTable = this.byId("table");
      var oBinding = oTable.getBinding("items");
      oBinding.filter(sQuery ? [new Filter("title", FilterOperator.Contains, sQuery)] : []);
    },
    _idOf: function (oItem) {
      return oItem.getBindingContext().getProperty("ID");
    },
    onDetalle: function (oEvent) {
      var sID = this._idOf(oEvent.getSource());
      this.getOwnerComponent().getRouter().navTo("detalle", { ID: sID });
    },
    onCrear: function () {
      this.getOwnerComponent().getRouter().navTo("crear");
    }
  });
});
