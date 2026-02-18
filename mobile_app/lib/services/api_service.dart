import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/config/api_config.dart';

// Custom Exceptions
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException([this.message = 'Conexion agotada (15 segundos)']);
  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = 'No autorizado. Inicia sesion nuevamente']);
  @override
  String toString() => message;
}

class BadRequestException implements Exception {
  final String message;
  BadRequestException(this.message);
  @override
  String toString() => message;
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);
  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  static const String _tokenKey = ApiConfig.tokenKey;
  static const String _userKey = ApiConfig.userKey;
  static const int _timeoutSeconds = ApiConfig.timeoutSeconds;

  static String get baseUrl => ApiConfig.baseUrl;

  // Get token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Save token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Clear token
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // Get headers with auth
  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Handle response
  static Future<Map<String, dynamic>> _handleResponse(
    http.Response response,
  ) async {
    try {
      final data = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      final errorMessage =
          (data['mensaje'] ?? data['error'] ?? 'Error desconocido').toString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else if (response.statusCode == 401) {
        await clearToken();
        throw UnauthorizedException(errorMessage);
      } else if (response.statusCode == 400) {
        throw BadRequestException(errorMessage);
      } else if (response.statusCode == 404) {
        throw NotFoundException(errorMessage);
      } else if (response.statusCode >= 500) {
        throw ServerException(errorMessage);
      } else {
        throw ApiException(errorMessage);
      }
    } catch (e) {
      if (e is ApiException ||
          e is UnauthorizedException ||
          e is BadRequestException ||
          e is NotFoundException ||
          e is ServerException) {
        rethrow;
      }
      throw ApiException('Error procesando respuesta: $e');
    }
  }

  // GET
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl$endpoint'), headers: headers)
          .timeout(
            const Duration(seconds: _timeoutSeconds),
            onTimeout: () => throw TimeoutException(),
          );
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No hay conexion al servidor');
    } on TimeoutException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // POST
  static Future<Map<String, dynamic>> post(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(
            const Duration(seconds: _timeoutSeconds),
            onTimeout: () => throw TimeoutException(),
          );
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No hay conexion al servidor');
    } on TimeoutException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // PUT
  static Future<Map<String, dynamic>> put(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(
            const Duration(seconds: _timeoutSeconds),
            onTimeout: () => throw TimeoutException(),
          );
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No hay conexion al servidor');
    } on TimeoutException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // DELETE
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .delete(Uri.parse('$baseUrl$endpoint'), headers: headers)
          .timeout(
            const Duration(seconds: _timeoutSeconds),
            onTimeout: () => throw TimeoutException(),
          );
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No hay conexion al servidor');
    } on TimeoutException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // GET bytes (for file downloads)
  static Future<List<int>> getBytes(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl$endpoint'), headers: headers)
          .timeout(
            const Duration(seconds: _timeoutSeconds),
            onTimeout: () => throw TimeoutException(),
          );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else if (response.statusCode == 401) {
        await clearToken();
        throw UnauthorizedException();
      }

      String message = 'Error descargando archivo';
      if (response.body.isNotEmpty) {
        try {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          message = (data['mensaje'] ?? data['error'] ?? message).toString();
        } catch (_) {}
      }
      throw ApiException(message);
    } on SocketException {
      throw ApiException('No hay conexion al servidor');
    } on TimeoutException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}

