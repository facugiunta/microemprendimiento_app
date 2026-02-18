import 'dart:io';

class ApiConfig {
  static const String _apiBaseFromEnv = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_apiBaseFromEnv.isNotEmpty) {
      return _apiBaseFromEnv;
    }

    if (Platform.isAndroid) {
      // For local development on Android emulator.
      return 'http://10.0.2.2:3000/api';
    } else if (Platform.isIOS) {
      return 'http://localhost:3000/api'; // iOS Simulator
    } else {
      return 'http://localhost:3000/api'; // Windows, macOS
    }
  }

  static const int timeoutSeconds = 15;
  static const String tokenKey = 'jwt_token';
  static const String userKey = 'user_data';
}
