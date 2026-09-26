# store_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# 🏁 Resumen de Arquitectura (Flutter Mobile vs Backend Node.js)

## 1. Cliente Móvil — `store_app` (Flutter SDK 3.34)

### Dependencias principales

| Paquete | Versión | Uso |
|---------|---------|-----|
| `http` | `^1.6.0` | API REST (GET /products, POST /auth/login, POST /products) |
| `socket_io_client` | `^3.0.2` | WebSocket en tiempo real (chat) |

### Estado actual

- **✅ Autenticación:** Login devuelve JWT → se guarda en memoria (`_MyAppState._token`) → usado en `Authorization: Bearer <token>` para rutas protegidas.
- **✅ Catálogo:** `ProductsScreen` renderiza todos los productos (GET /products) y muestra contador local `(N)` basado en el nombre del usuario logueado.
- **✅ Chat:** `ChatScreen` conecta vía WebSocket con Socket.IO, envía mensajes (`new-message`), recibe historial (`messages-history`) y broadcasts.
- **✅ Build:** `flutter build apk --debug` genera app-debug.apk lista para instalar en dispositivo físico.

### Configuración de red (opción recomendada)

```bash
# Ruta fija para dispositivo físico en LAN
flutter build apk --release --dart-define=BASE_URL=http://192.168.40.15:3005
```

## 2. Backend — `Act01_ODAAM` (Node.js + Express + Socket.IO + DBeaver)

### Endpoints REST

- `POST /auth/login` — genera JWT válido con payload `{ "userId": 10, "username": "adminDavid", "role": "admin" }`.
- `GET /products` — retorna todos los productos con `created_by_username` (JOIN con tabla `users`).
- `POST /products` — crea un producto nuevo, guarda `created_by_username` con el nombre del usuario.

### Socket.IO

- Handshake usa token en `socket.handshake.auth.token`.
- Broadcast `io.emit('new-message', ...)` a todos los conectados.
- Historial: carga últimos 10 mensajes al conectar (`'messages-history'`).

### Base de datos

- MySQL tables: `users`, `products`, `messages`.
- `created_by_username` en `products` almacena el nombre del creador.

### 🔐 CORS

✅ CORS configurado (`cors: { origin: '*' }` en `app.js`) — permite peticiones desde cualquier origen (incluido el cliente Flutter nativo).
