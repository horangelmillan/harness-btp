---
name: sap-verify
description: Clasificar disponibilidad, cuenta y coste de servicios SAP/BTP
---

# Verificación de dependencias externas SAP

Toda afirmación sobre un servicio, plan, API o capacidad BTP se clasifica en
una de estas categorías, con fuente y fecha:

| Categoría | Significado |
|---|---|
| **Documentado** | Docs oficiales vigentes + evidencia (comando, consola o enlace con fecha). |
| **Pendiente en cuenta** | Existe en docs pero sin comprobar en la subcuenta/destino real. |
| **Coste por cotizar** | Requiere plan de pago o métrica no verificada; no activar sin confirmación. |

## Reglas

- Desarrollo local y mocks primero; servicios reales solo con evidencia.
- Distinguir Windows local frente a BAS/dev space remoto: una instalación o
  capacidad de un lado no implica la del otro.
- No afirmar que una integración está aprobada o disponible hasta comprobarla
  con documentación y accesos vigentes.
- Costes: antes de activar cualquier recurso con coste, verificar precio y
  documentarlo en la spec; capa gratuita por defecto.
- Bloqueos externos no paran el MVP: documentar evidencia y continuar con
  mocks o adaptador local.
- Seguridad: todo scope usado en código o rutas `xs-app.json` debe existir en
  `AI/docs/xs-security-checklist.md` / `xs-security.json` del MVP.
