class Compra {
  final int id;
  final int usuarioId;
  final int productoId;
  final String nombreProducto;
  final int cantidad;
  final double precioUnitario;
  final double total;
  final String? proveedor;
  final String? nota;
  final DateTime fecha;
  final DateTime createdAt;

  Compra({
    required this.id,
    required this.usuarioId,
    required this.productoId,
    required this.nombreProducto,
    required this.cantidad,
    required this.precioUnitario,
    required this.total,
    this.proveedor,
    this.nota,
    required this.fecha,
    required this.createdAt,
  });

  factory Compra.fromJson(Map<String, dynamic> json) {
    final createdAtRaw =
        json['created_at'] ?? json['createdAt'] ?? DateTime.now().toString();

    return Compra(
      id: int.tryParse('${json['id']}') ?? 0,
      usuarioId: int.tryParse('${json['usuario_id'] ?? 0}') ?? 0,
      productoId: int.tryParse('${json['producto_id'] ?? 0}') ?? 0,
      nombreProducto: json['nombre_producto'] ?? 'Producto',
      cantidad: int.tryParse('${json['cantidad'] ?? 0}') ?? 0,
      precioUnitario: double.tryParse('${json['precio_unitario'] ?? 0}') ?? 0.0,
      total: double.tryParse('${json['total'] ?? 0}') ?? 0.0,
      proveedor: json['proveedor'] as String?,
      nota: json['nota'] as String?,
      fecha: DateTime.parse(json['fecha'] as String),
      createdAt: DateTime.parse('$createdAtRaw'),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuario_id': usuarioId,
    'producto_id': productoId,
    'cantidad': cantidad,
    'precio_unitario': precioUnitario,
    'total': total,
    'proveedor': proveedor,
    'nota': nota,
    'fecha': fecha.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
  };
}
