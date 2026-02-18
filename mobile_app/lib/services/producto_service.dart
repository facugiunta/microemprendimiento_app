import 'package:mobile_app/services/api_service.dart';
import 'package:mobile_app/models/producto.dart';

class ProductoService {
  static Future<Map<String, dynamic>> listarProductos({
    int page = 1,
    String? search,
  }) async {
    try {
      String endpoint = '/productos?pagina=$page&limite=20';
      if (search != null && search.isNotEmpty) {
        endpoint += '&search=$search';
      }

      final response = await ApiService.get(endpoint);

      if (response['success'] == true) {
        final productos = (response['data'] as List)
            .map((item) => Producto.fromJson(item as Map<String, dynamic>))
            .toList();

        return {
          'success': true,
          'productos': productos,
          'paginacion': response['paginacion'] ?? {},
        };
      }

      throw ApiException(response['mensaje'] ?? 'Error al listar productos');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Producto> obtenerProducto(int id) async {
    try {
      final response = await ApiService.get('/productos/$id');

      if (response['success'] == true && response['data'] != null) {
        return Producto.fromJson(response['data'] as Map<String, dynamic>);
      }

      throw ApiException(response['mensaje'] ?? 'Error al obtener el producto');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Producto> crearProducto({
    required String nombre,
    String? descripcion,
    required int stock,
    required int stockMinimo,
    required double precioCompra,
    required double precioVenta,
  }) async {
    try {
      final response = await ApiService.post(
        '/productos',
        body: {
          'nombre': nombre,
          'descripcion': descripcion,
          'stock': stock,
          'stock_minimo': stockMinimo,
          'precio_compra': precioCompra,
          'precio_venta': precioVenta,
        },
      );

      if (response['success'] == true && response['data'] != null) {
        return Producto.fromJson(response['data'] as Map<String, dynamic>);
      }

      throw ApiException(response['mensaje'] ?? 'Error al crear el producto');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Producto> actualizarProducto(
    int id, {
    required String nombre,
    String? descripcion,
    required int stock,
    required int stockMinimo,
    required double precioCompra,
    required double precioVenta,
  }) async {
    try {
      final response = await ApiService.put(
        '/productos/$id',
        body: {
          'nombre': nombre,
          'descripcion': descripcion,
          'stock': stock,
          'stock_minimo': stockMinimo,
          'precio_compra': precioCompra,
          'precio_venta': precioVenta,
        },
      );

      if (response['success'] == true && response['data'] != null) {
        return Producto.fromJson(response['data'] as Map<String, dynamic>);
      }

      throw ApiException(
        response['mensaje'] ?? 'Error al actualizar el producto',
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> eliminarProducto(int id) async {
    try {
      final response = await ApiService.delete('/productos/$id');

      if (response['success'] != true) {
        throw ApiException(
          response['mensaje'] ?? 'Error al eliminar el producto',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Producto>> obtenerProductosBajoStock() async {
    try {
      final response = await ApiService.get('/productos/stock-bajo');

      if (response['success'] == true) {
        final productos = (response['data'] as List)
            .map((item) => Producto.fromJson(item as Map<String, dynamic>))
            .toList();
        return productos;
      }

      throw ApiException(
        response['mensaje'] ?? 'Error al obtener productos con stock bajo',
      );
    } catch (e) {
      rethrow;
    }
  }
}
