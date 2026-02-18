import 'package:flutter/material.dart';
import 'package:mobile_app/services/auditoria_service.dart';
import 'package:mobile_app/models/auditoria.dart';

class AuditoriaProvider extends ChangeNotifier {
  List<Auditoria> _auditoria = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _paginacion = {};

  // Getters
  List<Auditoria> get auditoria => _auditoria;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get paginacion => _paginacion;

  Future<void> cargarAuditoria({
    int page = 1,
    String? entidad,
    String? accion,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AuditoriaService.listarAuditoria(
        page: page,
        entidad: entidad,
        accion: accion,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );

      _auditoria = result['auditoria'];
      _paginacion = result['paginacion'];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
