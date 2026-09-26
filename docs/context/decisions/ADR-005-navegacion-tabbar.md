# ADR-005 — Navegación post-login: `NavigationBar` (TabBar Material 3)

| Campo | Valor |
|---|---|
| **ID** | ADR-005 |
| **Fecha** | 2026-09-18 |
| **Estado** | Aceptada |

---

## Contexto

Tras el login exitoso, la app necesita exponer dos módulos principales:
**Productos** (catálogo) y **Chat** (tiempo real). Se necesita una estructura
de navegación que los integre sin perder el estado de cada módulo al cambiar de pestaña.

---

## Decisión

Usar un **`_HomeShell` con `NavigationBar` (Material 3)** y control de índice
via `setState`. Cada pestaña es un widget independiente montado/desmontado al navegar.

---

## Alternativas descartadas

| Alternativa | Razón |
|---|---|
| `Navigator.push` secuencial | No permite volver a Productos desde Chat sin perder scroll |
| `TabBarView` + `TabController` | Más verboso; `NavigationBar` es el patrón M3 recomendado |
| `go_router` | YAGNI — dos destinos no justifican un router externo |
| `IndexedStack` | Mantiene estado de ambas pestañas; innecesario aquí; el Chat reconecta solo |

---

## Consecuencias

- ✅ Cero dependencias adicionales.
- ✅ Patrón Material 3 estándar — reconocible y accesible.
- ⚠️ Al cambiar de pestaña, `ChatScreen` se desmonta y se reconecta al Socket.IO.
  Aceptable porque `socket_io_client` tiene reconexión automática y el servidor envía
  el historial en cada nueva conexión (`messages-history`).
- ⚠️ Si la app crece a 4+ destinos, migrar a `go_router` (crear ADR-006).

---

## Cuándo revisar

Si se añaden más de 3 pestañas o se necesita deep-linking / rutas con parámetros.
