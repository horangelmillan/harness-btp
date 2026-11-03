# Plantilla de especificación de MVP

Copiar a `specs/<nombre-mvp>.md` y rellenar. Lo marcado con (*) es
indispensable para avanzar; el resto puede quedar en `TBD` y el orquestador
lo resolverá o lo pedirá en la etapa 0.

## 1. Identificación (*)

- **Nombre del MVP:**
- **Objetivo (1–2 frases):**
- **Tipo:** [UI5 freestyle / Fiori Elements / CAP + UI5 / solo servicio CAP / MTA Java / TBD]
- **Repositorio:** [nuevo local / existente: ruta / remoto: URL o TBD]
- **Harness BTP:** [versión de `AI/VERSION` al abrir el MVP, p. ej. `0.3.2`; el orquestador la copia en etapa 0 y la actualiza si hace upgrade]

## 2. Destino SAP BTP (* antes del despliegue)

- **Endpoint API:**
- **Organización:**
- **Espacio:**
- **Servicios necesarios (plan si se conoce):** p. ej. XSUAA, HANA Cloud, HTML5 Repo, Destination
- **Destino/consumo (si aplica, ver `AI/docs/destination-approuter-checklist.md`):** [nombre destino / `TODO(<paisaje>)` si URL desconocida]
- **Seguridad (si aplica, ver `AI/docs/xs-security-checklist.md`):** [roles/scopes o TBD]
- **MTA (si aplica):** [`managed-service` vs `existing-service`, `.mtaext` por paisaje]

## 3. Alcance funcional (*)

- **Usuarios y roles:**
- **Historias / funciones (lista breve):**
- **Fuera de alcance explícito:**

## 4. Criterios de aceptación (*)

- [ ] Criterio 1 verificable (comando, URL o comportamiento observable)
- [ ] …

## 5. Restricciones

- **Datos reales o sensibles:** [sí/no — por defecto: no, desarrollo con mocks]
- **Coste permitido:** [solo capa gratuita / especificar]
- **Git:** [commits locales sí/no — `push`/PR solo si se pide aquí expresamente]
- **Plazos o hitos:**

## 6. Notas y referencias

- Enlaces a docs, diseños, sistemas backend a consumir:
