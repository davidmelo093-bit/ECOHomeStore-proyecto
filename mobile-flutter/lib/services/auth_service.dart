import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'api_exceptions.dart';

/// Autenticación contra POST /auth/login. Token solo en memoria (no persistente).
class AuthService {
  // ── Login ──────────────────────────────────────────────────────────────────

  /// Autentica al usuario y devuelve el token.
  /// Lanza [ApiException] con mensaje si falla la solicitud.
  static Future<String> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return body['token'] as String;
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        throw ClientErrorException(body['error'] ?? 'Credenciales inválidas', statusCode: response.statusCode);
      } else if (response.statusCode >= 500) {
        throw ServerErrorException('Error de servidor (${response.statusCode})', response.statusCode);
      }

      throw ClientErrorException(body['error'] ?? 'Error inesperado', statusCode: response.statusCode);
    } on TimeoutException {
      throw const NetworkTimeoutException();
    } on SocketException {
      throw const NetworkConnectionException();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkConnectionException('Error de conexión: $e');
    }
  }

  // ── JWT util ───────────────────────────────────────────────────────────────

  static Map<String, dynamic>? _decodePayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      return jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
    } catch (_) {
      return null;
    }
  }

  /// Extrae el username del payload JWT (solo display, sin verificar firma).
  static String extractUsername(String token, {String fallback = ''}) =>
      (_decodePayload(token)?['username'] as String?) ?? fallback;

  /// Extrae el role del payload JWT (solo display/evaluación UI, sin verificar firma).
  static String extractRole(String token, {String fallback = 'cliente'}) =>
      (_decodePayload(token)?['role'] as String?) ?? fallback;
}
