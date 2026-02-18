import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mobile_app/services/venta_service.dart';
import 'package:mobile_app/models/venta.dart';

class VentaProvider extends ChangeNotifier {
  List<Venta> _ventas = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _paginacion = {};
  double _totalVentasPeriodo = 0;
  bool _advertenciaStock = false;
  String? _mensajeAdvertencia;

  // Getters
  List<Venta> get ventas => _ventas;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get paginacion => _paginacion;
  double get totalVentasPeriodo => _totalVentasPeriodo;
  bool get advertenciaStock => _advertenciaStock;
  String? get mensajeAdvertencia => _mensajeAdvertencia;

  Future<void> cargarVentas({
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
      final result = await VentaService.listarVentas(
        page: page,
        filtro: filtro,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );

      _ventas = result['ventas'];
      _paginacion = result['paginacion'];
      _totalVentasPeriodo = _ventas.fold(
        0.0,
        (sum, venta) => sum + venta.total,
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

  Future<bool> registrarVenta({
    required int productoId,
    required int cantidad,
    required double precioUnitario,
    String? nota,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      _advertenciaStock = false;
      _mensajeAdvertencia = null;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      final result = await VentaService.registrarVenta(
        productoId: productoId,
        cantidad: cantidad,
        precioUnitario: precioUnitario,
        nota: nota,
      );

      _advertenciaStock = result['advertencia_stock'] ?? false;
      _mensajeAdvertencia = result['mensaje_advertencia'];

      await cargarVentas();
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

  void clearAdvertencia() {
    _advertenciaStock = false;
    _mensajeAdvertencia = null;
    notifyListeners();
  }
}
