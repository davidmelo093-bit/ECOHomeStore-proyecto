# ADR-004 — Cliente WebSocket: `socket_io_client`

| Campo | Valor |
|---|---|
| **ID** | ADR-004 |
| **Fecha** | 2026-09-18 |
| **Estado** | Aceptada |

---

## Contexto

El backend usa **Socket.IO** (no WebSocket nativo). El protocolo Socket.IO
incluye handshake propio, reconexión automática y autenticación via `auth`.
Un cliente WebSocket nativo de Dart **no es compatible** con el servidor Socket.IO.

---

## Decisión

Usar **`socket_io_client ^3.0.2`** — el cliente oficial de Socket.IO para Dart/Flutter.

Configuración de conexión:
```dart
io.io('http://10.0.2.2:3005', io.OptionBuilder()
  .setTransports(['websocket'])
  .setAuth({'token': token})
  .enableAutoConnect()
  .build())
```

---

## Alternativas descartadas

| Alternativa | Razón |
|---|---|
| `dart:io WebSocket` nativo | Incompatible con el protocolo Socket.IO del backend |
| `web_socket_channel` | Idem — no habla el handshake de Socket.IO |
| Polling HTTP | Mayor latencia, no es tiempo real real |

---

## Consecuencias

- ✅ Compatibilidad exacta con el servidor Socket.IO de Act01.
- ✅ Reconexión automática incluida.
- ✅ El JWT se pasa en `auth.token` — mismo mecanismo que el cliente React.
- ⚠️ Transporte forzado a `websocket` (sin fallback a long-polling) para evitar problemas de CORS en móvil.
- ⚠️ Si el backend cambia a WebSocket nativo, reemplazar por `web_socket_channel`.

---

## Cuándo revisar

Si el backend migra de Socket.IO a WebSocket nativo o a otro protocolo.
