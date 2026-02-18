class Product {
  final String id;
  final String codigo;
  final String nombre;
  final String? descripcion;
  final String? categoria;
  final double precioCosto;
  final double precioVenta;
  final int stockActual;
  final int stockMinimo;
  final String unidadMedida;
  final bool activo;
  final DateTime creadoEn;

  Product({
    required this.id,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    this.categoria,
    required this.precioCosto,
    required this.precioVenta,
    required this.stockActual,
    required this.stockMinimo,
    required this.unidadMedida,
    required this.activo,
    required this.creadoEn,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      codigo: json['codigo'] ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      categoria: json['categoria'],
      precioCosto: double.tryParse(json['precio_costo']?.toString() ?? '0') ?? 0,
      precioVenta: double.tryParse(json['precio_venta']?.toString() ?? '0') ?? 0,
      stockActual: json['stock_actual'] ?? 0,
      stockMinimo: json['stock_minimo'] ?? 0,
      unidadMedida: json['unidad_medida'] ?? 'unidad',
      activo: json['activo'] ?? true,
      creadoEn: DateTime.parse(
        json['creado_en'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'nombre': nombre,
      'descripcion': descripcion,
      'categoria': categoria,
      'precio_costo': precioCosto,
      'precio_venta': precioVenta,
      'stock_actual': stockActual,
      'stock_minimo': stockMinimo,
      'unidad_medida': unidadMedida,
      'activo': activo,
    };
  }
}
