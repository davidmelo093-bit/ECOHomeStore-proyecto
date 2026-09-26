# Plan 1.1.2 — Frontend Web (React): Auditoría y Plan de Acción

> **Fecha de auditoría:** 2026-09-24
> **Auditor:** Tech Lead / Agente AUDIT-1.1.2
> **Fase:** Solo lectura — ningún archivo de `client/src/` fue modificado.
> **Rutas auditadas:**
> - `C:\Proyectos\Act01_ODAAM\client\src\App.jsx`
> - `C:\Proyectos\Act01_ODAAM\client\src\components\Login.jsx`
> - `C:\Proyectos\Act01_ODAAM\client\src\components\Products.jsx`
> - `C:\Proyectos\Act01_ODAAM\client\src\components\Chat.jsx`
> - `C:\Proyectos\Act01_ODAAM\client\package.json`

---

## 1. Stack React detectado

| Elemento | Valor |
|---|---|
| Framework | React 19.2.8 (Vite 8.3) |
| Lenguaje | JSX (ES Modules) |
| HTTP | `fetch` nativo del browser |
| WebSocket | `socket.io-client ^4.8.3` |
| Estado | `useState` + `useCallback` (sin Redux/Zustand/Context global) |
| Sesión | `sessionStorage` (no persistente entre pestañas) |
| Linter | `oxlint` |
| Router | Ninguno — tabs con estado local (`tab` en `App.jsx`) |

---

## 2. Matriz de Requisitos vs. Estado Real

| # | Requisito | Archivo(s) clave | Estado | Observaciones |
|---|---|---|---|---|
| R1 | Login con JWT | `Login.jsx` | ✅ **COMPLETO** | `POST /auth/login` con `{email, password}`. JWT recibido y guardado en `sessionStorage`. Decodificación del payload para extraer `username` (sin verificación de firma — solo display). |
| R2 | Catálogo con nombre, precio y creador | `Products.jsx` L86-94 | ✅ **COMPLETO** | Tabla con columnas: `#`, `Nombre`, `Precio`, `Creado por` (campo `created_by_username`). Consume `GET /products` (ruta pública). |
| R3 | Gestión de productos (crear) | `Products.jsx` L35-48 | ✅ **COMPLETO** | Formulario `POST /products` con JWT. Actualiza lista y contador localmente sin recargar (reactividad con `useState`). **CRUD parcial**: solo Create. Sin Update/Delete en el frontend. |
| R4 | Header con `NombreUsuario (N)` | `Products.jsx` L54-56 | ✅ **COMPLETO** | `<h2>Catálogo — <span>{stats.username} ({stats.product_count})</span></h2>`. Carga desde `GET /users/me/stats` al montar. Contador sube +1 localmente al crear. |
| R5a | Chat — historial últimos 10 mensajes | `Chat.jsx` L16-18 | ✅ **COMPLETO** | Escucha evento `messages-history` de Socket.IO. Renderiza `username`, `text` y timestamp. El límite de 10 es responsabilidad del backend. |
| R5b | Chat — envío en tiempo real | `Chat.jsx` L31-38 | ✅ **COMPLETO** | Emite `new-message` con `{text}`. Backend retransmite y el componente lo recibe via `new-message` listener. Desconexión limpia en `useEffect` cleanup. |

**Resultado global: 5/5 requisitos COMPLETADOS al menos en su forma mínima.**

---

## 3. Hallazgos de Calidad (gaps no bloqueantes)

Estos puntos no impiden que los requisitos funcionen, pero representan deuda técnica identificada durante la auditoría.

### 3.1 — Manejo de errores incompleto en `Products.jsx`

```jsx
// L38-44 — Products.jsx
const res = await fetch(`${API}/products`, { ... });
const data = await res.json();
if (!res.ok) { setError(data.error || 'Error al crear'); return; }
```

**Problema:** `handleCreate` no tiene `try/catch`. Si la red cae, `fetch` lanza y la app no muestra error al usuario — queda en estado indefinido. `fetchProducts` tampoco captura errores de red.

**Impacto:** P1. El usuario no recibe feedback si el backend no responde.

---

### 3.2 — URL hardcodeada en tres archivos

```jsx
// Login.jsx L13
fetch('http://localhost:3005/auth/login', ...)

// Products.jsx L3
const API = 'http://localhost:3005';

// Chat.jsx L11
io('http://localhost:3005', ...)
```

**Problema:** Imposible cambiar de entorno (dev → staging → prod) sin editar código. Viola el principio de 12-Factor App.

**Impacto:** P2. Bloquea cualquier despliegue fuera de `localhost`.

---

### 3.3 — CRUD incompleto (Update / Delete ausentes)

El requisito R3 pide capacidad mínima de **crear** (cumplido). Sin embargo, el backend expone `PUT /products/:id`, `PATCH /products/:id` y `DELETE /products/:id` — ninguno tiene UI en React.

