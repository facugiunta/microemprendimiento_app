import 'package:mobile_app/services/api_service.dart';
import 'package:mobile_app/models/venta.dart';

class VentaService {
  static Future<Map<String, dynamic>> listarVentas({
    int page = 1,
    String? filtro = 'todos',
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      String endpoint = '/ventas?pagina=$page&limite=20';
      if (fechaInicio != null) {
        endpoint +=
            '&fecha_desde=${fechaInicio.toIso8601String().split('T')[0]}';
      }
      if (fechaFin != null) {
        endpoint += '&fecha_hasta=${fechaFin.toIso8601String().split('T')[0]}';
      }

      final response = await ApiService.get(endpoint);

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

      throw ApiException(response['mensaje'] ?? 'Error al listar ventas');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> registrarVenta({
    required int productoId,
    required int cantidad,
    required double precioUnitario,
    String? nota,
  }) async {
    try {
      final response = await ApiService.post(
        '/ventas',
        body: {
          'producto_id': productoId,
          'cantidad': cantidad,
          'precio_unitario': precioUnitario,
          'nota': nota,
        },
      );

      if (response['success'] == true && response['data'] != null) {
        return {
          'success': true,
          'venta': Venta.fromJson(response['data'] as Map<String, dynamic>),
          'advertencia_stock': response['advertencia_stock'] ?? false,
          'mensaje_advertencia': response['mensaje_advertencia'],
        };
      }

      throw ApiException(response['mensaje'] ?? 'Error al registrar la venta');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Venta> obtenerVenta(int id) async {
    try {
      final response = await ApiService.get('/ventas/$id');

      if (response['success'] == true && response['data'] != null) {
        return Venta.fromJson(response['data'] as Map<String, dynamic>);
      }

      throw ApiException(response['mensaje'] ?? 'Error al obtener la venta');
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
        '/ventas/historial/dia?fecha=$fechaStr',
      );

      if (response['success'] == true) {
        final data = (response['data'] as List)
            .map((item) => Venta.fromJson(item as Map<String, dynamic>))
            .toList();

        return {
          'success': true,
          'ventas': data,
          'total': data.fold<double>(0.0, (sum, venta) => sum + venta.total),
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
        '/ventas/historial/mes?mes=$mes&ano=$ano',
      );

      if (response['success'] == true) {
        final data = (response['data'] as List)
            .map((item) => Venta.fromJson(item as Map<String, dynamic>))
            .toList();

        return {
          'success': true,
          'ventas': data,
          'total': data.fold<double>(0.0, (sum, venta) => sum + venta.total),
          'cantidad': data.length,
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
        '/ventas/historial/rango?fecha_desde=$inicio&fecha_hasta=$fin',
      );

      if (response['success'] == true) {
        final data = (response['data'] as List)
            .map((item) => Venta.fromJson(item as Map<String, dynamic>))
            .toList();

        return {
          'success': true,
          'ventas': data,
          'total': data.fold<double>(0.0, (sum, venta) => sum + venta.total),
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
