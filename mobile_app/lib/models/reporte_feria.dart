class ReporteFeria {
  final int id;
  final int usuarioId;
  final String nombreFeria;
  final DateTime fechaFeria;
  final double inversionPuesto;
  final double gastosVarios;
  final double totalVentas;
  final double totalCostoProductos;
  final double gananciaNeta;
  final String? nota;
  final DateTime createdAt;
  final List<ReporteFeriaItem>? items;

  ReporteFeria({
    required this.id,
    required this.usuarioId,
    required this.nombreFeria,
    required this.fechaFeria,
    required this.inversionPuesto,
    required this.gastosVarios,
    required this.totalVentas,
    required this.totalCostoProductos,
    required this.gananciaNeta,
    this.nota,
    required this.createdAt,
    this.items,
  });

  factory ReporteFeria.fromJson(Map<String, dynamic> json) {
    final createdAtRaw =
        json['created_at'] ?? json['createdAt'] ?? DateTime.now().toString();

    return ReporteFeria(
      id: int.tryParse('${json['id']}') ?? 0,
      usuarioId: int.tryParse('${json['usuario_id'] ?? 0}') ?? 0,
      nombreFeria: json['nombre_feria'] as String,
      fechaFeria: DateTime.parse(json['fecha_feria'] as String),
      inversionPuesto:
          double.tryParse('${json['inversion_puesto'] ?? 0}') ?? 0.0,
      gastosVarios: double.tryParse('${json['gastos_varios'] ?? 0}') ?? 0.0,
      totalVentas: double.tryParse('${json['total_ventas'] ?? 0}') ?? 0.0,
      totalCostoProductos:
          double.tryParse('${json['total_costo_productos'] ?? 0}') ?? 0.0,
      gananciaNeta: double.tryParse('${json['ganancia_neta'] ?? 0}') ?? 0.0,
      nota: json['nota'] as String?,
      createdAt: DateTime.parse('$createdAtRaw'),
      items: (json['items'] as List?)
          ?.map(
            (item) => ReporteFeriaItem.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuario_id': usuarioId,
    'nombre_feria': nombreFeria,
    'fecha_feria': fechaFeria.toIso8601String(),
    'inversion_puesto': inversionPuesto,
    'gastos_varios': gastosVarios,
    'total_ventas': totalVentas,
    'total_costo_productos': totalCostoProductos,
    'ganancia_neta': gananciaNeta,
    'nota': nota,
    'created_at': createdAt.toIso8601String(),
  };
}

class ReporteFeriaItem {
  final int id;
  final int reporteFeriaId;
  final int productoId;
  final String nombreProducto;
  final int cantidad;
  final double precioCompra;
  final double precioVenta;
  final double subtotalGanancia;

  ReporteFeriaItem({
    required this.id,
    required this.reporteFeriaId,
    required this.productoId,
    required this.nombreProducto,
    required this.cantidad,
    required this.precioCompra,
    required this.precioVenta,
    required this.subtotalGanancia,
  });

  factory ReporteFeriaItem.fromJson(Map<String, dynamic> json) {
    return ReporteFeriaItem(
      id: int.tryParse('${json['id']}') ?? 0,
      reporteFeriaId: int.tryParse('${json['reporte_feria_id'] ?? 0}') ?? 0,
      productoId: int.tryParse('${json['producto_id'] ?? 0}') ?? 0,
      nombreProducto: json['nombre_producto'] as String,
      cantidad: int.tryParse('${json['cantidad'] ?? 0}') ?? 0,
      precioCompra: double.tryParse('${json['precio_compra'] ?? 0}') ?? 0.0,
      precioVenta: double.tryParse('${json['precio_venta'] ?? 0}') ?? 0.0,
      subtotalGanancia:
          double.tryParse('${json['subtotal_ganancia'] ?? 0}') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'reporte_feria_id': reporteFeriaId,
    'producto_id': productoId,
    'nombre_producto': nombreProducto,
    'cantidad': cantidad,
    'precio_compra': precioCompra,
    'precio_venta': precioVenta,
    'subtotal_ganancia': subtotalGanancia,
  };
}
