import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;

  AuthProvider();

  // Getters
  User? get user => _user;
  User? get usuario => _user; // Alias for compatibility
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;

  // Initialize - load saved token on app start
  Future<void> initialize() async {
    try {
      _token = await ApiService.getToken();

      if (_token != null && _token!.isNotEmpty) {
        try {
          final response = await AuthService.getMe();
          if (response != null) {
            _user = User(
              id: response.id.toString(),
              email: response.email,
              name: response.nombre,
              role: 'user',
            );
            _isLoggedIn = true;
          }
        } catch (e) {
          await ApiService.clearToken();
          _token = null;
          _isLoggedIn = false;
        }
      }

      notifyListeners();
    } catch (e) {
      _error = 'Error al inicializar: $e';
      notifyListeners();
    }
  }

  // Register
  Future<bool> register({
    required String nombre,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AuthService.register(
        nombre: nombre,
        email: email,
        password: password,
      );

      if (response['success'] == true) {
        // Auto-login after registration
        return await login(email: email, password: password);
      } else {
        _error = response['mensaje'] ?? 'Error al registrarse';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = _friendlyError(e);
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AuthService.login(
        email: email,
        password: password,
      );

      if (response['success'] == true) {
        _token = response['token'] as String?;
        final usuarioData = response['usuario'];
        if (usuarioData != null) {
          // Convert Usuario to User
          _user = User(
            id: usuarioData.id.toString(),
            email: usuarioData.email,
            name: usuarioData.nombre,
            role: 'user',
          );
        }
        _isLoggedIn = true;

        await ApiService.saveToken(_token ?? '');

        notifyListeners();
        return true;
      } else {
        _error = response['mensaje'] ?? 'Error al iniciar sesion';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = _friendlyError(e);
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _user = null;
      _token = null;
      _isLoggedIn = false;

      await ApiService.clearToken();

      notifyListeners();
    } catch (e) {
      _error = 'Error al cerrar sesion: $e';
      notifyListeners();
    }
  }

  // Get current user data
  Future<void> refreshUser() async {
    try {
      final response = await AuthService.getMe();
      if (response != null) {
        _user = User(
          id: response.id.toString(),
          email: response.email,
          name: response.nombre,
          role: 'user',
        );
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error al obtener datos del usuario: $e';
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _friendlyError(Object e) {
    if (e is UnauthorizedException) return e.message;
    if (e is BadRequestException) return e.message;
    if (e is NotFoundException) return e.message;
    if (e is ServerException) return e.message;
    if (e is TimeoutException) return e.message;
    if (e is ApiException) return e.message;
    return 'Ocurrio un error inesperado';
  }
}
