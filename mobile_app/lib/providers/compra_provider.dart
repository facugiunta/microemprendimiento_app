import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mobile_app/services/compra_service.dart';
import 'package:mobile_app/models/compra.dart';

class CompraProvider extends ChangeNotifier {
  List<Compra> _compras = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _paginacion = {};
  double _totalComprasperiodo = 0;

  // Getters
  List<Compra> get compras => _compras;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get paginacion => _paginacion;
  double get totalComprasPeriodo => _totalComprasperiodo;

  Future<void> cargarCompras({
    int page = 1,
    String? filtro = 'todos',
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    _isLoading = true;
    _error = null;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final result = await CompraService.listarCompras(
        page: page,
        filtro: filtro,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );

      _compras = result['compras'];
      _paginacion = result['paginacion'];
      _totalComprasperiodo = _compras.fold(
        0.0,
        (sum, compra) => sum + compra.total,
      );
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

  Future<bool> registrarCompra({
    required int productoId,
    required int cantidad,
    required double precioUnitario,
    String? proveedor,
    String? nota,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      await CompraService.registrarCompra(
        productoId: productoId,
        cantidad: cantidad,
        precioUnitario: precioUnitario,
        proveedor: proveedor,
        nota: nota,
      );

      await cargarCompras();
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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
