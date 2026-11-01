# Habilitación del trial — guía ordenada con justificación

> Paso a paso de todo lo configurado para el laboratorio `doc-extract-lab`
> el 2026-10-29. Cada sección explica **para qué sirve**, **cómo se
> configuró**, **casos de uso** y **cuándo usarlo**. Orden cronológico real
> de ejecución: seguirlo en este orden evita los errores que encontramos
> (p. ej. suscribir Document AI antes de tener IAS falla con `422`).

## Paso 0. Verificar el entorno Cloud Foundry (lectura, sin cambios)

- **Para qué sirve.** Confirma contra qué org/espacio desplegará el MTA.
- **Cómo.** En el equipo local: `cf target` (endpoint, org, espacio).
- **Casos de uso / cuándo.** Antes de cada despliegue y siempre que el
  cockpit muestre un espacio con otro nombre (aquí: cockpit `dev` frente a
  la sesión local). Si no coinciden, se ajusta el target en la puerta de
  despliegue; nunca se despliega "a ver qué pasa".

## Paso 1. Instancia HTML5 Application Repository (`HTML5_service`)

- **Para qué sirve.** Repositorio central de frontends HTML5 del espacio CF:
  versiona los bundles UI5, los sirve con caché y rutas estables, y los
  publica en la sección **HTML5 Applications** del cockpit.
- **Cómo se configuró.** Subcuenta `trial` → Services → Service Marketplace
  → `HTML5 Application Repository Service` → Create → Plan **`app-host`** →
  Runtime **Cloud Foundry** → Space **`dev`** → nombre `HTML5_service`.
- **Casos de uso.** Cualquier frontend Fiori/UI5 que deba vivir en el
  cockpit y servirse vía App Router.
- **Cuándo usarlo.** Siempre que la app tenga UI propia (este MVP: CA5). Si
  el MVP fuera solo API, se omite.

## Paso 2. Instancia XSUAA (`XSUAA_service`)

- **Para qué sirve.** Broker OAuth2 propio de la aplicación: emite los JWT
  con que el App Router crea la sesión de usuario y que el backend CAP
  valida (`xsappname`, scopes).
- **Cómo se configuró.** Service Marketplace → `Authorization and Trust
  Management Service` → Create → Plan **`application`** → CF → `dev` →
  nombre `XSUAA_service`.
- **Por qué `application`.** `broker` es para multi-tenant con tenant
  dinámico, `apiaccess` para API sin sesión de usuario, `space` delega en el
  espacio: ninguno sirve al App Router gestionado.
- **Casos de uso / cuándo.** Toda app con login de usuarios o propagación de
  identidad al backend. Se omite solo en MVPs 100 % anónimos o batch.

## Paso 3. Instancia Document AI (`DAI_service`)

- **Para qué sirve.** API REST de extracción de datos desde documentos
  (PDF, imágenes): recibe el archivo y devuelve JSON con los campos del
  esquema entrenado.
- **Cómo se configuró.** Service Marketplace → `SAP Document AI Trial` →
  Create → Plan **`default`** (gratuito del trial) → CF → `dev` → nombre
  `DAI_service`. Estado final: `Usable`.
- **Por qué `default` y no `blocks_of_100`.** `blocks_of_100` consume
  créditos de la cuenta; `default` respeta la restricción "solo trial".
- **Casos de uso.** Facturas, remitos, formularios: cualquier documento
  semiestructurado del que haya que extraer campos.
- **Cuándo usarlo.** Cuando el volumen o la variabilidad de documentos hacen
  inviable la carga manual o plantillas fijas.

## Paso 4. Suscripción a la app `SAP Document AI`

- **Para qué sirve.** UI de gestión: crear/entrenar esquemas de extracción y
  probar con documentos de ejemplo. La **instancia** (paso 3) da la API; la
  **suscripción** da la consola.
- **Cómo se configuró.** Service Marketplace → `SAP Document AI` →
  suscripción directa (plan `default`). **Falló al inicio** con `422 OIDC
  trust missing` porque no existía tenant IAS → se resolvió tras los pasos
  6–7 y reintento.
- **Casos de uso / cuándo.** Siempre que se usen esquemas propios o haya que
  inspeccionar resultados fuera del código. Si solo se consume un esquema
  estándar vía API, es opcional.

## Paso 5. Suscripción a Integration Suite (plan `trial`)

- **Para qué sirve.** Plataforma de integración: aquí vive el iFlow que
  recibe el JSON extraído y simula la entrega al S/4HANA inexistente.
- **Cómo se configuró.** Service Marketplace → `Integration Suite` → plan
  **`trial`** → suscribir. Estado final: `Subscribed`.
- **Casos de uso.** Conectar el MVP con sistemas SAP/no-SAP, transformar
  mensajes, exponer APIs gestionadas.
- **Cuándo usarlo.** Cuando el flujo sale del BTP hacia otro sistema. Si el
  MVP fuera autocontenido, se omite (o se deja como mock documentado).

