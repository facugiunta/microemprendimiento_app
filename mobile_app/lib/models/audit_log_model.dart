class AuditLog {
  final String id;
  final String userId;
  final String resource;
  final String action;
  final bool allowed;
  final DateTime createdAt;

  AuditLog({
    required this.id,
    required this.userId,
    required this.resource,
    required this.action,
    required this.allowed,
    required this.createdAt,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id']?.toString() ?? '',
      userId: json['user_id'] ?? '',
      resource: json['resource'] ?? '',
      action: json['action'] ?? '',
      allowed: json['allowed'] ?? false,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
