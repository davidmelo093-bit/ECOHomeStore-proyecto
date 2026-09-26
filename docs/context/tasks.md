# tasks.md — Registro de Tareas

> Actualizar estado al iniciar (`TODO → IN_PROGRESS`) y al terminar (`IN_PROGRESS → COMPLETE`).
> Registrar el cierre en `progress.md`.

---

## Leyenda

| Campo | Valores posibles |
|---|---|
| **Estado** | `TODO` · `IN_PROGRESS` · `COMPLETE` · `BLOCKED` |
| **Prioridad** | `P0` crítica · `P1` alta · `P2` media · `P3` baja |

---

## Tareas activas

| ID | Título | Prioridad | Estado | Depende de |
|---|---|---|---|---|
| T-003 | Manejo de error diferenciado (timeout vs 4xx vs 5xx) en servicios | P1 | COMPLETE | — |
| T-004 | Agregar campo de búsqueda/filtro en `ProductsScreen` | P2 | COMPLETE | — |
| T-005 | Pantalla de detalle de producto (`product_detail_screen.dart`) | P2 | COMPLETE | — |
| T-010 | Escribir widget tests para `LoginScreen` | P2 | COMPLETE | — |
| T-011 | Escribir widget tests para `ProductsScreen` y `ChatScreen` | P2 | COMPLETE | T-010 |
| T-012 | Configurar CI básico (GitHub Actions: `flutter test` + `flutter analyze`) | P3 | COMPLETE | T-010, T-011 |
| T-015 | Parametrizar `baseUrl` con `--dart-define` para entornos staging/prod | P2 | COMPLETE | — |
| F-001 | [React] Añadir `try/catch` en `handleCreate`, `fetchProducts` y `fetchStats` de `Products.jsx` | P1 | COMPLETE | — |
| F-002 | [React] Centralizar URL base en `src/config.js` usando `import.meta.env.VITE_API_URL` | P2 | COMPLETE | — |
| F-003 | [React] Implementar Update y Delete de productos en `Products.jsx` (CRUD completo) | P2 | COMPLETE | F-001 |
| F-004 | [React] Añadir estado de conexión Socket.IO en `Chat.jsx` (connect / connect_error / disconnect) | P2 | COMPLETE | — |
| F-005 | [React] Auto-logout en respuestas 401 — helper `apiFetch` centralizado | P1 | COMPLETE | F-002 |

### Módulo 1.1.3 — Flutter APK (backlog nuevo)

| ID | Título | Prioridad | Estado | Depende de | Notas |
|---|---|---|---|---|---|
| T-FL01 | Login: consumo de `POST /auth/login`, almacenamiento del JWT en memoria (`_MyAppState._token`) | P0 | COMPLETE | — | El JWT ya vive en memoria (`auth_service.dart`). Verificar que `LoginScreen` cumpla el flujo completo y maneja 401/500 correctamente. |
| T-FL02 | Catálogo: `GET /products` con renderizado de `createdBy` y contador `Nombre (N)` por usuario | P1 | COMPLETE | T-FL01 | `ApiService` ya existe. Auditar que el campo `createdBy` se muestre; el contador `(N)` = total de productos creados por el usuario autenticado (filtrar la lista por `createdBy == username`). |
| T-FL03 | Chat: `socket_io_client` — historial (`messages-history`, últimos 10) + envío/recepción en tiempo real | P1 | COMPLETE | T-FL01 | `ChatScreen` ya existe. Verificar que la IP sea correcta para dispositivo físico via `--dart-define=BASE_URL`. Auditar handshake JWT en `socket.auth`. |
| T-FL04 | Build APK (`flutter build apk --release`) y captura de evidencia de funcionamiento | P0 | COMPLETE | T-FL01, T-FL02, T-FL03 | APK generado: `build/app/outputs/flutter-apk/app-release.apk` (49.2 MB). |



---

## Tareas completadas

| ID | Título | Completada |
|---|---|---|
| T-000 | Corregir error `body: {}` (Set literal) en `ProductsScreen` + añadir `initState` | 2026-09-17 |
| T-001 | Separar lógica HTTP de `LoginScreen` en `AuthService` | 2026-09-18 |
| T-002 | Separar lógica HTTP de `ProductsScreen` en `ApiService` | 2026-09-18 |
| T-006 | Crear módulo Chat con Socket.IO autenticado (`ChatScreen` + `MessageBubble`) | 2026-09-18 |
| T-007 | Persistir JWT con `flutter_secure_storage` + restaurar sesión al arrancar | 2026-09-18 |
| T-008 | Corregir endpoint login: `GET /login?username` → `POST /auth/login` con email+password | 2026-09-18 |
| T-009 | URL base dinámica por plataforma (Web/Desktop → localhost, Android → 10.0.2.2) | 2026-09-18 |
| T-013 | Corregir endpoint productos: `fakestoreapi.com` → `localhost:3005/products` | 2026-09-18 |
| T-014 | Navegación post-login: TabBar con pestañas Productos y Chat | 2026-09-18 |
| T-004 | Agregar campo de búsqueda/filtro en `ProductsScreen` | 2026-09-18 |
