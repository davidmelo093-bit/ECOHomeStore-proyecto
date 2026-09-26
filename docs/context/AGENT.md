# AGENT.md — Reglas y Convenciones del Proyecto

> [!IMPORTANT]
> Este archivo define las reglas que cualquier agente de IA **debe respetar**
> antes de proponer o aplicar cambios en este repositorio.

---

## 1. Stack técnico

| Elemento | Valor |
|---|---|
| Framework | Flutter 3.x / Material 3 |
| Lenguaje | Dart 3.x (SDK `^3.13.3`) |
| HTTP | `package:http ^1.6.0` |
| Almacenamiento seguro | `flutter_secure_storage ^9.2.2` (JWT) |
| WebSockets / Chat | `socket_io_client ^3.0.2` |
| Gestión de estado | `setState` (StatefulWidget nativo — sin Provider/Bloc/Riverpod) |
| Backend | REST + Socket.IO — `http://10.0.2.2:3005` (emulador Android) |
| Linter | `flutter_lints ^6.0.0` + `analysis_options.yaml` en raíz |

> [!NOTE]
> `10.0.2.2` mapea a `localhost` del host en el emulador Android.
> Para dispositivo físico, usar la IP LAN de la máquina (ej. `192.168.x.x`).
> Para producción, extraer a variable de entorno o config file.

---

## 2. Estructura de carpetas

```
store_app/
├── lib/
│   ├── main.dart                  # Entrada: restaura sesión, TabBar shell post-login
│   ├── services/                  # Lógica de red y almacenamiento
│   │   ├── auth_service.dart      # POST /auth/login + flutter_secure_storage
│   │   └── api_service.dart       # GET /products (y futuros endpoints REST)
│   ├── screens/                   # Una pantalla = un archivo
│   │   ├── login_screen.dart
│   │   ├── products_screen.dart
│   │   └── chat_screen.dart
│   └── widgets/                   # Widgets reutilizables sin lógica de negocio
│       └── message_bubble.dart
├── test/                          # Tests de widget/unidad
├── docs/
│   └── context/                   # Contexto del agente (este directorio)
│       ├── AGENT.md
│       ├── tasks.md
│       ├── current.md
│       ├── progress.md
│       └── decisions/
└── pubspec.yaml
```

**Reglas de estructura:**
- Cada pantalla vive en `lib/screens/` con nombre `<nombre>_screen.dart`.
- Lógica HTTP y de almacenamiento va en `lib/services/` — nunca directamente en pantallas.
- Widgets puramente visuales y reutilizables van en `lib/widgets/`.
- No crear subcarpetas adicionales dentro de `lib/` sin aprobación explícita.
- No crear carpetas `models/`, `providers/`, `repositories/` especulativas; solo cuando una tarea lo requiera.

---

## 3. Endpoints del backend (Act01_ODAAM — puerto 3005)

| Método | Ruta | Auth | Notas |
|---|---|---|---|
| POST | `/auth/login` | ❌ | Body: `{ email, password }` → `{ token }` |
| POST | `/auth/signup` | ❌ | Body: `{ username, email, password, role? }` |
| GET | `/products` | ❌ Pública | Sin JWT |
| POST | `/products` | ✅ JWT + rol admin | |
| PUT | `/products/:id` | ✅ JWT + rol admin | |
| PATCH | `/products/:id` | ✅ JWT + rol admin | |
| DELETE | `/products/:id` | ✅ JWT + rol admin | |
| WS | `/` (Socket.IO) | ✅ JWT en `auth.token` | Eventos: `new-message`, `messages-history` |

---

## 4. Convenciones de código Dart/Flutter

- **Nombrado:** `UpperCamelCase` para clases/widgets; `lowerCamelCase` para variables y métodos; `snake_case` para archivos.
- **`const`** en todos los widgets/constructores donde sea posible (el linter lo exige).
- **`setState`** es el único mecanismo de estado permitido hasta que una tarea lo cambie explícitamente.
- **Sin comentarios de código muerto.** Si se elimina código, se elimina completo.
- Imports ordenados: `dart:*` → `package:flutter/*` → `package:*` → imports locales.
- Líneas ≤ 120 caracteres.
- Los servicios exponen solo métodos estáticos (`static`) — no instanciar si no hay estado.

---

## 5. Manejo de errores

- Toda llamada HTTP va dentro de `try/on Exception catch`. Nunca dejar `catch` vacío.
- Errores de red → estado `_error` en el widget + mensaje legible al usuario. No usar `print` en producción.
- El `finally` (o `if (mounted)`) siempre debe restablecer el estado de `loading`.
- Los servicios lanzan `Exception` con mensaje legible; las pantallas los capturan y muestran.
- No lanzar excepciones sin capturar al usuario final.

---

## 6. Lo que la IA **nunca** debe modificar sin permiso explícito

| Archivo / Área | Razón |
|---|---|
| `pubspec.yaml` — sección `dependencies` | Agregar dependencias cambia el contrato del proyecto |
| `android/`, `ios/`, `windows/`, `linux/`, `macos/`, `web/` | Plataformas nativas — requieren revisión manual |
| `analysis_options.yaml` | Cambiar reglas de lint afecta todo el equipo |
| `.gitignore` raíz | Ya configurado para Flutter; modificar puede exponer artefactos |
| `lib/main.dart` — lógica de enrutado y sesión | Cambio de arquitectura — requiere aprobación |
| `lib/services/auth_service.dart` — clave `_tokenKey` | Cambiarla invalida sesiones existentes |
| `docs/context/progress.md` | Solo el agente activo en la sesión lo actualiza al cerrar tarea |

---

## 7. Qué sí puede hacer la IA sin permiso adicional

- Corregir errores de compilación o linter en archivos ya existentes.
- Añadir widgets dentro de pantallas existentes si la tarea lo indica.
- Crear archivos nuevos dentro de `lib/screens/`, `lib/services/` o `lib/widgets/` cuando la tarea los defina.
- Actualizar `tasks.md`, `current.md` y `progress.md` según avance.
- Crear ADRs en `docs/context/decisions/`.
- Ejecutar `flutter analyze` y `flutter pub get` sin confirmación.
