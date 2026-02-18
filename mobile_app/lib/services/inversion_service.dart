import 'package:mobile_app/services/api_service.dart';
import 'package:mobile_app/models/inversion.dart';

class InversionService {
  static Future<Map<String, dynamic>> listarInversiones({
    int page = 1,
    String? categoria,
    int? mes,
    int? ano,
  }) async {
    try {
      String endpoint = '/inversiones?pagina=$page&limite=20';
      if (categoria != null && categoria.isNotEmpty) {
        endpoint += '&categoria=$categoria';
      }
      if (mes != null && ano != null) {
        endpoint += '&mes=$mes&ano=$ano';
      }

      final response = await ApiService.get(endpoint);

      if (response['success'] == true) {
        final inversiones = (response['data'] as List)
            .map((item) => Inversion.fromJson(item as Map<String, dynamic>))
            .toList();

        return {
          'success': true,
          'inversiones': inversiones,
          'paginacion': response['paginacion'] ?? {},
        };
      }

      throw ApiException(response['mensaje'] ?? 'Error al listar inversiones');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Inversion> crearInversion({
    required String nombre,
    String? descripcion,
    required double monto,
    required String categoria,
    required DateTime fecha,
  }) async {
    try {
      final response = await ApiService.post(
        '/inversiones',
        body: {
          'nombre': nombre,
          'descripcion': descripcion,
          'monto': monto,
          'categoria': categoria,
          'fecha': fecha.toIso8601String(),
        },
      );

      if (response['success'] == true && response['data'] != null) {
        return Inversion.fromJson(response['data'] as Map<String, dynamic>);
      }

      throw ApiException(response['mensaje'] ?? 'Error al crear la inversión');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Inversion> obtenerInversion(int id) async {
    try {
      final response = await ApiService.get('/inversiones/$id');

      if (response['success'] == true && response['data'] != null) {
        return Inversion.fromJson(response['data'] as Map<String, dynamic>);
      }

      throw ApiException(
        response['mensaje'] ?? 'Error al obtener la inversión',
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<Inversion> actualizarInversion(
    int id, {
    required String nombre,
    String? descripcion,
    required double monto,
    required String categoria,
    required DateTime fecha,
  }) async {
    try {
      final response = await ApiService.put(
        '/inversiones/$id',
        body: {
          'nombre': nombre,
          'descripcion': descripcion,
          'monto': monto,
          'categoria': categoria,
          'fecha': fecha.toIso8601String(),
        },
      );

      if (response['success'] == true && response['data'] != null) {
        return Inversion.fromJson(response['data'] as Map<String, dynamic>);
      }

      throw ApiException(
        response['mensaje'] ?? 'Error al actualizar la inversión',
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> eliminarInversion(int id) async {
    try {
      final response = await ApiService.delete('/inversiones/$id');

      if (response['success'] != true) {
        throw ApiException(
          response['mensaje'] ?? 'Error al eliminar la inversión',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> obtenerHistorialPorMes(
    int mes,
    int ano,
  ) async {
    try {
      final response = await ApiService.get(
        '/inversiones/historial/mes?mes=$mes&ano=$ano',
      );

      if (response['success'] == true) {
        final inversiones = (response['data'] as List)
            .map((item) => Inversion.fromJson(item as Map<String, dynamic>))
            .toList();

        return {
          'success': true,
          'inversiones': inversiones,
          'total': response['total'] ?? 0.0,
        };
      }

      throw ApiException(
        response['mensaje'] ?? 'Error al obtener inversiones del mes',
      );
    } catch (e) {
      rethrow;
    }
  }
}
