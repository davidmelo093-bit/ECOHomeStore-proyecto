# current.md — Tarea Activa

> Este archivo se **sobreescribe** al inicio de cada sesión de trabajo.
> Al cerrar la tarea, mover el resumen a `progress.md` y limpiar este archivo.

---

## Sesión actual

- **Fecha:** 2026-09-26
- **Tarea ID:** FINAL-DELIVERY-MONOREPO
- **Título:** Preparación de Entrega Final: Reorganización Monorepo y Generación de README
- **Estado:** DONE

> [!IMPORTANT]
> **Permisos de ESCRITURA activos para:**
> - Estructura de directorios raíz del monorepo (`backend/`, `web-react/`, `mobile-flutter/`, `db/`, `docs/`)
> - `db/*.sql` (`01_init.sql`, `02_trazabilidad.sql`, `03_seed.sql`)
> - `README.md` (raíz global)
> - `docs/context/current.md`
> - `docs/context/progress.md`

> [!NOTE]
> **Reglas de integración activas:**
> - Cero endpoints nuevos en el servidor (reutilizar backend existente).
> - JWT obligatorio en rutas protegidas; prohibido texto plano.
> - Preservación íntegra de proyectos de origen (`Act01_ODAAM`, `Act03_ODAAM`).
> - Compatibilidad multiplataforma y sin dependencias obsoletas.

---

## Última sesión completada

**Fecha:** 2026-09-26
**Tareas completadas:** NET-LAN-001 (Configuración de red: URL base para entorno LAN móvil)
**Resumen:** Configuración de `baseUrl` con fallback a IP LAN `192.168.40.15:3005` y adición de permiso `INTERNET` explícito en `AndroidManifest.xml`. Ver detalle en [`progress.md`](progress.md).

---

## Archivos con permiso de LECTURA para la próxima sesión

- Todo `lib/` y `docs/context/`

## Archivos con permiso de ESCRITURA para la próxima sesión

- Solo los definidos explícitamente en la tarea que se active.

---

## Notas

- `lib/config.dart` es el **único lugar** donde vive la URL base. No hay strings hardcodeados en servicios ni pantallas.
- Fallback Android: `http://192.168.40.15:3005` (dispositivo físico LAN).
- Web/Desktop/iOS: `http://localhost:3005`.
- Para cambiar de red: `--dart-define=BASE_URL=http://<nueva-ip>:3005` sin tocar código.
- `flutter analyze lib` pasa sin errores (verificado 2026-09-25).
