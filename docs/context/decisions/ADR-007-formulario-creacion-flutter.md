# ADR-007 — Formulario de Creación de Productos en Flutter

| Campo | Valor |
|---|---|
| **ID** | ADR-007 |
| **Fecha** | 2026-09-24 |
| **Estado** | Aceptada |
| **Motivación** | Proveer una interfaz accesible y responsiva para la creación de productos (`POST /products`) exclusiva para administradores en Flutter. |

---

## Contexto

Se requiere permitir la creación de nuevos productos desde el cliente móvil Flutter consumiendo `POST /products` (requiere JWT con rol `admin`). 
Se evaluaron tres aspectos clave de UX/UI y arquitectura:

1. **Gatillador visual:** FloatingActionButton (FAB) vs Botón en la AppBar.
2. **Formulario:** `showModalBottomSheet` vs `AlertDialog` vs Nueva Pantalla (`Navigator.push`).
3. **Manejo de estado y reactividad:** Mutación optimista vs actualización post-servidor exitoso (201 Created).

---

## Análisis de Alternativas y Evaluación Crítica

### 1. Gatillador Visual (FAB vs AppBar)
* **Propuesta inicial:** FloatingActionButton (FAB) flotante condicionado a `_isAdmin`.
* **Evaluación:** El FAB es el patrón estándar en Material 3 para la acción primaria positiva ("Crear"). Sin embargo, en listas largas puede tapar el último elemento.
* **Decisión:** Usar `FloatingActionButton.extended` o `FloatingActionButton` estándar condicionado a `_isAdmin` en la propiedad `floatingActionButton` del `Scaffold`. Para evitar tapar contenido, el `ListView` mantendrá un `padding` inferior adecuado.

### 2. Formulario de Entrada (`showModalBottomSheet` vs `AlertDialog` vs Nueva Pantalla)
* **Evaluación `AlertDialog`:** Los diálogos flotantes se distorsionan o quedan cubiertos cuando el teclado virtual (Soft Keyboard) se despliega en dispositivos móviles.
* **Evaluación Nueva Pantalla (`Navigator.push`):** Añade fricción de navegación innecesaria para un formulario de solo 2 campos (`name` y `price`). YAGNI.
* **Decisión:** Utilizar **`showModalBottomSheet` modal con ajuste de teclado (`isScrollControlled: true`)**.
  - Se adapta naturalmente en iOS y Android deslizando desde abajo.
  - El uso de `Padding(padding: MediaQuery.of(ctx).viewInsets)` empuja automáticamente el formulario por encima del teclado sin desbordamientos de pantalla (`overflow`).

### 3. Reactividad y Actualización del Estado
* **Evaluación Mutación Optimista:** Insertar el producto localmente antes de recibir la respuesta del servidor genera inconsistencias si el backend valida el precio o rechaza la solicitud (ej. 400 Bad Request o 403 Forbidden). Además, el id real y `created_by_username` son generados por la base de datos PostgreSQL.
* **Decisión:** **Actualización Post-Respuesta Exitosa (HTTP 201 Created)**:
  - Al presionar "Guardar", se ejecuta `ApiService.createProduct(name, price, token)`.
  - Si el backend retorna HTTP 201 con el objeto creado `{ id, name, price, created_by_username, ... }`, se inserta directamente en la lista local `_products.insert(0, newProduct)` y se incrementa el contador `_productCount = _productCount + 1`.
  - Se cierra el BottomSheet y se notifica con un `SnackBar` verde.

---

## Consecuencias

- ✅ Experiencia de usuario (UX) óptima con manejo limpio del teclado virtual mediante BottomSheet.
- ✅ Cero inconsistencias de datos al confiar en el objeto retornado por la base de datos PostgreSQL.
- ✅ Reactividad inmediata en la UI (lista + header `Nombre (N)`) sin recargar todo el catálogo vía `_fetchAll`.
- ✅ Respeto estricto a las convenciones del proyecto (`setState` nativo, sin dependencias extra).

---

## Archivos Afectados

| Archivo | Cambio |
|---|---|
| `lib/services/api_service.dart` | Agregado método estático `createProduct(name, price, token)` |
| `lib/screens/products_screen.dart` | Agregado `floatingActionButton` condicionado a `_isAdmin` y método `_showCreateBottomSheet()` |
