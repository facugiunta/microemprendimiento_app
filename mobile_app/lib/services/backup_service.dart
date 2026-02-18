import 'dart:convert';
import 'package:mobile_app/services/api_service.dart';

class BackupService {
  static Future<Map<String, dynamic>> crearBackup() async {
    try {
      final response = await ApiService.post('/backup/crear', body: {});

      if (response['version'] != null && response['datos'] != null) {
        return response;
      }

      throw ApiException(response['mensaje'] ?? 'Error al crear el backup');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> restaurarBackup(
    String contenidoBackup,
  ) async {
    try {
      final backup = contenidoBackup.isNotEmpty
          ? contenidoBackup
          : '{}';
      final response = await ApiService.post(
        '/backup/restaurar',
        body: Map<String, dynamic>.from(
          backup == '{}'
              ? <String, dynamic>{}
              : (jsonDecode(backup) as Map<String, dynamic>),
        ),
      );

      if (response['success'] == true) {
        return {'success': true, 'mensaje': response['mensaje']};
      }

      throw ApiException(response['mensaje'] ?? 'Error al restaurar el backup');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> obtenerHistorialBackups({
    int page = 1,
  }) async {
    try {
      final response = await ApiService.get('/backup/historial');

      if (response['success'] == true) {
        return {
          'success': true,
          'backups': response['data'] ?? [],
          'paginacion': response['paginacion'] ?? {},
        };
      }

      throw ApiException(
        response['mensaje'] ?? 'Error al obtener el historial de backups',
      );
    } catch (e) {
      rethrow;
    }
  }
}
