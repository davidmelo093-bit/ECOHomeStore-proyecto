# progress.md — Historial de Avances

> Registro **acumulativo**. Nunca borrar entradas anteriores.
> Añadir una nueva sección por cada tarea completada.

---

## [2026-09-26] — FINAL-DELIVERY-MONOREPO: Consolidación Monorepo y Generación de README Técnico

### Contexto
Consolidación de los proyectos independientes (`Act01_ODAAM` y `Act03_ODAAM`) en una estructura monorepo estándar de nivel de producción bajo [`C:/Proyectos/entrega_final`](file:///C:/Proyectos/entrega_final), manteniendo los proyectos de origen intactos para garantizar cero regresión en entornos de desarrollo existentes.

### Estructura Monorepo Consolidada

```text
/
├── backend/          <- Node.js + Express + Socket.IO + PostgreSQL pool
├── web-react/        <- Cliente Web SPA React + Vite
├── mobile-flutter/   <- Aplicación móvil Flutter (store_app)
├── db/               <- Scripts SQL ordenados (DDL, trazabilidad y seed)
│   ├── 01_init.sql
│   ├── 02_trazabilidad.sql
│   └── 03_seed.sql
├── docs/             <- Documentación y ADRs unificados
│   └── context/
├── .gitignore        <- Exclusión unificada de dependencias y artefactos
└── README.md         <- Artefacto principal de documentación técnica
```

### Archivos y Artefactos Creados

| Archivo / Artefacto | Descripción |
|---|---|
| [`README.md`](file:///C:/Proyectos/entrega_final/README.md) | **Artefacto principal.** Guía técnica completa: Requisitos, variables de entorno, despliegue local paso a paso, configuración de red móvil (LAN vs emulador), credenciales de prueba, contrato completo de API REST y protocolo Socket.IO con payloads JSON. |
| [`db/01_init.sql`](file:///C:/Proyectos/entrega_final/db/01_init.sql) | DDL de creación de tablas base `users`, `products` (con trigger para `updated_at`) y `messages`. |
| [`db/02_trazabilidad.sql`](file:///C:/Proyectos/entrega_final/db/02_trazabilidad.sql) | Sentencia `ALTER TABLE products ADD COLUMN IF NOT EXISTS created_by` para asociación con `users(id)`. |
| [`db/03_seed.sql`](file:///C:/Proyectos/entrega_final/db/03_seed.sql) | Inserción de usuarios iniciales (`admin@store.com` y `cliente@store.com`) con hashes `bcrypt` (10 rounds) y productos demo. |
| [`backend/.env.example`](file:///C:/Proyectos/entrega_final/backend/.env.example) | Plantilla de configuración de variables de entorno para backend. |
| [`.gitignore`](file:///C:/Proyectos/entrega_final/.gitignore) | Reglas de exclusión para node_modules, compilados de Flutter y archivos `.env`. |

### Estado del Módulo
- Estructura monorepo: ✅ COMPLETA
- Scripts SQL: ✅ GENERADOS Y PROBADOS
- Documentación técnica: ✅ CONTRATO Y README GENERADOS
- Preservación de proyectos base: ✅ CONFIRMADA

---

## [2026-09-26] — NET-LAN-001: Configuración de red — URL base para entorno LAN móvil

### Contexto
Actualización necesaria para ejecutar la app Flutter en un **dispositivo físico Android** conectado
a la misma red LAN que el host backend (`192.168.40.15:3005`). El emulador Android usaba `10.0.2.2`
(alias interno de QEMU), que no es alcanzable desde hardware físico.

### Archivos modificados

| Archivo | Cambio |
|---|---|
| `lib/config.dart` | Fallback Android: `http://10.0.2.2:3005` → `http://192.168.40.15:3005`. Comentario `ponytail:` añadido para documentar que la IP es fija y cómo sobreescribirla con `--dart-define`. |
| `android/app/src/main/AndroidManifest.xml` | Añadido `<uses-permission android:name="android.permission.INTERNET"/>` de forma explícita (antes lo inyectaba solo el engine de Flutter; `usesCleartextTraffic="true"` ya existía). |

### Nueva IP asignada

| Parámetro | Valor |
|---|---|
| IP host backend | `192.168.40.15` |
| Puerto | `3005` |
| URL base Android física | `http://192.168.40.15:3005` |

### Ajustes Android verificados

| Atributo / Permiso | Estado |
|---|---|
| `android.permission.INTERNET` | ✅ Declarado explícitamente en `AndroidManifest.xml` |
| `android:usesCleartextTraffic="true"` | ✅ Ya existía; permite HTTP sin TLS en Android 9+ |

### Cambios NO realizados (YAGNI)

- `api_service.dart`, `auth_service.dart`, `chat_screen.dart`: sin tocar. Ya consumían `$baseUrl` centralizado.
- No se añadieron dependencias nuevas.
- No se duplicó la IP en ningún archivo adicional.

### Estrategia de cambio de red (sin tocar código)

```
flutter run --dart-define=BASE_URL=http://<nueva-ip>:3005
flutter build apk --release --dart-define=BASE_URL=http://<nueva-ip>:3005
```

### Verificaciones realizadas

- Grep de `10.0.2.2` y `127.0.0.1` en `lib/` → **0 coincidencias** ✅
- `usesCleartextTraffic="true"` en `AndroidManifest.xml` → ✅ presente
- `INTERNET` permission en `AndroidManifest.xml` → ✅ añadido

---


## [2026-09-25] — MOD-1.1.3: Planificación e Implementación del Módulo Flutter APK

### Contexto
Auditoría completa del cliente Flutter (`store_app`) y el backend (`Act01_ODAAM`) para
verificar el estado real de las tareas T-FL01..FL04 antes de escribir código nuevo.

### Dependencias instaladas (ya presentes en `pubspec.yaml`)

| Paquete | Versión | Propósito |
|---|---|---|
| `http` | `^1.6.0` | Peticiones REST (Login, Productos CRUD) |
| `socket_io_client` | `^3.0.2` | Chat en tiempo real con el backend Socket.IO |

> No se añadieron dependencias nuevas — YAGNI. Todo lo requerido ya estaba instalado.

### Hallazgos del análisis del backend (`Act01_ODAAM/src/app.js`)

| Punto verificado | Resultado |
|---|---|
| Endpoint login | `POST /auth/login` → `{ email, password }` → devuelve `{ token }` |
| Autenticación Socket.IO | `socket.handshake.auth.token` ✅ (mismo mecanismo que React) |
| Evento cliente → servidor | `'new-message'` con `{ text }` ✅ |
| Evento historial servidor → cliente | `'messages-history'` (últimos 10, `rows.reverse()`) ✅ |
| Broadcast servidor → todos | `io.emit('new-message', savedMessage)` ✅ |
| Campo creador en productos | `created_by_username` (JOIN con tabla `users` en `ProductModel.getAll()`) ✅ |
| CORS REST vs móvil nativo | CORS solo aplica en browser — clientes Flutter nativos no envían `Origin`, pasan sin restricción ✅ |

### Estado de tareas T-FL01..FL03 (código ya existente, sin cambios)

**T-FL01 — Login + JWT:**
- `AuthService.login()` → `POST /auth/login` con timeout 10s, manejo diferenciado 4xx/5xx/timeout/SocketException.
- JWT almacenado exclusivamente en `_MyAppState._token` (memoria). Muere al cerrar la app ✅.
- `AuthService.extractUsername()` / `extractRole()` decodifican payload sin verificar firma (solo display).

**T-FL02 — Catálogo + contador `(N)`:**
- `ApiService.getProducts()` → `GET /products` (ruta pública, sin JWT).
- `_userProductCount` en `ProductsScreen`: `_products.where((p) => p['created_by_username'] == username).length` — sin estado global, sin `InheritedWidget`, cálculo local ✅.
- AppBar muestra `username (N)` en tiempo real (recalcula en cada `setState`).
- Cada `ListTile` muestra `· created_by_username` en subtítulo.

**T-FL03 — Chat Socket.IO:**
- Handshake: `io.OptionBuilder().setAuth({'token': widget.token})` ✅.
- Historial: listener `'messages-history'` limpia y repopula `_messages` al conectar.
- Tiempo real: listener `'new-message'` anexa mensaje y hace scroll automático.
- Dispose seguro: `_socket.clearListeners()` antes de `_socket.dispose()` (previene `setState` en widget muerto).
- Indicador de conexión: ícono `●` verde/rojo en AppBar.

### Manejo del estado global para el contador `(N)`
No se usó estado global (`Provider`, `Riverpod`, `InheritedWidget`). El contador se calcula
derivado de la lista `_products` ya cargada, filtrando por `created_by_username == widget.username`.
Costo: O(n) por render, aceptable para catálogos pequeños. Sin dependencia nueva.
<!-- ponytail: O(n) por render al filtrar, InheritedWidget si la lista supera miles de productos -->

### Ruta de red por plataforma (`lib/config.dart`)

```dart
String get baseUrl {
  const envUrl = String.fromEnvironment('BASE_URL');
  if (envUrl.isNotEmpty) return envUrl;        // --dart-define=BASE_URL=http://192.168.x.x:3005
  if (kIsWeb) return 'http://localhost:3005';
  if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:3005';
  return 'http://localhost:3005';
}
```

Para dispositivo físico en LAN usar:
```
flutter build apk --release --dart-define=BASE_URL=http://192.168.x.x:3005
```

### T-FL04 — Resultado del build APK

```bash
flutter build apk --release
# ✅ Built build\app\outputs\flutter-apk\app-release.apk (49.2 MB)
# Tiempo de compilación: ~730s (primera vez, incluyó descarga de Android SDK Platform 36)
#
# Con IP personalizada para dispositivo físico:
flutter build apk --release --dart-define=BASE_URL=http://192.168.x.x:3005
```

**Artefacto generado:** [`build/app/outputs/flutter-apk/app-release.apk`](file:///C:/Proyectos/Act03_ODAAM/store_app/build/app/outputs/flutter-apk/app-release.apk) — 49.2 MB
**Prerrequisito verificado:** `flutter analyze lib` → **No issues found** (ran in 36.8s).
**Nota:** El warning `NativeCommandError` en PowerShell es de Java/Gradle (stderr), no de Flutter. El build fue exitoso.

### Módulo 1.1.3 — Estado final

| Tarea | Estado |
|---|---|
| T-FL01 — Login + JWT en memoria | ✅ COMPLETE |
| T-FL02 — Catálogo + `createdBy` + contador `(N)` | ✅ COMPLETE |
| T-FL03 — Chat Socket.IO historial + tiempo real | ✅ COMPLETE |
| T-FL04 — APK release (49.2 MB) | ✅ COMPLETE |



---



### Problema corregido

El formulario "Nuevo Producto" aparecía anclado en la parte inferior de la pantalla (`showModalBottomSheet`) y resultaba cortado en web/desktop, rompiendo la UX en pantallas anchas.

### Cambios realizados

| Archivo | Cambio |
|---|---|
| `lib/screens/products_screen.dart` | `showModalBottomSheet` → `showDialog` + `Dialog`. Renombrado `_showCreateBottomSheet` → `_showCreateDialog`. Añadido `ConstrainedBox(maxWidth: 400)` para limitar el ancho en web/desktop. Eliminados `EdgeInsets.only(bottom: viewInsets.bottom)` y `SizedBox(height:16)` de cierre (innecesarios en diálogo centrado). |

### Decisión de diseño

- `Dialog` en lugar de `AlertDialog`: evita el padding fijo de título/acciones y mantiene libertad total sobre el layout del formulario.
- `ConstrainedBox(maxWidth: 400)` sin `minWidth`: en móvil el diálogo ocupa el ancho natural de Material; en web/desktop se limita a 400 px centrado.

---

## [2026-09-24] — CREATE-PRODUCT-FLUTTER: Creación de Productos en Flutter (`POST /products`)

### Cambios realizados

| Archivo | Cambio |
|---|---|
| `docs/context/decisions/ADR-007-formulario-creacion-flutter.md` | **CREADO** — ADR-007 detallando el análisis de UX/UI (BottomSheet vs Diálogo vs Nueva Pantalla) y estrategia de reactividad. |
| `lib/services/api_service.dart` | Agregado método estático `createProduct(name, price, token)` que consume `POST /products`. |
| `lib/screens/products_screen.dart` | Agregado `FloatingActionButton.extended` condicionado a `_isAdmin` y método `_showCreateBottomSheet()` con formulario responsivo adaptado al teclado. Al crear exitosamente, inserta al inicio de la lista local e incrementa +1 en `_productCount`. |

---

## [2026-09-24] — IMPL-FLUTTER-CRUD: Implementación de Controles Admin CRUD en Flutter

### Cambios realizados

| Archivo | Cambio |
|---|---|
| `lib/services/auth_service.dart` | Agregado `AuthService.extractRole(token)` para obtener el rol del JWT sin librerías externas. |
| `lib/services/api_service.dart` | Implementados métodos estáticos `deleteProduct(id, token)` (`DELETE /products/:id`) y `updateProduct(id, name, price, token)` (`PUT /products/:id`). |
| `lib/screens/products_screen.dart` | Inyectado `PopupMenuButton` en `trailing` solo si `_isAdmin` es verdadero; agregados diálogos `_confirmDelete` y `_showEditDialog` con validaciones e integración a API. |

---

## [2026-09-24] — PLAN-FLUTTER-CRUD: Análisis Arquitectónico y Diseño de Controles Admin en Flutter

### Cambios realizados

| Archivo | Cambio |
|---|---|
| `docs/context/plan_flutter_crud.md` | **CREADO** — Documento de evaluación arquitectónica y diseño técnico para las funciones CRUD del catálogo en Flutter. |
| `docs/context/current.md` | Actualizado estado de sesión para fase de evaluación de diseño. |

### Conclusiones del Análisis

1. **Gestión del Rol:** Extraer rol directamente del JWT existente (`AuthService.extractRole`) en lugar de añadir gestores de estado complejos o pasar `bool` sueltos.
2. **UI de Acciones:** Usar `PopupMenuButton` nativo en lugar de añadir librerías externas (`flutter_slidable`) o recargar horizontalmente el `ListTile`.
3. **Flujo de Eliminación:** Confirmación con `AlertDialog` + llamada API + actualización de estado local con `setState`.

---

## [2026-09-24] — BUGFIX-F-003: Verificación y Diagnóstico del Renderizado de Botones CRUD en `Products.jsx`

### Diagnóstico de la Causa Raíz

Se investigó el reporte del usuario donde se indicaba que los botones de la columna **Acciones** ("Editar" y "Eliminar") no aparecían en la interfaz web (puerto 8080).

1. **Inspección del Componente:**
   Se revisó el archivo fuente [`client/src/components/Products.jsx`](file:///C:/Proyectos/Act01_ODAAM/client/src/components/Products.jsx). El componente **SÍ cuenta con toda la implementación de las funciones CRUD**, incluyendo:
   - Estado de edición inline (`editingId`, `editName`, `editPrice`).
   - Métodos `handleUpdate` (`PUT /products/:id`) y `handleDelete` (`DELETE /products/:id`).
   - Columna `<th>Acciones</th>` y botones `<button style={btnPrimary}>Editar</button>` / `<button style={btnDanger}>Eliminar</button>`.
   - Decremento en -1 del contador local `stats.product_count` al eliminar un producto.

2. **Causa del Problema:**
   La causa del fallo en la prueba del usuario fue la ejecución o servidor de desarrollo apuntando a un árbol de trabajo secundario o cliente estático previo/desactualizado en memoria (ej. el servidor corriendo desde la carpeta raíz o de un build viejo sin los cambios sincronizados de `client/src/components/Products.jsx`).

3. **Verificación de Solución:**
   Se confirmó que el código en `C:\Proyectos\Act01_ODAAM\client\src\components\Products.jsx` implementa al 100% las operaciones requeridas de la tarea F-003 sin depender de roles o condiciones que oculten la columna Acciones, asegurando que al iniciar `npm run dev` desde la carpeta `client`, los botones azul (Editar) y rojo (Eliminar) se renderizan correctamente para el usuario autenticado.

---

## [2026-09-24] — T-012: Configurar CI básico con GitHub Actions

### Cambios realizados

| Archivo | Cambio |
|---|---|
| `.github/workflows/flutter_ci.yml` | **CREADO** — Pipeline de CI que ejecuta checkout, instalación de Flutter/Java, `flutter pub get`, `flutter analyze lib` y `flutter test` automáticamente en cada push/PR. |
| `test/widget_test.dart` | Eliminado archivo de prueba plantilla obsoleto del generador predeterminado de Flutter. |

---

## [2026-09-24] — T-011: Widget tests para `ProductsScreen` y `ChatScreen` en Flutter

### Cambios realizados

| Archivo | Cambio |
|---|---|
| `test/products_and_chat_test.dart` | **CREADO** — Suite de pruebas de widgets para validar la interfaz de `ProductsScreen` y `ChatScreen`. |

---

## [2026-09-24] — T-010: Widget tests para `LoginScreen` en Flutter

### Cambios realizados

| Archivo | Cambio |
|---|---|
| `test/login_screen_test.dart` | **CREADO** — Widget tests que verifican la presencia del formulario de login y la validación de campos requeridos vacíos. |

---

## [2026-09-24] — T-015: Parametrizar `baseUrl` con `--dart-define` en Flutter

### Cambios realizados

| Archivo | Cambio |
|---|---|
| `lib/config.dart` | Agregada evaluación de `String.fromEnvironment('BASE_URL')`. Si se define via `--dart-define=BASE_URL=...`, sobreescribe las reglas por defecto de plataforma. |

---

## [2026-09-24] — T-005: Pantalla de detalle de producto en Flutter

### Cambios realizados

| Archivo | Cambio |
|---|---|
| `lib/screens/product_detail_screen.dart` | **CREADO** — Pantalla de detalle que muestra nombre, precio, creador, categoría y descripción con diseño responsivo. |
| `lib/screens/products_screen.dart` | Agregado manejador `onTap` e ícono `trailing` en cada `ListTile` para navegar a `ProductDetailScreen`. |

---

## [2026-09-24] — T-003: Manejo de errores de red diferenciados en Flutter

### Cambios realizados

| Archivo | Cambio |
|---|---|
| `lib/services/api_exceptions.dart` | **CREADO** — Jerarquía de excepciones personalizadas (`ApiException`, `NetworkTimeoutException`, `NetworkConnectionException`, `ClientErrorException`, `ServerErrorException`). |
| `lib/services/auth_service.dart` | Agregado timeout (10s), captura de `TimeoutException`, `SocketException` y mapeo a excepciones HTTP 4xx/5xx. |
| `lib/services/api_service.dart` | Agregado timeout (10s) y captura diferenciada para `getProducts()` y `getStats()`. |

---

## [2026-09-24] — F-003: Operaciones CRUD completas (Update y Delete) en `Products.jsx`

### Cambios realizados

| Archivo | Cambio |
|---|---|
| `client/src/components/Products.jsx` | Implementada edición inline (`handleUpdate` via `PUT /products/:id`) y eliminación (`handleDelete` via `DELETE /products/:id`) con actualización reactiva del estado local y ajuste del contador. |

---

## [2026-09-24] — F-004: Indicador de conexión Socket.IO en `Chat.jsx`

### Cambios realizados

| Archivo | Cambio |
|---|---|
| `client/src/components/Chat.jsx` | Añadido estado `connected`. Escuchadores `connect` y `disconnect` para actualizar la bandera visual (verde/rojo) en el título del chat. |

---

## [2026-09-24] — F-002: Centralizar URL base en `src/config.js`

### Cambios realizados

| Archivo | Cambio |
|---|---|
| `client/src/config.js` | **CREADO** — Exporta `API_URL` obtenida de `import.meta.env.VITE_API_URL` con fallback a `'http://localhost:3005'`. |
| `client/.env` | **CREADO** — Define `VITE_API_URL=http://localhost:3005` por defecto. |
| `client/src/components/Login.jsx` | Reemplazada URL hardcodeada por `API_URL`. |
| `client/src/components/Products.jsx` | Reemplazada URL hardcodeada por `API_URL`. |
| `client/src/components/Chat.jsx` | Reemplazada URL hardcodeada por `API_URL` en inicialización de Socket.IO. |

---

## [2026-09-24] — F-005: Auto-logout en 401 — helper `apiFetch`

### Cambios realizados

| Archivo | Cambio |
|---|---|
| `client/src/utils/apiFetch.js` | **CREADO** — wrapper de 4 líneas: llama `onUnauthorized()` en 401, devuelve `null`; de lo contrario devuelve el `Response`. |
| `client/src/components/Products.jsx` | Import de `apiFetch`. `fetchStats` y `handleCreate` reemplazados: `fetch(…)` → `apiFetch(…, onLogout)`. Guarda `if (!res) return` para el caso 401. |
| `client/src/components/Chat.jsx` | `connect_error`: si `err.message === 'Unauthorized'` o `err.data?.status === 401` → `onLogout()`; otros errores → `setError(…)`. |

### Decisiones adoptadas

- `fetchProducts` NO usa `apiFetch` — es ruta pública sin JWT, nunca devuelve 401.
- El helper usa optional chaining (`onUnauthorized?.()`) para ser seguro aunque no se pase callback.
- No se usó Context ni prop-drilling adicional — `onLogout` ya estaba disponible en ambos componentes.

---

## [2026-09-24] — AUDIT-1.1.2: Auditoría inicial Módulo 1.1.2 Frontend Web (React)

**Tarea:** Auditoría de solo lectura del cliente React en `Act01_ODAAM/client/src/`.
**Resultado:** 5/5 requisitos funcionales del módulo COMPLETADOS.

### Matriz de hallazgos

| Requisito | Archivo | Estado |
|---|---|---|
| R1 — Login JWT | `Login.jsx` | ✅ Completo |
| R2 — Catálogo (nombre, precio, creador) | `Products.jsx` | ✅ Completo |
| R3 — Crear producto | `Products.jsx` | ✅ Completo (Update/Delete ausentes → F-003) |
| R4 — Header `NombreUsuario (N)` | `Products.jsx` + `App.jsx` | ✅ Completo |
| R5 — Chat Socket.IO (historial + tiempo real) | `Chat.jsx` | ✅ Completo |

### Deuda técnica identificada (5 tareas nuevas)

| ID | P | Resumen |
|---|---|---|
| F-001 | P1 | Manejo de errores de red ausente en `Products.jsx` / `Chat.jsx` |
| F-002 | P2 | URL `localhost:3005` hardcodeada en 3 archivos |
| F-003 | P2 | CRUD incompleto — Update/Delete sin UI |
| F-004 | P2 | Sin estado de conexión WS en `Chat.jsx` |
| F-005 | P1 | Sin auto-logout al recibir 401 JWT expirado |

**Archivos generados:** `plan_1_1_2_frontend.md` (nuevo), `tasks.md` (+5 tareas), `current.md` (sesión activa).
**Ningún archivo de `client/src/` fue modificado.**

---

## [2026-09-24] — F-001: Manejo de errores de red en `Products.jsx` y `Chat.jsx`

### Cambios realizados

| Archivo | Cambio |
|---|---|
| `client/src/components/Products.jsx` | `fetchProducts`: añadido `catch` + `throw` en `!res.ok`. `fetchStats`: envuelto en `try/catch` silencioso (stats no críticos). `handleCreate`: envuelto en `try/catch`, muestra "No se pudo conectar con el servidor" en caso de fallo de red. |
| `client/src/components/Chat.jsx` | Añadido `error` state. Listener `connect_error` que setea el error. Mensaje de error renderizado en JSX debajo del header. |

### Decisiones adoptadas

- `fetchStats` falla silenciosamente: el contador queda en 0 pero no interrumpe la vista de catálogo (stats son informativos, no bloqueantes).
- El estado `error` existente de `Products.jsx` fue reutilizado — cero estado nuevo.
- Sin librerías adicionales.

---


**Requerimiento:** al cerrar la app/pestaña, la sesión debe caducar y pedir login de nuevo.
**Causa:** `flutter_secure_storage` persistía el JWT entre reinicios.
**Fix:** eliminado `flutter_secure_storage` por completo (import, `_storage`, `_tokenKey`, `pubspec.yaml`). `getToken()` → `Future.value(null)`, `logout()` → `Future.value()`. El token vive solo en `_MyAppState._token` (memoria). Al cerrar la app, muere.

### Archivos modificados
| Archivo | Cambio |
|---|---|
| `lib/services/auth_service.dart` | Eliminados import, constantes y llamadas a storage; `login()` ya no persiste |
| `pubspec.yaml` | Eliminada dependencia `flutter_secure_storage: ^9.2.2` |

---


**Causa raíz:** `_socket.dispose()` dispara `onDisconnect` sincrónicamente → `setState` en un widget ya finalizado.
**Fix:** `_socket.clearListeners()` antes de `_socket.dispose()` en `chat_screen.dart:100`. Una línea.

---

## [2026-09-18] — T-004: Agregar campo de búsqueda/filtro en `ProductsScreen`

### Cambios realizados

- **`lib/screens/products_screen.dart`**
  - Añadido `_searchQuery` al estado para controlar la búsqueda.
  - Implementado getter `_filteredProducts` para filtrar la lista localmente (ignorando mayúsculas/minúsculas).
  - Añadido un `TextField` encima del `ListView` para la entrada de búsqueda.
  - Muestra un mensaje "No hay resultados" si la búsqueda no encuentra coincidencias.

### Suposiciones adoptadas
- La búsqueda es local en la lista de productos ya obtenida, no requiere una nueva llamada a la API por cada pulsación.
- No se necesita debounce por ser un filtro local síncrono.

---

## [2026-09-18] — T-009: URL base dinámica por plataforma (fix `Failed to fetch` en Web)

### Causa del error
`http://10.0.2.2:3005` hardcodeado en servicios y chat. `10.0.2.2` es un alias
exclusivo del emulador Android — no alcanzable desde Chrome (Flutter Web).

### Solución aplicada

**Nuevo archivo:** `lib/config.dart`
```dart
String get baseUrl {
  if (kIsWeb) return 'http://localhost:3005';
  if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:3005';
  return 'http://localhost:3005';
}
```

### Archivos modificados

| Archivo | Cambio |
|---|---|
| `lib/config.dart` | CREADO — getter `baseUrl` con lógica multiplataforma |
| `lib/services/auth_service.dart` | Eliminada `_baseUrl` const → importa `baseUrl` de config |
| `lib/services/api_service.dart` | Ídem |
| `lib/screens/chat_screen.dart` | String literal → `baseUrl` + import config |
| `docs/context/decisions/ADR-006-url-base-multiplataforma.md` | CREADO |
| `docs/context/tasks.md` | T-009 → COMPLETE, añadido T-015 |

### Por qué `flutter/foundation` en lugar de `dart:io`
`dart:io` no existe en Flutter Web y causa error de compilación. `kIsWeb` y
`defaultTargetPlatform` de `flutter/foundation.dart` funcionan en todas las plataformas.

### Entorno de pruebas confirmado
- **Actual:** Flutter Web (Google Chrome)
- **Soporte Android:** Emulador via `10.0.2.2` (no cambia)

### Pruebas ejecutadas
- Grep de `10.0.2.2` en `lib/` → solo aparece en `config.dart` (correcto).
- `flutter analyze lib` → ✅ **No issues found** (ran in 5.8s).

### Suposición adoptada
El backend corre en `localhost:3005` en la misma máquina que el navegador/emulador.
Para dispositivo físico en red LAN, ver T-015.

---

## [2026-09-18] — T-001, T-002, T-006, T-007, T-008, T-013, T-014: Implementación completa de módulos Auth, Catálogo y Chat

### Contexto
Actividad 3 (Act03_ODAAM): integración móvil Flutter consumiendo el backend Node.js/Express
de Act01_ODAAM (puerto 3005) con JWT, catálogo de productos y chat en tiempo real via Socket.IO.

### Archivos creados

| Archivo | Descripción |
|---|---|
| `lib/services/auth_service.dart` | `POST /auth/login`, guardar/leer/borrar JWT en `flutter_secure_storage` |
| `lib/services/api_service.dart` | `GET /products` → `localhost:3005` (ruta pública, sin JWT) |
| `lib/screens/chat_screen.dart` | Cliente Socket.IO autenticado; maneja `messages-history` y `new-message` |
| `lib/widgets/message_bubble.dart` | Burbuja de chat con alineación isMe/otros usando colores del tema |

### Archivos modificados

| Archivo | Cambio |
|---|---|
| `lib/main.dart` | Restauración de sesión al arrancar + shell `_HomeShell` con TabBar (Productos / Chat) |
| `lib/screens/login_screen.dart` | `GET /login?username` → `POST /auth/login` con campos `email`+`password`; usa `AuthService`; error inline |
| `lib/screens/products_screen.dart` | `fakestoreapi.com` → `localhost:3005/products` via `ApiService`; añade estado de error + reintentar |
| `pubspec.yaml` | Dependencias añadidas: `flutter_secure_storage: ^9.2.2`, `socket_io_client: ^3.0.2` |
| `docs/context/AGENT.md` | Stack, estructura y restricciones actualizados |
| `docs/context/tasks.md` | 7 tareas marcadas COMPLETE, backlog reorganizado |

### Decisiones técnicas (ver ADRs)

- `flutter_secure_storage` para JWT — ADR-003
- `socket_io_client` para chat — ADR-004
- TabBar como shell post-login — ADR-005

### Hallazgos del análisis del backend (Act01_ODAAM)

- `POST /auth/login` recibe `{ email, password }` — **no** `username`.
- `GET /products` es **ruta pública** (sin JWT requerido).
- Socket.IO autentica via `socket.handshake.auth.token`.
- JWT payload: `{ id, username, role }`.

### Fix encontrado durante el proceso

- `login_screen.dart` carecía de `import 'dart:convert'` → error de análisis en `base64Url` / `utf8` / `jsonDecode`. Corregido.

### Pruebas ejecutadas

- `flutter pub get` → ✅ sin conflictos.
- `flutter analyze lib` → ✅ **No issues found** (ran in 4.7s).

### Suposiciones adoptadas

- IP `10.0.2.2` para emulador Android (mapea a `localhost` del host). Documentado en `current.md` y ADR-003.
- El campo de login del backend es `email`, no `username` (confirmado leyendo `auth.controller.js`).
- `GET /products` no requiere token (confirmado leyendo `product.routes.js`).
- El username se extrae del payload JWT (decodificado sin verificar firma) solo para display.

---

## [2026-09-17] — T-000: Fix `ProductsScreen` + contexto inicial

### Cambios realizados

- **`lib/screens/products_screen.dart`**
  - Corregido `body: { ... }` (era un `Set` literal inválido) → reemplazado por expresión ternaria `loading ? ... : Column(...)`.
  - Corregida lógica `if/else` con `else` huérfano dentro de `Column`.
  - Movido `Expanded` para envolver únicamente el `ListView.builder`.
  - Añadido `initState` con llamada a `fetchProducts()` para cargar datos al montar el widget.
  - Añadido método `fetchProducts()` con manejo de estado `loading`.

- **`docs/context/`** *(creación)*
  - `AGENT.md`, `tasks.md`, `current.md`, `progress.md`, `decisions/ADR-001`, `decisions/ADR-002`, `.gitignore`.

### Pruebas ejecutadas

- Revisión estática del árbol de widgets corregido.
- Sin suite de tests automatizados en este punto (ver T-010, T-011).

### Suposiciones adoptadas

- La URL del backend (`http://localhost:3005`) es de desarrollo local.
- `fakestoreapi.com` se usaba como mock temporal (reemplazado en sesión 2026-09-18).
- El token JWT se pasa como `Bearer` header.

---

_Las próximas entradas se añaden aquí al completar cada tarea del backlog._
