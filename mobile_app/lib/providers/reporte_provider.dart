import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mobile_app/services/reporte_service.dart';
import 'package:mobile_app/models/reporte_mensual.dart';
import 'package:mobile_app/models/reporte_feria.dart';

class ReporteProvider extends ChangeNotifier {
  ReporteMensual? _reporteActual;
  List<ReporteMensual> _reportesMensuales = [];
  List<ReporteFeria> _reportesFeria = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  ReporteMensual? get reporteActual => _reporteActual;
  List<ReporteMensual> get reportesMensuales => _reportesMensuales;
  List<ReporteFeria> get reportesFeria => _reportesFeria;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> cargarReporteMensual(int mes, int ano) async {
    _isLoading = true;
    _error = null;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      _reporteActual = await ReporteService.obtenerReporteMensual(mes, ano);
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

  Future<void> cargarHistorialReportesMensuales() async {
    _isLoading = true;
    _error = null;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final result = await ReporteService.obtenerHistorialReportesMensuales();
      _reportesMensuales = result['reportes'];
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

  Future<bool> crearReporteFeria({
    required String nombreFeria,
    required DateTime fechaFeria,
    required double inversionPuesto,
    required double gastosVarios,
    required List<Map<String, dynamic>> productos,
    String? nota,
  }) async {
    _isLoading = true;
    _error = null;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      await ReporteService.crearReporteFeria(
        nombreFeria: nombreFeria,
        fechaFeria: fechaFeria,
        inversionPuesto: inversionPuesto,
        gastosVarios: gastosVarios,
        productos: productos,
        nota: nota,
      );

      await cargarReportesFeria();
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

  Future<void> cargarReportesFeria() async {
    _isLoading = true;
    _error = null;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final result = await ReporteService.listarReportesFeria();
      _reportesFeria = result['reportes'];
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

  Future<bool> eliminarReporteFeria(int id) async {
    try {
      await ReporteService.eliminarReporteFeria(id);
      await cargarReportesFeria();
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
