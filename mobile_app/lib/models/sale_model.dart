class Sale {
  final String id;
  final String numeroVenta;
  final DateTime fecha;
  final String usuarioId;
  final double total;
  final double descuento;
  final double impuesto;
  final String estado;
  final String? metodoPago;
  final String? notas;
  final List<SaleDetail> detalles;

  Sale({
    required this.id,
    required this.numeroVenta,
    required this.fecha,
    required this.usuarioId,
    required this.total,
    required this.descuento,
    required this.impuesto,
    required this.estado,
    this.metodoPago,
    this.notas,
    required this.detalles,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'] ?? '',
      numeroVenta: json['numero_venta'] ?? '',
      fecha: DateTime.parse(json['fecha'] ?? DateTime.now().toIso8601String()),
      usuarioId: json['usuario_id'] ?? '',
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0,
      descuento: double.tryParse(json['descuento']?.toString() ?? '0') ?? 0,
      impuesto: double.tryParse(json['impuesto']?.toString() ?? '0') ?? 0,
      estado: json['estado'] ?? 'pendiente',
      metodoPago: json['metodo_pago'],
      notas: json['notas'],
      detalles: (json['detalles'] as List? ?? [])
          .map((e) => SaleDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SaleDetail {
  final String id;
  final String ventaId;
  final String productoId;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  SaleDetail({
    required this.id,
    required this.ventaId,
    required this.productoId,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory SaleDetail.fromJson(Map<String, dynamic> json) {
    return SaleDetail(
      id: json['id'] ?? '',
      ventaId: json['venta_id'] ?? '',
      productoId: json['producto_id'] ?? '',
      cantidad: json['cantidad'] ?? 0,
      precioUnitario:
          double.tryParse(json['precio_unitario']?.toString() ?? '0') ?? 0,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'producto_id': productoId,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
    };
  }
}
