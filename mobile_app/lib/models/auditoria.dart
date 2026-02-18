class Auditoria {
  final int id;
  final int usuarioId;
  final String accion;
  final String entidad;
  final int? entidadId;
  final Map<String, dynamic>? datosAnteriores;
  final Map<String, dynamic>? datosNuevos;
  final String? ip;
  final String? descripcion;
  final DateTime fecha;

  Auditoria({
    required this.id,
    required this.usuarioId,
    required this.accion,
    required this.entidad,
    this.entidadId,
    this.datosAnteriores,
    this.datosNuevos,
    this.ip,
    this.descripcion,
    required this.fecha,
  });

  factory Auditoria.fromJson(Map<String, dynamic> json) {
    return Auditoria(
      id: json['id'] as int,
      usuarioId: json['usuario_id'] as int,
      accion: json['accion'] as String,
      entidad: json['entidad'] as String,
      entidadId: json['entidad_id'] as int?,
      datosAnteriores: json['datos_anteriores'] as Map<String, dynamic>?,
      datosNuevos: json['datos_nuevos'] as Map<String, dynamic>?,
      ip: json['ip'] as String?,
      descripcion: json['descripcion'] as String?,
      fecha: DateTime.parse(json['fecha'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuario_id': usuarioId,
    'accion': accion,
    'entidad': entidad,
    'entidad_id': entidadId,
    'datos_anteriores': datosAnteriores,
    'datos_nuevos': datosNuevos,
    'ip': ip,
    'descripcion': descripcion,
    'fecha': fecha.toIso8601String(),
  };
}
