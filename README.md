# EcoHome Store — Paquete de Entrega Final (Monorepo)

Monorepo consolidado multiplataforma que integra una arquitectura de microservicios y clientes desacoplados: Backend en Node.js/Express con WebSockets en tiempo real, Base de Datos relacional en PostgreSQL con trazabilidad, Cliente Web SPA en React/Vite y Cliente Móvil nativo en Flutter/Dart.

---

## 1. Estructura del Repositorio

La arquitectura monorepo organiza cada componente de la solución en capas de responsabilidad única:

```text
/
├── backend/          # API REST y Servidor WebSocket (Node.js, Express, Socket.IO, pg)
├── web-react/        # Cliente Web SPA (React 18, Vite, Socket.IO Client)
├── mobile-flutter/   # Aplicación Móvil Multiplataforma (Flutter SDK 3.34, Dart)
├── db/               # Scripts SQL ordenados (DDL, migración de trazabilidad y seed)
│   ├── 01_init.sql
│   ├── 02_trazabilidad.sql
│   └── 03_seed.sql
├── docs/             # Documentación técnica, ADRs y contexto de arquitectura
│   └── context/
├── .gitignore        # Reglas globales de exclusión de artefactos y dependencias
└── README.md         # Guía técnica integral y contrato de operaciones
```

---

## 2. Requisitos Previos

Para ejecutar la totalidad de la solución en entornos locales (Windows / macOS / Linux), se deben cumplir las siguientes versiones:

| Herramienta / Runtime | Versión Mínima Requerida | Comando de Verificación |
|---|---|---|
| **Node.js** | `v18.x` o superior (Recomendado: LTS `v20.x`) | `node -v` |
| **npm** | `v9.x` o superior | `npm -v` |
| **PostgreSQL** | `14.x`, `15.x` o `16.x` (Local, Supabase o Neon) | `psql -V` |
| **Flutter SDK** | `3.34.x` o superior | `flutter --version` |
| **Dart SDK** | `3.5.x` o superior (incluido en Flutter) | `dart --version` |
| **Android Studio / SDK** | API Level 34+ (para emulador/dispositivo Android) | `flutter doctor` |

---

## 3. Variables de Entorno (`.env.example`)

### Backend (`backend/.env`)
Crear el archivo `backend/.env` copiando la plantilla base:

```env
# Puerto del servidor backend HTTP y WebSocket
PORT=3005
NODE_ENV=development

# Conexión a Base de Datos PostgreSQL
DB_HOST=localhost
DB_USER=postgres
DB_PASS=tu_password_postgres
DB_NAME=postgres
DB_PORT=5432

# Autenticación JWT Stateless
JWT_SECRET=Mi_Tienda_Llave_Secreta_Extremadamente_Segura_2026
JWT_EXPIRES_IN=1h

# Parámetros Administrativos
ADMIN_PASSWORD=admin123
```

### Cliente Web React (`web-react/.env`)
Crear el archivo `web-react/.env` para definir la URL del endpoint del backend:

```env
VITE_API_URL=http://localhost:3005
```

---

## 4. Guía de Despliegue Local Paso a Paso

### Paso 1: Configurar y Levantar la Base de Datos (PostgreSQL)

Los scripts SQL están diseñados para ejecutarse en orden secuencial estricto en cualquier cliente PostgreSQL (CLI `psql`, DBeaver o pgAdmin):

#### Vía Terminal (Windows PowerShell / macOS / Linux):
```bash
# 1. Crear esquemas y tablas base (users, products, messages)
psql -U postgres -d postgres -f db/01_init.sql

# 2. Aplicar migración de trazabilidad (asociación created_by en products)
psql -U postgres -d postgres -f db/02_trazabilidad.sql

# 3. Poblar usuarios iniciales con hashes bcrypt y productos de prueba
psql -U postgres -d postgres -f db/03_seed.sql
```

> **Nota:** En DBeaver o pgAdmin, abrir y ejecutar secuencialmente los archivos [`01_init.sql`](db/01_init.sql), [`02_trazabilidad.sql`](db/02_trazabilidad.sql) y [`03_seed.sql`](db/03_seed.sql) sobre la base de datos de destino.

---

### Paso 2: Levantar el Backend (Node.js + Express + Socket.IO)

```bash
# Navegar a la carpeta del backend
cd backend

# Instalar dependencias
npm install

# Iniciar el servidor en modo desarrollo
npm start
# O directamente: node src/app.js
```
El backend confirmará:
```text
Servidor activo en puerto 3005
```

---

### Paso 3: Levantar el Cliente Web (React + Vite)

```bash
# Navegar a la carpeta del cliente web
cd ../web-react

# Instalar dependencias
npm install

# Iniciar servidor de desarrollo Vite
npm run dev
```
La interfaz web estará disponible de inmediato en `http://localhost:5173`.

---

### Paso 4: Levantar el Cliente Móvil (Flutter)

```bash
# Navegar a la carpeta del cliente móvil
cd ../mobile-flutter

# Descargar paquetes y dependencias
flutter pub get

# Ejecutar en emulador o dispositivo conectado
flutter run
```

---

## 5. Configuración de Conectividad Móvil (LAN vs Emulador)

El cliente móvil consume la API REST y el servidor de WebSockets mediante una configuración unificada centralizada en `mobile-flutter/lib/config.dart`.

### Comportamiento de Red por Entorno

