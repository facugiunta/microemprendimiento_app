import 'package:mobile_app/services/api_service.dart';

class ExportarService {
  static Future<List<int>> exportarProductos() async {
    return ApiService.getBytes('/exportar/productos');
  }

  static Future<List<int>> exportarCompras({
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    String endpoint = '/exportar/compras';
    if (fechaInicio != null && fechaFin != null) {
      endpoint += '?mes=${fechaInicio.month}&ano=${fechaInicio.year}';
    }
    return ApiService.getBytes(endpoint);
  }

  static Future<List<int>> exportarVentas({
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    String endpoint = '/exportar/ventas';
    if (fechaInicio != null && fechaFin != null) {
      endpoint += '?mes=${fechaInicio.month}&ano=${fechaInicio.year}';
    }
    return ApiService.getBytes(endpoint);
  }

  static Future<List<int>> exportarInversiones({int? mes, int? ano}) async {
    String endpoint = '/exportar/inversiones';
    if (mes != null && ano != null) {
      endpoint += '?mes=$mes&ano=$ano';
    }
    return ApiService.getBytes(endpoint);
  }

  static Future<List<int>> exportarReporteMensual(int mes, int ano) async {
    return ApiService.getBytes('/exportar/reporte-mensual?mes=$mes&ano=$ano');
  }

  static Future<List<int>> exportarAuditoria({
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    return ApiService.getBytes('/exportar/auditoria');
  }
}
