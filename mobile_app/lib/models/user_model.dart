class User {
  final String id;
  final String email;
  final String name;
  final String role;
  final int? issuedAt;
  final int? expiresAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.issuedAt,
    this.expiresAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['nombre'] ?? json['name'] ?? json['email'] ?? '',
      role: json['rol'] ?? json['role'] ?? 'vendedor',
      issuedAt: json['iat'],
      expiresAt: json['exp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'iat': issuedAt,
      'exp': expiresAt,
    };
  }
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User? user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}
