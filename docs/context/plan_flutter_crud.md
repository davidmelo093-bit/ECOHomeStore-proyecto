# Plan de Diseño Arquitectónico: CRUD de Productos en Flutter (Admin Controls)

> **Fecha:** 2026-09-24  
> **Autor:** Tech Lead (Ponytail Ultra Mode)  
> **Fase:** Análisis y Evaluación Arquitectónica (Solo lectura en código `.dart`).

---

## 1. Evaluación Crítica de la Propuesta Inicial vs. Alternativas

### 1.1 Manejo del Rol de Usuario (JWT claims vs Provider/Bloc vs `bool`)

* **Tu propuesta:** Pasar un `bool isAdmin` desde la respuesta de login hacia las pantallas.
* **Crítica Tech Lead (Ponytail Ultra):**
  - Inyectar Provider, Riverpod o Bloc para un solo `bool` de rol es **sobre-ingeniería innecesaria**. `AGENT.md` especifica explícitamente `setState` nativo y no incluir librerías de estado no aprobadas.
  - Sin embargo, pasar un simple `bool isAdmin` suelto por prop-drilling es frágil si el rol se puede derivar del token JWT existente.
* **Solución óptima (Laziest & safest):**
  - Extraer el campo `role` directamente del JWT en `AuthService.extractRole(token)` (misma técnica usada para `username`).
  - Evaluar `final isAdmin = AuthService.extractRole(token) == 'admin';` en el widget `ProductsScreen`. Cero dependencias adicionales, cero boilerplates de estado global, 100% derivado del token.

---

### 1.2 Layout de UI para Acciones en la Lista (`ListTile.trailing` vs `PopupMenuButton` vs `flutter_slidable`)

* **Tu propuesta:** Utilizar la propiedad `trailing` de `ListTile` para renderizar ambos botones (Editar / Eliminar).
* **Crítica Tech Lead (Ponytail Ultra):**
  - `flutter_slidable` requiere agregar una dependencia externa pesada a `pubspec.yaml` (violación directa de YAGNI y `AGENT.md`).
  - `ListTile.trailing` con un `Row(mainAxisSize: MainAxisSize.min)` que contiene dos botones pequeños o un `PopupMenuButton` nativo de Flutter.
* **Solución óptima:**
  - **`PopupMenuButton<String>` nativo:** 
    - No ocupa espacio horizontal en la tarjeta/fila (mantiene el UI limpio en pantallas pequeñas).
    - Muestra las opciones "Editar" (con icono) y "Eliminar" (con icono rojo) al tocar los tres puntos.
    - Cero dependencias externas (`PopupMenuButton` es un widget estándar de Material/Flutter).

---

### 1.3 Flujo de Eliminación y UX (Spinner bloqueante vs Actualización Optimista vs Confirmación)

* **Tu propuesta:** Mostrar `AlertDialog`, al confirmar ejecutar la petición HTTP y actualizar la interfaz.
* **Crítica Tech Lead (Ponytail Ultra):**
  - La actualización optimista (borrar de la lista antes de respuesta del server) añade complejidad de rollback en caso de error 4xx/5xx/timeout.
  - El borrado destructivo **requiere confirmación obligatoria** por seguridad del usuario.
* **Solución óptima:**
  - Mostrar `showDialog` con `AlertDialog` de confirmación rápida ("¿Eliminar producto?").
  - Al confirmar: ejecutar `ApiService.deleteProduct(id, token)`.
  - Si la API responde con éxito (HTTP 200/204): eliminar de la lista local `setState(() => _products.removeWhere(...))` y restar 1 al contador `_productCount`.
  - Si la API falla: capturar con `ApiException` y mostrar `SnackBar` con el error de red o permisos sin alterar la lista.

---

## 2. Plan Técnico Recomendado

1. **Backend Contract:**
   - `DELETE /products/:id` con `Authorization: Bearer <token>` (requiere rol `admin`).
   - `PUT /products/:id` con `Authorization: Bearer <token>` (requiere rol `admin`).

2. **Helper `AuthService`:**
   - Añadir método estático `extractRole(String token)` decodificando el JWT (payload `role`).

3. **`ProductsScreen`:**
   - Determinar `isAdmin = AuthService.extractRole(widget.token) == 'admin';`.
   - En `ListTile`, si `isAdmin` es `true`, renderizar `trailing: PopupMenuButton(...)` con acciones de Editar y Eliminar.
   - En la AppBar o FAB (FloatingActionButton), mostrar botón de "Agregar Producto" solo si `isAdmin` es `true`.

4. **Navegación / Diálogos:**
   - **Edición:** Abrir un modal bottom sheet o diálogo de edición con formulario para `name` y `price`.
   - **Eliminación:** Diálogo de confirmación simple → llamada HTTP → actualización de estado local (`setState`).

---

`code` → skipped: [flutter_slidable, Provider/Bloc], add when [se requiera soporte offline con sincronización en segundo plano].
