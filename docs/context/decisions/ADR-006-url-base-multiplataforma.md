# ADR-006 — URL Base dinámica por plataforma (`config.dart`)

| Campo | Valor |
|---|---|
| **ID** | ADR-006 |
| **Fecha** | 2026-09-18 |
| **Estado** | Aceptada |
| **Motivación** | Error `Failed to fetch` al correr en Flutter Web: `10.0.2.2` no es alcanzable desde el navegador |

---

## Contexto

La app se prueba en dos entornos:
- **Flutter Web (Chrome):** necesita `http://localhost:3005`.
- **Emulador Android:** necesita `http://10.0.2.2:3005` (alias del host).

Tener la IP hardcodeada en cada servicio provocó el fallo en Web.

---

## Decisión

Centralizar la URL base en **`lib/config.dart`** con un getter que usa
`kIsWeb` y `defaultTargetPlatform` de `flutter/foundation.dart`.

```dart
String get baseUrl {
  if (kIsWeb) return 'http://localhost:3005';
  if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:3005';
  return 'http://localhost:3005'; // iOS, macOS, Windows, Linux
}
```

---

## Por qué `flutter/foundation.dart` en lugar de `dart:io`

`dart:io` no está disponible en Flutter Web y causa error de compilación si se importa
directamente en archivos usados en Web. `flutter/foundation.dart` funciona en todas las
plataformas (incluyendo Web) y provee `kIsWeb` y `defaultTargetPlatform`.

---

## Alternativas descartadas

| Alternativa | Razón |
|---|---|
| `dart:io Platform.isAndroid` | Falla en compilación Web (no disponible) |
| `--dart-define=BASE_URL=...` en cada `flutter run` | Más control, pero más fricción para desarrolladores nuevos |
| Archivo `.env` con `flutter_dotenv` | Nueva dependencia; YAGNI para dos entornos |
| Constante estática hardcoded por entorno | Requiere editar código para cambiar entorno |

---

## Consecuencias

- ✅ Un solo archivo define la URL — cualquier nuevo servicio solo importa `config.dart`.
- ✅ Sin dependencias nuevas.
- ✅ Extensible: añadir iOS/macOS/staging en un solo lugar.
- ⚠️ `ponytail:` IP hardcoded por entorno; parametrizar con `--dart-define` si se necesita staging/prod (ver T-009).

---

## Archivos afectados

| Archivo | Cambio |
|---|---|
| `lib/config.dart` | CREADO — fuente única de `baseUrl` |
| `lib/services/auth_service.dart` | Eliminada `_baseUrl` const, importa `config.dart` |
| `lib/services/api_service.dart` | Ídem |
| `lib/screens/chat_screen.dart` | String literal `'http://10.0.2.2:3005'` → `baseUrl` |
