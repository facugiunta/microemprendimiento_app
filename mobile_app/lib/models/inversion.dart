class Inversion {
  final int id;
  final int usuarioId;
  final String nombre;
  final String? descripcion;
  final double monto;
  final String categoria;
  final DateTime fecha;
  final DateTime createdAt;

  Inversion({
    required this.id,
    required this.usuarioId,
    required this.nombre,
    this.descripcion,
    required this.monto,
    required this.categoria,
    required this.fecha,
    required this.createdAt,
  });

  static const List<String> categorias = [
    'Puesto de feria',
    'Packaging',
    'Stickers',
    'Transporte',
    'Marketing',
    'General',
    'Otro',
  ];

  factory Inversion.fromJson(Map<String, dynamic> json) {
    final createdAtRaw =
        json['created_at'] ?? json['createdAt'] ?? DateTime.now().toString();

    return Inversion(
      id: int.tryParse('${json['id']}') ?? 0,
      usuarioId: int.tryParse('${json['usuario_id'] ?? 0}') ?? 0,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      monto: double.tryParse('${json['monto'] ?? 0}') ?? 0.0,
      categoria: json['categoria'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      createdAt: DateTime.parse('$createdAtRaw'),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuario_id': usuarioId,
    'nombre': nombre,
    'descripcion': descripcion,
    'monto': monto,
    'categoria': categoria,
    'fecha': fecha.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
  };
}
