sap.ui.define([], function () {
  "use strict";
  // Lógica pura espejo de los controllers (sin fetch, sin UI5 salvo el
  // wrapper define): genera el $filter de Lista y clasifica errores
  // HTTP de Detalle/Crear. Si cambia un controller, cambiar aquí + test.
  function esc(s) { return String(s).replace(/'/g, "''"); }
  function containsFilter(field, q) {
    return "$filter=contains(" + field + ",'" + esc(q) + "')";
  }
  function formatError(oErr) {
    var s = (oErr && (oErr.status || (oErr.error && oErr.error.status))) || 0;
    if (Number(s) === 400) { return "Error 400: dato inválido (manda el servidor)"; }
    if (Number(s) === 404) { return "Error 404: no existe (manda el servidor)"; }
    return "Error " + (s || "?");
  }
  function stockState(v) {
    var n = Number(v);
    if (!Number.isInteger(n) || n < 0) { return "None"; }
    if (n === 0) { return "Error"; }
    if (n < 5) { return "Warning"; }
    return "Success";
  }
  return {
    containsFilter: containsFilter,
    formatError: formatError,
    stockState: stockState
  };
});
