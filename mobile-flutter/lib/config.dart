import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// URL base del backend, parametrizable con `--dart-define=BASE_URL=http://...`
///
/// Si no se pasa mediante `--dart-define`, se determina en tiempo de ejecución:
/// - Web / Desktop → http://localhost:3005
/// - Android (dispositivo físico LAN) → http://192.168.40.15:3005
/// ponytail: IP fija para entorno LAN; usar --dart-define=BASE_URL=http://X.X.X.X:3005 si la IP cambia
String get baseUrl {
  const envUrl = String.fromEnvironment('BASE_URL');
  if (envUrl.isNotEmpty) return envUrl;

  if (kIsWeb) return 'http://localhost:3005';
  if (defaultTargetPlatform == TargetPlatform.android) return 'http://192.168.40.15:3005';
  return 'http://localhost:3005'; // iOS, macOS, Windows, Linux
}
