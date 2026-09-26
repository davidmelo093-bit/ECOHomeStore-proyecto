import 'dart:async';
import 'dart:io';

/// Excepción base para errores de red en la aplicación.
abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Error por tiempo de espera agotado (TimeoutException / SocketException de red).
class NetworkTimeoutException extends ApiException {
  const NetworkTimeoutException([super.message = 'Tiempo de espera agotado. Verifica tu conexión.']);
}

/// Error por falla de conexión (sin conexión a internet, servidor no alcanzable).
class NetworkConnectionException extends ApiException {
  const NetworkConnectionException([super.message = 'No se pudo conectar con el servidor.']);
}

/// Error por cliente HTTP 4xx (400 Bad Request, 401 Unauthorized, 403 Forbidden, 404 Not Found, etc.).
class ClientErrorException extends ApiException {
  const ClientErrorException(super.message, {super.statusCode});
}

/// Error de servidor HTTP 5xx (500 Internal Server Error, 502 Bad Gateway, 503 Service Unavailable, etc.).
class ServerErrorException extends ApiException {
  const ServerErrorException([super.message = 'Error interno del servidor (5xx). Intenta más tarde.', int? statusCode])
      : super(statusCode: statusCode);
}

/// Helper para convertir excepciones de http / SocketException / TimeoutException en [ApiException].
ApiException handleHttpError(Object error, [int? statusCode]) {
  if (error is TimeoutException) {
    return const NetworkTimeoutException();
  }
  if (error is SocketException) {
    return const NetworkConnectionException();
  }
  if (error is ApiException) {
    return error;
  }
  
  if (statusCode != null) {
    if (statusCode >= 400 && statusCode < 500) {
      return ClientErrorException(error.toString(), statusCode: statusCode);
    }
    if (statusCode >= 500) {
      return ServerErrorException('Error de servidor ($statusCode)', statusCode);
    }
  }
  
  return NetworkConnectionException(error.toString());
}
