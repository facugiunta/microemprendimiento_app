class ReporteMensual {
  final int? id;
  final String mes; // e.g., "2024-02"
  final double totalVentas;
  final double totalCompras;
  final double totalInversiones;
  final double gananciaNeta;

  ReporteMensual({
    this.id,
    required this.mes,
    required this.totalVentas,
    required this.totalCompras,
    required this.totalInversiones,
    required this.gananciaNeta,
  });

  factory ReporteMensual.fromJson(Map<String, dynamic> json) {
    final mesValor = json['mes'];
    final anioValor = json['anio'];

    String mesTexto = '';
    if (mesValor is String && mesValor.isNotEmpty) {
      mesTexto = mesValor;
    } else {
      final mesInt = int.tryParse('${mesValor ?? 0}') ?? 0;
      final anioInt = int.tryParse('${anioValor ?? 0}') ?? 0;
      if (mesInt > 0 && anioInt > 0) {
        mesTexto = '${anioInt.toString().padLeft(4, '0')}-${mesInt.toString().padLeft(2, '0')}';
      }
    }

    return ReporteMensual(
      id: int.tryParse('${json['id'] ?? ''}'),
      mes: mesTexto,
      totalVentas:
          double.tryParse('${json['total_ventas'] ?? json['ventas'] ?? 0}') ??
          0.0,
      totalCompras:
          double.tryParse('${json['total_compras'] ?? json['compras'] ?? 0}') ??
          0.0,
      totalInversiones:
          double.tryParse(
            '${json['total_inversiones'] ?? json['inversiones'] ?? 0}',
          ) ??
          0.0,
      gananciaNeta:
          double.tryParse('${json['ganancia_neta'] ?? json['ganancia'] ?? 0}') ??
          0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'mes': mes,
    'total_ventas': totalVentas,
    'total_compras': totalCompras,
    'total_inversiones': totalInversiones,
    'ganancia_neta': gananciaNeta,
  };
}
