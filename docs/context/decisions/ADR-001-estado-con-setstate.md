# ADR-001 — Gestión de estado con `setState` (StatefulWidget nativo)

| Campo | Valor |
|---|---|
| **ID** | ADR-001 |
| **Fecha** | 2026-09-17 |
| **Estado** | Aceptada |
| **Decidido por** | Equipo / análisis inicial del proyecto |

---

## Contexto

La aplicación tiene dos pantallas: `LoginScreen` y `ProductsScreen`. Cada una
necesita reaccionar a cambios asincrónicos (respuestas HTTP) y actualizar la UI
(`loading`, `products`, `isLoggedIn`).

Se evaluó si usar una solución de gestión de estado externa.

---

## Decisión

Usar **`setState` con `StatefulWidget`** nativo de Flutter. Sin dependencias
externas de estado (no Provider, no Bloc, no Riverpod).

---

## Alternativas descartadas

| Alternativa | Razón del descarte |
|---|---|
| `provider` | YAGNI — dos pantallas no justifican la indirección |
| `flutter_bloc` | Excesivo para el alcance actual; boilerplate > lógica |
| `riverpod` | Idem; introduce un modelo de aprendizaje innecesario en este punto |
| `InheritedWidget` manual | Más código que `setState` para el mismo resultado |

---

## Consecuencias

- ✅ Cero dependencias adicionales.
- ✅ Código directo y legible para quien aprende Flutter.
- ⚠️ Si la app crece a 5+ pantallas con estado compartido, revisar esta decisión.
- ⚠️ El token se pasa como prop entre widgets (prop drilling); aceptable con 2 pantallas.

---

## Cuándo revisar

Si aparece una tarea que requiera estado compartido entre más de dos pantallas
no relacionadas jerárquicamente, crear ADR-003 con la nueva decisión.
