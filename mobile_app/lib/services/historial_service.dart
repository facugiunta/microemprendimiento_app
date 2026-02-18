import 'package:mobile_app/services/api_service.dart';
import 'package:mobile_app/models/venta.dart';
import 'package:mobile_app/models/compra.dart';
import 'package:mobile_app/models/inversion.dart';

class HistorialService {
  static Future<Map<String, dynamic>> obtenerHistorialVentas({
    int page = 1,
  }) async {
    try {
      final response = await ApiService.get(
        '/historial/ventas?pagina=$page&limite=50',
      );

      if (response['success'] == true) {
        final ventas = (response['data'] as List)
            .map((item) => Venta.fromJson(item as Map<String, dynamic>))
            .toList();

        return {
          'success': true,
          'ventas': ventas,
          'paginacion': response['paginacion'] ?? {},
        };
      }

      throw ApiException(
        response['mensaje'] ?? 'Error al obtener historial de ventas',
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> obtenerHistorialCompras({
    int page = 1,
  }) async {
    try {
      final response = await ApiService.get(
        '/historial/compras?pagina=$page&limite=50',
      );

      if (response['success'] == true) {
        final compras = (response['data'] as List)
            .map((item) => Compra.fromJson(item as Map<String, dynamic>))
            .toList();

        return {
          'success': true,
          'compras': compras,
          'paginacion': response['paginacion'] ?? {},
        };
      }

      throw ApiException(
        response['mensaje'] ?? 'Error al obtener historial de compras',
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> obtenerHistorialInversiones({
    int page = 1,
  }) async {
    try {
      final response = await ApiService.get(
        '/historial/inversiones?pagina=$page&limite=50',
      );

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

      throw ApiException(
        response['mensaje'] ?? 'Error al obtener historial de inversiones',
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> obtenerHistorialReportes({
    int page = 1,
  }) async {
    try {
      final response = await ApiService.get(
        '/historial/reportes?pagina=$page&limite=50',
      );

      if (response['success'] == true) {
        return {
          'success': true,
          'reportes': response['data'] ?? [],
          'paginacion': response['paginacion'] ?? {},
        };
      }

      throw ApiException(
        response['mensaje'] ?? 'Error al obtener historial de reportes',
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> obtenerTimelineUnificado({
    int page = 1,
  }) async {
    try {
      final response = await ApiService.get(
        '/historial/todo?pagina=$page&limite=50',
      );

      if (response['success'] == true) {
        return {
          'success': true,
          'timeline': response['data'] ?? [],
          'paginacion': response['paginacion'] ?? {},
        };
      }

      throw ApiException(response['mensaje'] ?? 'Error al obtener el timeline');
    } catch (e) {
      rethrow;
    }
  }
}