## Paso 6. Suscripción a Cloud Identity Services (tenant IAS)

- **Para qué sirve.** Crea el **tenant IAS propio** de la subcuenta: el
  proveedor de identidad de los usuarios de negocio (login, grupos,
  federación). Sin él, ninguna suscripción a aplicación con login funciona.
- **Cómo se configuró.** Service Marketplace → `Cloud Identity Services` →
  Create → Plan **`default` de la sección Subscriptions**
  (`sap-identity-services-onboarding`, NO `application` de Instances) →
  parámetro **Service type: `TEST`** → Create → **activar la cuenta con el
  email** que llega al admin (definir contraseña) → consola admin abierta.
- **Casos de uso.** Login de usuarios en Fiori, Work Zone y cualquier app
  suscrita; base para federar con un IdP corporativo más adelante.
- **Cuándo usarlo.** Antes de suscribir la primera aplicación con usuarios
  (paso 7). Es prerrequisito, no opcional.

## Paso 7. Establecer confianza (Establish Trust) y reintentar

- **Para qué sirve.** Vincula la subcuenta con el tenant IAS vía **OpenID
  Connect**, para que las apps deleguen el login en él. (SAML no vale para
  Document AI.)
- **Cómo.** Subcuenta → Security → Trust Configuration → **Establish
  Trust** → Choose Tenant: ya aparece el tenant creado en el paso 6 →
  completar el wizard → luego Instances and Subscriptions → `SAP Document
  AI` → `...` → **Retry** hasta `Subscribed`.
- **Cuándo.** Una vez por subcuenta, tras el paso 6 y antes de usar
  cualquier app suscrita.
- **Estado 2026-10-29: resuelto.** Trust `Active` (origen `sap.custom`,
  dominio `Default`); suscripción `SAP Document AI` en `Subscribed`.

## Concepto clave: usuarios de plataforma frente a usuarios de negocio

El trial te da un **usuario de plataforma** (tu login, p. ej. el `HM` del
cockpit): administra la cuenta global —cockpit, `cf`, crear
instancias— autenticado por el IdP por defecto de SAP. Ese usuario **no**
sirve para entrar a las aplicaciones desplegadas.

Los **usuarios de negocio** son quienes usan las apps (consola de Document
AI, tu Fiori vía App Router): se autentican contra un **tenant IAS** en el
que la subcuenta confía (pasos 6–7). Por eso hizo falta crear el tenant
aunque ya tuvieras usuario: son dos poblaciones distintas con dos IdP
distintos.

**Cuándo es pertinente crear el tenant IAS y la confianza:**

- Siempre que suscribas una **aplicación con login** (Document AI,
  Work Zone, cualquier SaaS del marketplace).
- Siempre que tu app propia autentique usuarios (App Router + XSUAA con
  `application` delega el login en este trust).
- Cuando necesites **roles y grupos de negocio** separados de los
  administradores de plataforma.
- En productiva, además: para **federar tu IdP corporativo** (Azure AD,
  etc.) como fuente de usuarios sin crearlos uno a uno.

**Cuándo NO hace falta:** MVPs de solo API con llaves de servicio, jobs
batch sin usuarios, o pruebas de conectividad máquina a máquina — ahí basta
con instancias y service keys.

## Paso 8 (siguiente, aún no hecho). Role collections del usuario

- **Para qué sirve.** Autorizar a tu usuario en cada servicio (DIE,
  Integration Suite, HTML5 Repo): sin roles, el acceso da 403 aunque todo lo
  anterior esté verde.
- **Cómo (cuando toque).** Subcuenta → Security → Users → tu usuario →
  asignar las role collections de cada servicio; o crear role collections a
  medida. Se hará durante el `/flow` si algún acceso falla.
- **Cuándo.** Después del despliegue o al primer 403.
- **Incidencia 2026-10-29 (Integration Suite):** `Go to Application`
  devuelve página en blanco `.../is-landing/v1.0/unauthorized` → falta
  asignar `Integration_Provisioner` al usuario antes de `Add Capabilities`.
  Si persiste tras asignarlo: (1) esperar 5–10 min por propagación y
  reentrar en incógnito (token viejo en caché); (2) asignar el rol al
  usuario de origen `sap.custom` (IAS), no solo al `sap.default` — la app
  autentica contra el trust IAS; (3) comprobar que el usuario exista en la
  consola IAS.

## Mapa rápido decisión

| Mi MVP necesita… | Habilitar |
|---|---|
| UI Fiori en el cockpit | Pasos 0, 1 (+ 2 para login) |
| Login / identidad propagada | Pasos 2, 6, 7 |
| Extraer datos de documentos | Pasos 3 (+ 4 para consola) |
| Salir hacia otro sistema | Paso 5 |
| Solo API sin UI ni usuarios | Solo 0 (+ 3/5 según el caso) |
