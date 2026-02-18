import 'package:mobile_app/services/api_service.dart';
import 'package:mobile_app/models/compra.dart';

class CompraService {
  static Future<Map<String, dynamic>> listarCompras({
    int page = 1,
    String? filtro = 'todos',
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      String endpoint = '/compras?pagina=$page&limite=20';
      if (fechaInicio != null) {
        endpoint +=
            '&fecha_desde=${fechaInicio.toIso8601String().split('T')[0]}';
      }
      if (fechaFin != null) {
        endpoint += '&fecha_hasta=${fechaFin.toIso8601String().split('T')[0]}';
      }

      final response = await ApiService.get(endpoint);

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

      throw ApiException(response['mensaje'] ?? 'Error al listar compras');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Compra> registrarCompra({
    required int productoId,
    required int cantidad,
    required double precioUnitario,
    String? proveedor,
    String? nota,
  }) async {
    try {
      final response = await ApiService.post(
        '/compras',
        body: {
          'producto_id': productoId,
          'cantidad': cantidad,
          'precio_unitario': precioUnitario,
          'proveedor': proveedor,
          'nota': nota,
        },
      );

      if (response['success'] == true && response['data'] != null) {
        return Compra.fromJson(response['data'] as Map<String, dynamic>);
      }

      throw ApiException(response['mensaje'] ?? 'Error al registrar la compra');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Compra> obtenerCompra(int id) async {
    try {
      final response = await ApiService.get('/compras/$id');

      if (response['success'] == true && response['data'] != null) {
        return Compra.fromJson(response['data'] as Map<String, dynamic>);
      }

      throw ApiException(response['mensaje'] ?? 'Error al obtener la compra');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> obtenerHistorialPorDia(
    DateTime fecha,
  ) async {
    try {
      final fechaStr = fecha.toIso8601String().split('T')[0];
      final response = await ApiService.get(
        '/compras/historial/dia?fecha=$fechaStr',
      );

      if (response['success'] == true) {
        final data = (response['data'] as List)
            .map((item) => Compra.fromJson(item as Map<String, dynamic>))
            .toList();

        return {
          'success': true,
          'compras': data,
          'total': data.fold<double>(0.0, (sum, compra) => sum + compra.total),
          'cantidad': data.length,
        };
      }

      throw ApiException(response['mensaje'] ?? 'Error al obtener historial');
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
        '/compras/historial/mes?mes=$mes&ano=$ano',
      );

      if (response['success'] == true) {
        return {
          'success': true,
          'total': response['total'] ?? 0.0,
          'cantidad': response['cantidad'] ?? 0,
        };
      }

      throw ApiException(
        response['mensaje'] ?? 'Error al obtener historial del mes',
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> obtenerHistorialPorRango(
    DateTime fechaInicio,
    DateTime fechaFin,
  ) async {
    try {
      final inicio = fechaInicio.toIso8601String().split('T')[0];
      final fin = fechaFin.toIso8601String().split('T')[0];
      final response = await ApiService.get(
        '/compras/historial/rango?fecha_desde=$inicio&fecha_hasta=$fin',
      );

      if (response['success'] == true) {
        final data = (response['data'] as List)
            .map((item) => Compra.fromJson(item as Map<String, dynamic>))
            .toList();

        return {
          'success': true,
          'compras': data,
          'total': data.fold<double>(0.0, (sum, compra) => sum + compra.total),
          'cantidad': data.length,
        };
      }

      throw ApiException(
        response['mensaje'] ?? 'Error al obtener historial del rango',
      );
    } catch (e) {
      rethrow;
    }
  }
}