| Entorno de Ejecución | IP / Host Utilizado | Detalle Técnico |
|---|---|---|
| **Flutter Web / Desktop** | `http://localhost:3005` | Acceso directo en el loopback de la máquina host. |
| **Emulador Android (AVD)** | `http://10.0.2.2:3005` | `10.0.2.2` es el alias de loopback de QEMU hacia el localhost del sistema operativo host. |
| **Dispositivo Móvil Físico** | `http://192.168.40.15:3005` | IP privada asignada a la máquina en la red local (LAN). **Nunca usar `localhost` en dispositivo físico.** |

### Inyección Dinámica sin Modificar Código (`--dart-define`)

Para desplegar en cualquier IP de red local sin alterar archivos fuente, ejecutar con el parámetro `BASE_URL`:

```bash
# Ejecución en dispositivo físico conectado a la misma red Wi-Fi:
flutter run --dart-define=BASE_URL=http://192.168.40.15:3005

# Generación de APK Release para instalación manual:
flutter build apk --release --dart-define=BASE_URL=http://192.168.40.15:3005
```

### Requisitos de Red en Android (`AndroidManifest.xml`)
El archivo `mobile-flutter/android/app/src/main/AndroidManifest.xml` cuenta con las directivas requeridas:
1. `<uses-permission android:name="android.permission.INTERNET"/>` para permitir tráfico de sockets y HTTP.
2. `android:usesCleartextTraffic="true"` en `<application>` para permitir tráfico HTTP no cifrado hacia la IP de desarrollo local.

---

## 6. Credenciales de Demostración

La base de datos se inicializa con dos perfiles de prueba listos para validar autorización basada en roles (RBAC):

| Rol | Correo Electrónico | Contraseña en Claro | Hash Almacenado (`bcrypt`) | Permisos |
|---|---|---|---|---|
| **Administrador** | `admin@store.com` | `admin123` | `$2b$10$./THOfyDyMIHPZnXhQau3u3FOj1japxJ80nq/wqK2sZtZOhcuASDu` | Acceso total: Crear, editar y eliminar productos (`POST`, `PUT`, `DELETE`), chat en tiempo real. |
| **Cliente Estándar** | `cliente@store.com` | `cliente123` | `$2b$10$werhYYh/ovBqlYDeRHPSoO7wEab71wsGYBXnhVtPMtq/XalmTxixq` | Lectura de catálogo (`GET /products`), consulta de estadísticas personales y chat en tiempo real. |

---

## 7. Contrato de API REST y WebSockets

### Endpoints de la API REST

| Método | Endpoint | Cabecera Auth Requerida | Rol Requerido | Descripción |
|---|---|---|---|---|
| `POST` | `/auth/signup` | No | Cualquiera | Registro de nuevo usuario (hashea contraseña con bcrypt). |
| `POST` | `/auth/login` | No | Cualquiera | Autenticación con email/password. Retorna `{ token }` JWT. |
| `GET` | `/products` | No | Cualquiera | Lista todos los productos con `created_by_username` vía `LEFT JOIN`. |
| `GET` | `/products/:id` | No | Cualquiera | Obtiene el detalle de un producto específico. |
| `POST` | `/products` | `Authorization: Bearer <JWT>` | `admin` | Crea un nuevo producto asociando `created_by` con el ID del usuario en el token. |
| `PUT` | `/products/:id` | `Authorization: Bearer <JWT>` | `admin` | Actualización total de nombre y precio del producto. |
| `PATCH` | `/products/:id` | `Authorization: Bearer <JWT>` | `admin` | Actualización parcial de campos del producto. |
| `DELETE` | `/products/:id` | `Authorization: Bearer <JWT>` | `admin` | Eliminación definitiva del producto de la base de datos. |
| `GET` | `/users/me/stats` | `Authorization: Bearer <JWT>` | Cualquiera autenticado | Devuelve `{ id, username, role, product_count }` para sincronizar header `Usuario (N)`. |

---

### Protocolo de Comunicación en Tiempo Real (Socket.IO)

#### 1. Handshake y Autenticación
El cliente establece la conexión enviando el token JWT en el objeto `auth`:
```javascript
// Cliente Socket.IO (React / Flutter)
const socket = io(BASE_URL, {
  auth: { token: "<JWT_TOKEN>" },
  transports: ['websocket']
});
```

#### 2. Eventos del Ciclo de Vida

- **`connection`:** El servidor valida el JWT en el middleware `io.use()`. Si es válido, inyecta `socket.user = decoded` y emite de inmediato el historial:
  - **Evento emitido:** `messages-history`
  - **Payload servidor → cliente:**
    ```json
    [
      {
        "id": 14,
        "user_id": 1,
        "username": "adminuser",
        "text": "Bienvenidos al chat de EcoHome Store",
        "created_at": "2026-09-26T20:15:00.000Z"
      }
    ]
    ```

- **`new-message` (Envío cliente → servidor):**
  - **Payload cliente → servidor:**
    ```json
    {
      "text": "Hola a todos desde Flutter!"
    }
    ```

- **`new-message` (Broadcast servidor → todos los clientes conectados):**
  - El servidor persiste el mensaje en PostgreSQL en la tabla `messages` y hace broadcast con `io.emit`:
  - **Payload emitido:**
    ```json
    {
      "id": 15,
      "user_id": 2,
      "username": "clienteuser",
      "text": "Hola a todos desde Flutter!",
      "created_at": "2026-09-26T20:16:30.000Z"
    }
    ```

- **`disconnect`:** El servidor registra el cierre de conexión y limpia los recursos del socket sin afectar a otros clientes.

---

## 8. Verificación y Pruebas Automatizadas

```bash
# Ejecutar suite de pruebas de widgets en Flutter
cd mobile-flutter
flutter test
# Resultado esperado: 00:03 +3: All tests passed!

# Análisis estático en Flutter
flutter analyze lib
# Resultado esperado: No issues found!
```
