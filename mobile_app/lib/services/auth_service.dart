import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/services/api_service.dart';
import 'package:mobile_app/models/usuario.dart';
import 'package:mobile_app/config/api_config.dart';

class AuthService {
  static Future<Map<String, dynamic>> register({
    required String nombre,
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiService.post(
        '/auth/register',
        body: {'nombre': nombre, 'email': email, 'password': password},
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        final token = data['token'] as String;
        final usuario = Usuario.fromJson(data);

        await _saveToken(token);
        await _saveUser(usuario);

        return {'success': true, 'token': token, 'usuario': usuario};
      }

      throw ApiException(response['mensaje'] ?? 'Error al registrarse');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiService.post(
        '/auth/login',
        body: {'email': email, 'password': password},
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        final token = data['token'] as String;
        final usuario = Usuario.fromJson(data);

        await _saveToken(token);
        await _saveUser(usuario);

        return {'success': true, 'token': token, 'usuario': usuario};
      }

      throw ApiException(response['mensaje'] ?? 'Error al iniciar sesión');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Usuario?> getMe() async {
    try {
      final response = await ApiService.get('/auth/me');

      if (response['success'] == true && response['data'] != null) {
        final usuario = Usuario.fromJson(
          response['data'] as Map<String, dynamic>,
        );
        await _saveUser(usuario);
        return usuario;
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiConfig.tokenKey);
  }

  static Future<Usuario?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(ApiConfig.userKey);
    if (userJson != null) {
      return Usuario.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    }
    return null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConfig.tokenKey);
    await prefs.remove(ApiConfig.userKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConfig.tokenKey, token);
  }

  static Future<void> _saveUser(Usuario usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConfig.userKey, jsonEncode(usuario.toJson()));
  }
}
