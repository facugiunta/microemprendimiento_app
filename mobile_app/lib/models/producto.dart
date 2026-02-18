class Producto {
  final int id;
  final int usuarioId;
  final String nombre;
  final String? descripcion;
  final int stock;
  final int stockMinimo;
  final double precioCompra;
  final double precioVenta;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;

  Producto({
    required this.id,
    required this.usuarioId,
    required this.nombre,
    this.descripcion,
    required this.stock,
    required this.stockMinimo,
    required this.precioCompra,
    required this.precioVenta,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get stockBajo => stock <= stockMinimo;

  double get margenGanancia => precioCompra > 0
      ? ((precioVenta - precioCompra) / precioCompra * 100)
      : 0;

  factory Producto.fromJson(Map<String, dynamic> json) {
    final createdAtRaw =
        json['created_at'] ?? json['createdAt'] ?? DateTime.now().toString();
    final updatedAtRaw =
        json['updated_at'] ?? json['updatedAt'] ?? createdAtRaw;

    return Producto(
      id: int.tryParse('${json['id']}') ?? 0,
      usuarioId: int.tryParse('${json['usuario_id'] ?? 0}') ?? 0,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      stock: int.tryParse('${json['stock'] ?? 0}') ?? 0,
      stockMinimo: int.tryParse('${json['stock_minimo'] ?? 0}') ?? 0,
      precioCompra: double.tryParse('${json['precio_compra'] ?? 0}') ?? 0.0,
      precioVenta: double.tryParse('${json['precio_venta'] ?? 0}') ?? 0.0,
      activo: json['activo'] as bool? ?? true,
      createdAt: DateTime.parse('$createdAtRaw'),
      updatedAt: DateTime.parse('$updatedAtRaw'),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuario_id': usuarioId,
    'nombre': nombre,
    'descripcion': descripcion,
    'stock': stock,
    'stock_minimo': stockMinimo,
    'precio_compra': precioCompra,
    'precio_venta': precioVenta,
    'activo': activo,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
