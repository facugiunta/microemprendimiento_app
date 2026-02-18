import 'package:mobile_app/services/api_service.dart';
import 'package:mobile_app/models/reporte_mensual.dart';
import 'package:mobile_app/models/reporte_feria.dart';

class ReporteService {
  static Future<ReporteMensual> obtenerReporteMensual(int mes, int ano) async {
    try {
      final response = await ApiService.get(
        '/reportes/mensual?mes=$mes&ano=$ano',
      );

      if (response['success'] == true && response['data'] != null) {
        return ReporteMensual.fromJson(
          response['data'] as Map<String, dynamic>,
        );
      }

      throw ApiException(
        response['mensaje'] ?? 'Error al obtener el reporte mensual',
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> obtenerHistorialReportesMensuales({
    int page = 1,
  }) async {
    try {
      final response = await ApiService.get(
        '/reportes/mensual/historial?pagina=$page&limite=12',
      );

      if (response['success'] == true) {
        final reportes = (response['data'] as List)
            .map(
              (item) => ReporteMensual.fromJson(item as Map<String, dynamic>),
            )
            .toList();

        return {'success': true, 'reportes': reportes};
      }

      throw ApiException(
        response['mensaje'] ?? 'Error al obtener el historial de reportes',
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> obtenerReporteAnual(int ano) async {
    try {
      final response = await ApiService.get('/reportes/anual?ano=$ano');

      if (response['success'] == true) {
        return {'success': true, 'data': response['data']};
      }

      throw ApiException(
        response['mensaje'] ?? 'Error al obtener el reporte anual',
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<ReporteFeria> crearReporteFeria({
    required String nombreFeria,
    required DateTime fechaFeria,
    required double inversionPuesto,
    required double gastosVarios,
    required List<Map<String, dynamic>> productos,
    String? nota,
  }) async {
    try {
      final response = await ApiService.post(
        '/reportes/feria',
        body: {
          'nombre_feria': nombreFeria,
          'fecha_feria': fechaFeria.toIso8601String(),
          'inversion_puesto': inversionPuesto,
          'gastos_varios': gastosVarios,
          'productos_vendidos': productos,
          'nota': nota,
        },
      );

      if (response['success'] == true && response['data'] != null) {
        return ReporteFeria.fromJson(response['data'] as Map<String, dynamic>);
      }

      throw ApiException(
        response['mensaje'] ?? 'Error al crear el reporte de feria',
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> listarReportesFeria({
    int page = 1,
  }) async {
    try {
      final response = await ApiService.get(
        '/reportes/feria?pagina=$page&limite=10',
      );

      if (response['success'] == true) {
        final reportes = (response['data'] as List)
            .map((item) => ReporteFeria.fromJson(item as Map<String, dynamic>))
            .toList();

        return {
          'success': true,
          'reportes': reportes,
          'paginacion': response['paginacion'] ?? {},
        };
      }

      throw ApiException(
        response['mensaje'] ?? 'Error al listar reportes de feria',
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<ReporteFeria> obtenerReporteFeria(int id) async {
    try {
      final response = await ApiService.get('/reportes/feria/$id');

      if (response['success'] == true && response['data'] != null) {
        return ReporteFeria.fromJson(response['data'] as Map<String, dynamic>);
      }

      throw ApiException(
        response['mensaje'] ?? 'Error al obtener el reporte de feria',
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> eliminarReporteFeria(int id) async {
    try {
      final response = await ApiService.delete('/reportes/feria/$id');

      if (response['success'] != true) {
        throw ApiException(
          response['mensaje'] ?? 'Error al eliminar el reporte de feria',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
