import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mobile_app/services/inversion_service.dart';
import 'package:mobile_app/models/inversion.dart';

class InversionProvider extends ChangeNotifier {
  List<Inversion> _inversiones = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _paginacion = {};
  double _totalInversionesPeriodo = 0;

  // Getters
  List<Inversion> get inversiones => _inversiones;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get paginacion => _paginacion;
  double get totalInversionesPeriodo => _totalInversionesPeriodo;

  Future<void> cargarInversiones({
    int page = 1,
    String? categoria,
    int? mes,
    int? ano,
  }) async {
    _isLoading = true;
    _error = null;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final result = await InversionService.listarInversiones(
        page: page,
        categoria: categoria,
        mes: mes,
        ano: ano,
      );

      _inversiones = result['inversiones'];
      _paginacion = result['paginacion'];
      _totalInversionesPeriodo = _inversiones.fold(
        0.0,
        (sum, inv) => sum + inv.monto,
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

  Future<bool> crearInversion({
    required String nombre,
    String? descripcion,
    required double monto,
    required String categoria,
    required DateTime fecha,
  }) async {
    _isLoading = true;
    _error = null;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      await InversionService.crearInversion(
        nombre: nombre,
        descripcion: descripcion,
        monto: monto,
        categoria: categoria,
        fecha: fecha,
      );

      await cargarInversiones();
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

  Future<bool> actualizarInversion(
    int id, {
    required String nombre,
    String? descripcion,
    required double monto,
    required String categoria,
    required DateTime fecha,
  }) async {
    _isLoading = true;
    _error = null;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      await InversionService.actualizarInversion(
        id,
        nombre: nombre,
        descripcion: descripcion,
        monto: monto,
        categoria: categoria,
        fecha: fecha,
      );

      await cargarInversiones();
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

  Future<bool> eliminarInversion(int id) async {
    try {
      await InversionService.eliminarInversion(id);
      await cargarInversiones();
      return true;
    } catch (e) {
      _error = e.toString();
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return false;
    }
  }

  void clearError() {
    _error = null;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
