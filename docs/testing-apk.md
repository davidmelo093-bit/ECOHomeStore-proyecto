# Cómo probar la APK — store_app

## 1. Generar la APK

```bash
flutter build apk --debug
```

El archivo queda en:
```
build/app/outputs/flutter-apk/app-debug.apk
```

> Para release: `flutter build apk --release`

---

## 2. Opción A — Dispositivo físico (recomendado)

1. En el teléfono: **Ajustes → Opciones de desarrollador → Depuración USB** ✓  
2. Conectar con cable USB y aceptar el aviso de confianza.
3. Verificar que el dispositivo aparece:
   ```bash
   adb devices
   ```
4. Instalar:
   ```bash
   adb install build/app/outputs/flutter-apk/app-debug.apk
   ```
5. Abrir **store_app** en el cajón de apps.

---

## 3. Opción B — Emulador Android

1. Abrir Android Studio → **Device Manager** → iniciar un AVD (API 30+).  
2. Una vez que el emulador esté corriendo:
   ```bash
   flutter run
   ```
   *(Flutter detecta el emulador y despliega en caliente)*

   O instalar la APK directamente:
   ```bash
   adb install build/app/outputs/flutter-apk/app-debug.apk
   ```

---

## 4. Opción C — Instalar APK sin cable (sideload)

1. Copiar `app-debug.apk` al teléfono (USB, Google Drive, etc.).
2. En el teléfono: **Ajustes → Seguridad → Fuentes desconocidas** ✓  
3. Abrir el archivo desde el explorador de archivos y tocar **Instalar**.

---

## 5. Credenciales de prueba

> Actualiza estos valores según tu entorno de backend.

| Campo    | Valor de prueba          |
|----------|--------------------------|
| Email    | `usuario@test.com`       |
| Password | `password123`            |
| API base | `http://10.0.2.2:3000`  *(emulador)* / IP local *(dispositivo físico)* |

---

## 6. Flujos a verificar

- [ ] Login con credenciales válidas → redirige a productos
- [ ] Login con credenciales inválidas → muestra error
- [ ] Lista de productos carga correctamente
- [ ] Tap en producto → pantalla de detalle
- [ ] Chat: enviar mensaje y recibir respuesta vía socket
- [ ] Logout (si aplica)

---

## 7. Logs en tiempo real

```bash
flutter logs
# o filtrar por tag de la app:
adb logcat -s flutter
```
