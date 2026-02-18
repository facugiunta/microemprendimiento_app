class ApiConfig {
  // Base URL apuntando a Render
  static const String baseUrl =
      "https://microemprendimiento-app.onrender.com/api";

  // Timeout para requests HTTP
  static const int timeoutSeconds = 15;

  // Keys para almacenamiento local
  static const String tokenKey = 'jwt_token';
  static const String userKey = 'user_data';
}
