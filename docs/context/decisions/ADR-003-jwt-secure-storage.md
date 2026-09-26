# ADR-003 — Persistencia del JWT con `flutter_secure_storage`

| Campo | Valor |
|---|---|
| **ID** | ADR-003 |
| **Fecha** | 2026-09-18 |
| **Estado** | Aceptada |

---

## Contexto

El JWT obtenido en login necesita persistirse entre sesiones para que el usuario
no deba autenticarse en cada arranque de la app.

---

## Decisión

Usar **`flutter_secure_storage ^9.2.2`**.  
Almacenamiento: clave `jwt_token` en el Keychain (iOS) / Keystore (Android) / Credential Locker (Windows).

---

## Alternativas descartadas

| Alternativa | Razón |
|---|---|
| `shared_preferences` | Almacenamiento en texto plano — inseguro para tokens JWT |
| Variable en memoria (`_MyAppState`) | Se pierde al cerrar la app |
| `hive` | Dependencia adicional innecesaria para un solo valor |

---

## Consecuencias

- ✅ El token sobrevive cierres de app y reinicios de dispositivo.
- ✅ Cifrado a nivel del SO — sin gestión de llaves propia.
- ⚠️ La IP del backend está hardcoded (`10.0.2.2`). Ver T-009 para parametrizar.
- ⚠️ En emulador Android, `10.0.2.2` apunta al host. En dispositivo físico se debe cambiar.

---

## Cuándo revisar

Si se requiere almacenar más datos de sesión (perfil, preferencias), evaluar `hive` o `isar`.
