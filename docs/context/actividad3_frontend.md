# Actividad 3 — UI Sincronizada: Creador y Contador Dinámico

> Registro de implementación en ambos clientes (React + Flutter).
> Fecha: 2026-09-18

---

## Objetivo

Mostrar en ambos clientes:
1. El **nombre del creador** en cada fila/tarjeta de producto (campo `created_by_username` del backend).
2. El **contador dinámico** de productos propios en formato `Nombre (N)` en el header/AppBar.
3. **Reactividad**: el contador sube +1 inmediatamente al crear un producto, sin recargar.

---

## Estado del Backend (referencia, no modificado)

| Endpoint | Método | Auth | Respuesta relevante |
|---|---|---|---|
| `GET /products` | Público | No | `[{ id, name, price, created_by_username, ... }]` |
| `GET /users/me/stats` | Privado | JWT Bearer | `{ username, product_count, role, id }` |
| `POST /products` | Privado | JWT Bearer + rol admin | `{ id, name, price, ... }` |

Campo clave: `created_by_username` viene del JOIN en `product.model.js`:
```sql
SELECT p.*, u.username AS created_by_username
FROM products p LEFT JOIN users u ON u.id = p.created_by
```

---

## React — `C:\Proyectos\Act01_ODAAM\client\src\`

### Archivos modificados / creados

| Archivo | Cambio |
|---|---|
| `components/Products.jsx` | **CREADO** — Componente de catálogo completo |
| `App.jsx` | **MODIFICADO** — Tabs Productos/Chat, extracción de username, sessionStorage |
| `components/Login.jsx` | **MODIFICADO** — Decodifica JWT payload para extraer `username` |

### Descripción de cambios

#### `Login.jsx`
- Antes: `onLoginSuccess(data.token)` — solo pasaba el token.
- Ahora: decodifica el payload JWT con `atob(token.split('.')[1])` para extraer `username` (sin verificar firma, solo display) y lo pasa: `onLoginSuccess(data.token, username)`.

#### `App.jsx`
- Agrega tabs de navegación (Productos / Chat) mediante estado `tab`.
- Recibe `username` del login y lo propaga a `<Products>`.
- Migrado de `localStorage` a `sessionStorage` (sesión no persistente — requerimiento anterior).

#### `components/Products.jsx` (nuevo)
- **Listado**: tabla con columnas `#`, `Nombre`, `Precio`, `Creado por` (`p.created_by_username`).
- **Contador**: llama `GET /users/me/stats` al montar → muestra `Nombre (N)` en el header.
- **Formulario crear**: `POST /products` con JWT. Al éxito:
  - Agrega el nuevo producto al estado local (`setProducts(prev => [...prev, data])`).
  - Incrementa el contador localmente: `setStats(prev => ({ ...prev, product_count: prev.product_count + 1 }))`.
  - **Sin recarga de página** — reactividad pura con `useState`.

### Estrategia de estado (React)

```
Mount → fetchProducts() + fetchStats() en paralelo (Promise.all implícito)
         ↓                       ↓
   setProducts([...])     setStats({ username, product_count })
                                  ↓
                        Header muestra "username (N)"

handleCreate() → POST /products → éxito
   ↓
   setProducts(prev => [...prev, newProduct])   // lista actualizada sin fetch
   setStats(prev => ({ ...prev, product_count: prev.product_count + 1 }))  // +1 local
```

No se usa Context ni Redux — el estado local de `Products.jsx` es suficiente. `product_count` se incrementa localmente para evitar un round-trip al servidor y garantizar reactividad inmediata.

---

## Flutter — `C:\Proyectos\Act03_ODAAM\store_app\lib\`

### Archivos modificados

| Archivo | Cambio |
|---|---|
| `services/api_service.dart` | **MODIFICADO** — Agregado `getStats(String token)` |
| `screens/products_screen.dart` | **MODIFICADO** — Contador en AppBar, creador en ListTile |

### Descripción de cambios

#### `api_service.dart`
- Nuevo método `getStats(token)`: `GET /users/me/stats` con header `Authorization: Bearer $token`.
- Devuelve `Map<String, dynamic>` con `{ username, product_count, ... }`.

#### `products_screen.dart`
- **Estado nuevo**: `int _productCount = 0`.
- `_fetchProducts()` renombrado a `_fetchAll()` que corre en paralelo:
  ```dart
  final results = await Future.wait([
    ApiService.getProducts(),
    ApiService.getStats(widget.token),
  ]);
  ```
- **AppBar title**: cambiado de `'Productos (${widget.username})'` a `'${widget.username} ($_productCount)'`.
- **ListTile subtitle**: `Row` con precio + creador (`· created_by_username`) en gris.

> **Nota**: En Flutter, la creación de productos no está implementada en el cliente móvil (no es parte del requerimiento de Act03). El contador se actualiza correctamente al refrescar (`_fetchAll`). Si se añade creación en el futuro, basta con hacer `setState(() => _productCount++)` después de la llamada exitosa.

### Estrategia de estado (Flutter)

```
initState → _fetchAll()
    ↓
Future.wait([getProducts(), getStats(token)])
    ↓
setState:
  _products = results[0]
  _productCount = results[1]['product_count']
    ↓
AppBar muestra "username (N)"
ListTile muestra "· created_by_username" por cada producto
```

`setState` estándar de Flutter — sin Provider ni Bloc. Suficiente para este scope.

---

## Resumen de Endpoints Consumidos

| Cliente | Endpoint | Para qué |
|---|---|---|
| React | `GET /products` | Lista de productos con creador |
| React | `GET /users/me/stats` | Contador inicial al montar |
| React | `POST /products` | Crear producto (solo admin) |
| Flutter | `GET /products` | Lista de productos con creador |
| Flutter | `GET /users/me/stats` | Contador en AppBar |

---

## Pruebas esperadas

- `flutter analyze lib` → sin issues
- React: login → tab Productos muestra tabla con columna "Creado por" y header `username (N)`
- React: crear producto (admin) → fila aparece en tabla, contador sube +1 sin recarga
- Flutter: AppBar muestra `username (N)` correcto al cargar; cada ListTile muestra `· creador`