**Impacto:** P2. Funcional para la actividad, pero la gestión real de catálogo requiere Update/Delete.

---

### 3.4 — Sin feedback de carga en Chat

El componente `Chat.jsx` no tiene estado de conexión. Si el servidor WebSocket tarda o rechaza el token, el usuario ve el chat vacío sin mensaje de error.

**Impacto:** P2. UX degradada en fallos de autenticación WS.

---

### 3.5 — Sin validación de token expirado

`App.jsx` restaura el token de `sessionStorage` sin verificar si expiró. Una llamada a API con JWT vencido devuelve 401 sin que la app haga logout automático.

**Impacto:** P1. El usuario ve errores crípticos en lugar de volver al login.

---

### 3.6 — Sin router (navegación plana)

La app usa estado `tab` en `App.jsx` para simular rutas. No hay URL que represente la vista activa — el botón "atrás" del browser rompe el estado.

**Impacto:** P3. Aceptable para esta actividad; problema real en producción.

---

## 4. Estrategia de Implementación (para las tareas pendientes)

### Tarea F-001 — Manejo de errores en `Products.jsx` y `Chat.jsx`

**Qué modificar:** Envolver `handleCreate`, `fetchProducts` y la conexión Socket.IO en `try/catch`. Mostrar `error` en el JSX.

**Patrón:**
```jsx
try {
  const res = await fetch(...);
  if (!res.ok) throw new Error((await res.json()).error ?? 'Error de servidor');
  // éxito
} catch (err) {
  setError(err.message);
}
```

**Archivos:** `Products.jsx`, `Chat.jsx`.  
**Sin librerías nuevas** — patrón nativo `try/catch`.

---

### Tarea F-002 — Centralizar URL base

**Patrón más simple (sin lib):** Crear `src/config.js`:
```js
// src/config.js
export const API_URL = import.meta.env.VITE_API_URL ?? 'http://localhost:3005';
```
Y en `.env` (raíz del cliente):
```
VITE_API_URL=http://localhost:3005
```

**Qué modificar:** Reemplazar los 3 strings literales por `import { API_URL } from '../config'`.  
**Sin librerías nuevas** — Vite ya soporta `import.meta.env`.

---

### Tarea F-003 — Update y Delete de productos (CRUD completo)

**Endpoints disponibles en el backend:**
- `PUT /products/:id` — reemplaza `{name, price}`
- `DELETE /products/:id` — elimina por id

**Estrategia:**
1. Añadir columna "Acciones" a la tabla (`Editar` / `Eliminar`).
2. Estado local: `editingId` + `editName` + `editPrice`.
3. Al guardar: `PUT /products/:id` → actualizar `products` en estado sin refetch.
4. Al eliminar: `DELETE /products/:id` → filtrar del array local.

**Archivos:** solo `Products.jsx`.  
**Sin librerías nuevas.**

---

### Tarea F-004 — Estado de conexión en Chat

**Patrón:**
```jsx
const [connected, setConnected] = useState(false);
newSocket.on('connect', () => setConnected(true));
newSocket.on('connect_error', (err) => setError(err.message));
newSocket.on('disconnect', () => setConnected(false));
```
Mostrar indicador de estado en el header del chat.

**Archivos:** `Chat.jsx`.  
**Sin librerías nuevas.**

---

### Tarea F-005 — Manejo de JWT expirado (auto-logout en 401)

**Patrón centralizado:** Helper `apiFetch` que intercepta 401:
```js
// src/utils/apiFetch.js
export async function apiFetch(url, options, onUnauthorized) {
  const res = await fetch(url, options);
  if (res.status === 401) { onUnauthorized(); return null; }
  return res;
}
```
`App.jsx` pasa `handleLogout` a los componentes o usa Context para acceder sin prop-drilling.

**Archivos:** nuevo `src/utils/apiFetch.js`, `Products.jsx`, `Chat.jsx`, `App.jsx`.  
**Sin librerías nuevas.**

---

## 5. Priorización de implementación (orden sugerido)

```
F-001 (P1, errores de red)
  ↓
F-002 (P2, config URL)
  ↓
F-005 (P1, 401 auto-logout)
  ↓
F-004 (P2, estado conexión chat)
  ↓
F-003 (P2, CRUD completo)
```

---

## 6. Lo que NO hace falta implementar

- **Router (react-router-dom):** La navegación por tabs es suficiente para el scope de la actividad. Añadir router es YAGNI aquí.
- **Context / Redux:** El estado local es correcto para este tamaño de app. No añadir hasta que haya prop-drilling real entre >3 niveles.
- **Tests automatizados en esta fase:** Fuera del scope del módulo 1.1.2. Ver tareas T-010/T-011 existentes.
- **Autenticación con refresh token:** El backend no lo implementa; no especular.

---

_Documento generado en fase de auditoría — ningún archivo de `client/src/` fue modificado._
