import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mobile_app/services/producto_service.dart';
import 'package:mobile_app/models/producto.dart';

class ProductoProvider extends ChangeNotifier {
  List<Producto> _productos = [];
  List<Producto> _productoBajoStock = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _paginacion = {};

  // Getters
  List<Producto> get productos => _productos;
  List<Producto> get productoBajoStock => _productoBajoStock;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get paginacion => _paginacion;

  Future<void> cargarProductos({int page = 1, String? search}) async {
    _isLoading = true;
    _error = null;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final result = await ProductoService.listarProductos(
        page: page,
        search: search,
      );
      _productos = result['productos'];
      _paginacion = result['paginacion'];
      _isLoading = false;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<void> cargarProductosBajoStock() async {
    try {
      _productoBajoStock = await ProductoService.obtenerProductosBajoStock();
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<bool> crearProducto({
    required String nombre,
    String? descripcion,
    required int stock,
    required int stockMinimo,
    required double precioCompra,
    required double precioVenta,
  }) async {
    try {
      _isLoading = true;
      _error = null;

      // Use post frame callback to avoid setState during build
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      await ProductoService.crearProducto(
        nombre: nombre,
        descripcion: descripcion,
        stock: stock,
        stockMinimo: stockMinimo,
        precioCompra: precioCompra,
        precioVenta: precioVenta,
      );

      await cargarProductos();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return false;
    }
  }

  Future<bool> actualizarProducto(
    int id, {
    required String nombre,
    String? descripcion,
    required int stock,
    required int stockMinimo,
    required double precioCompra,
    required double precioVenta,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ProductoService.actualizarProducto(
        id,
        nombre: nombre,
        descripcion: descripcion,
        stock: stock,
        stockMinimo: stockMinimo,
        precioCompra: precioCompra,
        precioVenta: precioVenta,
      );

      await cargarProductos();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarProducto(int id) async {
    try {
      await ProductoService.eliminarProducto(id);
      await cargarProductos();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
