# Checklist Dialog trazabilidad / JSON (doc-extract-lab 2026-11-01)
1. Modelo: `oDialog.setModel(oTrace,"trace")` → leer de `oDialog.getModel("trace")` con fallback a la vista; nunca `this.getView().getModel("trace")` solo.
2. Apertura: `oDialog.open()` ANTES de `oDialog.setBusy(true)`; cerrar con `try/finally { setBusy(false) }` (blocklayer huérfano si se invierte).
3. Tabla: poblar solo con `bindItems(path, template)`; `itemsTemplate` NO es setting válido del constructor de `sap.m.Table`.
4. Layout Dialog: content = un `VBox` contenedor + clase `sapUiSmallMargin`; secciones con `Title level=H4`; `Label+Text` nunca como hijos planos (fluyen inline).
5. JSON largo: `sap.m.TextArea wrapping="Soft" editable="false"`; VBox con márgenes SIN `width:"100%"` (desborda +16px); verificar `scrollWidth<=clientWidth` en E2E.
6. Vista única Fiori: si hay `DynamicPageTitle`, `Page showHeader="false"` (evita título duplicado i18n).
