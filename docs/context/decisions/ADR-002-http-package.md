# ADR-002 — Cliente HTTP: `package:http`

| Campo | Valor |
|---|---|
| **ID** | ADR-002 |
| **Fecha** | 2026-09-17 |
| **Estado** | Aceptada |
| **Decidido por** | Equipo / análisis inicial del proyecto |

---

## Contexto

La app necesita hacer peticiones REST a dos endpoints:
1. `POST`-equivalente via `GET` al backend local de login (`localhost:3005`).
2. `GET` a `fakestoreapi.com` para obtener la lista de productos.

Se necesita un cliente HTTP para Dart/Flutter.

---

## Decisión

Usar **`package:http ^1.6.0`** — la librería oficial/canónica del equipo de Dart.

---

## Alternativas descartadas

| Alternativa | Razón del descarte |
|---|---|
| `dio` | YAGNI — interceptores, reintentos y caché no se necesitan ahora |
| `chopper` | Genera código; sobrecarga para dos endpoints |
| `http` con wrapper propio | Abstraer `http` en esta etapa es especulativo |
| `Dio` con `Retrofit` | Demasiado para el alcance actual |

---

## Consecuencias

- ✅ Ya instalado en `pubspec.yaml`; sin costo adicional.
- ✅ API simple: `http.get(uri, headers: {...})`.
- ⚠️ Sin reintentos automáticos. Si se necesitan, añadir lógica manual o migrar a `dio` (crear ADR-004).
- ⚠️ Sin interceptores globales para el token. Si hay más de 3 pantallas con llamadas autenticadas, centralizar en un servicio HTTP (ver T-002).

---

## Cuándo revisar

Si una tarea requiere interceptores de autenticación globales, caché de
respuestas o reintentos con backoff, abrir ADR-004 evaluando `dio`.
