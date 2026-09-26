import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'api_exceptions.dart';

/// Cliente HTTP para la API REST de Act01 (localhost:3005).
class ApiService {
  // ── Productos ──────────────────────────────────────────────────────────────

  /// GET /products — ruta pública, no requiere JWT.
  static Future<List<dynamic>> getProducts() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/products'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        throw ClientErrorException('Error del cliente (${response.statusCode})', statusCode: response.statusCode);
      } else if (response.statusCode >= 500) {
        throw ServerErrorException('Error de servidor (${response.statusCode})', response.statusCode);
      }
      throw ClientErrorException('Error inesperado (${response.statusCode})', statusCode: response.statusCode);
    } on TimeoutException {
      throw const NetworkTimeoutException();
    } on SocketException {
      throw const NetworkConnectionException();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkConnectionException('Error al obtener productos: $e');
    }
  }

  // ── Admin Operaciones CRUD ──────────────────────────────────────────────────

  /// DELETE /products/:id — requiere JWT + rol admin.
  static Future<void> deleteProduct(int id, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/products/$id'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        final body = jsonDecode(response.body);
        throw ClientErrorException(body['error'] ?? 'Error al eliminar producto', statusCode: response.statusCode);
      } else if (response.statusCode >= 500) {
        throw ServerErrorException('Error de servidor (${response.statusCode})', response.statusCode);
      }
    } on TimeoutException {
      throw const NetworkTimeoutException();
    } on SocketException {
      throw const NetworkConnectionException();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkConnectionException('Error al eliminar producto: $e');
    }
  }

  /// PUT /products/:id — requiere JWT + rol admin.
  static Future<Map<String, dynamic>> updateProduct(int id, String name, double price, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/products/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'name': name, 'price': price}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        final body = jsonDecode(response.body);
        throw ClientErrorException(body['error'] ?? 'Error al actualizar producto', statusCode: response.statusCode);
      } else if (response.statusCode >= 500) {
        throw ServerErrorException('Error de servidor (${response.statusCode})', response.statusCode);
      }
      throw ClientErrorException('Error inesperado (${response.statusCode})', statusCode: response.statusCode);
    } on TimeoutException {
      throw const NetworkTimeoutException();
    } on SocketException {
      throw const NetworkConnectionException();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkConnectionException('Error al actualizar producto: $e');
    }
  }

  /// POST /products — requiere JWT + rol admin.
  static Future<Map<String, dynamic>> createProduct(String name, double price, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'name': name, 'price': price}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        final body = jsonDecode(response.body);
        throw ClientErrorException(body['error'] ?? 'Error al crear producto', statusCode: response.statusCode);
      } else if (response.statusCode >= 500) {
        throw ServerErrorException('Error de servidor (${response.statusCode})', response.statusCode);
      }
      throw ClientErrorException('Error inesperado (${response.statusCode})', statusCode: response.statusCode);
    } on TimeoutException {
      throw const NetworkTimeoutException();
    } on SocketException {
      throw const NetworkConnectionException();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkConnectionException('Error al crear producto: $e');
    }
  }
}

