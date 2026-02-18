class Purchase {
  final String id;
  final String numeroCompra;
  final DateTime fecha;
  final String proveedorId;
  final String usuarioId;
  final double total;
  final double impuesto;
  final String estado;
  final DateTime? fechaPago;
  final String? metodoPago;
  final String? notas;
  final List<PurchaseDetail> detalles;

  Purchase({
    required this.id,
    required this.numeroCompra,
    required this.fecha,
    required this.proveedorId,
    required this.usuarioId,
    required this.total,
    required this.impuesto,
    required this.estado,
    this.fechaPago,
    this.metodoPago,
    this.notas,
    required this.detalles,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'] ?? '',
      numeroCompra: json['numero_compra'] ?? '',
      fecha: DateTime.parse(json['fecha'] ?? DateTime.now().toIso8601String()),
      proveedorId: json['proveedor_id'] ?? '',
      usuarioId: json['usuario_id'] ?? '',
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0,
      impuesto: double.tryParse(json['impuesto']?.toString() ?? '0') ?? 0,
      estado: json['estado'] ?? 'pendiente',
      fechaPago: json['fecha_pago'] != null
          ? DateTime.parse(json['fecha_pago'])
          : null,
      metodoPago: json['metodo_pago'],
      notas: json['notas'],
      detalles: (json['detalles'] as List? ?? [])
          .map((e) => PurchaseDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PurchaseDetail {
  final String id;
  final String compraId;
  final String productoId;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  PurchaseDetail({
    required this.id,
    required this.compraId,
    required this.productoId,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory PurchaseDetail.fromJson(Map<String, dynamic> json) {
    return PurchaseDetail(
      id: json['id'] ?? '',
      compraId: json['compra_id'] ?? '',
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
