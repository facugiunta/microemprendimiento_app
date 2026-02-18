import 'package:mobile_app/services/api_service.dart';
import 'package:mobile_app/models/auditoria.dart';

class AuditoriaService {
  static Future<Map<String, dynamic>> listarAuditoria({
    int page = 1,
    String? entidad,
    String? accion,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      String endpoint = '/auditoria?pagina=$page&limite=20';
      if (entidad != null && entidad.isNotEmpty) {
        endpoint += '&entidad=$entidad';
      }
      if (accion != null && accion.isNotEmpty) {
        endpoint += '&accion=$accion';
      }
      if (fechaInicio != null) {
        endpoint +=
            '&fecha_desde=${fechaInicio.toIso8601String().split('T')[0]}';
      }
      if (fechaFin != null) {
        endpoint += '&fecha_hasta=${fechaFin.toIso8601String().split('T')[0]}';
      }

      final response = await ApiService.get(endpoint);

      if (response['success'] == true) {
        final auditoria = (response['data'] as List)
            .map((item) => Auditoria.fromJson(item as Map<String, dynamic>))
            .toList();

        return {
          'success': true,
          'auditoria': auditoria,
          'paginacion': response['paginacion'] ?? {},
        };
      }

      throw ApiException(response['mensaje'] ?? 'Error al listar auditoría');
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Auditoria>> obtenerHistoriaEntidad(
    String entidad,
    int entidadId,
  ) async {
    try {
      final response = await ApiService.get(
        '/auditoria/entidad/$entidad/$entidadId',
      );

      if (response['success'] == true) {
        final auditoria = (response['data'] as List)
            .map((item) => Auditoria.fromJson(item as Map<String, dynamic>))
            .toList();
        return auditoria;
      }

      throw ApiException(
        response['mensaje'] ?? 'Error al obtener el historial',
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> obtenerResumenMensual() async {
    try {
      final response = await ApiService.get('/auditoria/resumen');

      if (response['success'] == true) {
        return {'success': true, 'resumen': response['data']};
      }

      throw ApiException(response['mensaje'] ?? 'Error al obtener el resumen');
    } catch (e) {
      rethrow;
    }
  }
}
