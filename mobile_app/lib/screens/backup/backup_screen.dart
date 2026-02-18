import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mobile_app/services/backup_service.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _creatingBackup = false;
  bool _restoringBackup = false;

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  Future<void> _crearBackup() async {
    if (_creatingBackup) return;
    setState(() => _creatingBackup = true);
    try {
      final backupData = await BackupService.crearBackup();
      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);

      final tempDir = await getTemporaryDirectory();
      final fileName = 'backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(jsonString, flush: true);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Backup de Microemprendimiento',
      );

      _showSnackBar('Backup creado correctamente');
    } catch (e) {
      _showSnackBar('Error al crear backup: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _creatingBackup = false);
      }
    }
  }

  Future<void> _restaurarBackup() async {
    if (_restoringBackup) return;
    setState(() => _restoringBackup = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        _showSnackBar('No se seleccionó ningún archivo');
        return;
      }

      final file = result.files.first;
      String contenido;

      if (file.bytes != null) {
        contenido = utf8.decode(file.bytes!, allowMalformed: true);
      } else if (file.path != null) {
        contenido = await File(file.path!).readAsString();
      } else {
        _showSnackBar('No se pudo leer el archivo seleccionado', isError: true);
        return;
      }

      await BackupService.restaurarBackup(contenido);
      _showSnackBar('Backup restaurado correctamente');
    } catch (e) {
      _showSnackBar('Error al restaurar backup: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _restoringBackup = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Backup',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Crear Backup',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.cloud_download),
                label: Text(
                  _creatingBackup ? 'Creando...' : 'Crear Backup',
                ),
                onPressed: _creatingBackup ? null : _crearBackup,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Restaurar Backup',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.folder_open),
                label: Text(
                  _restoringBackup ? 'Restaurando...' : 'Seleccionar Archivo',
                ),
                onPressed: _restoringBackup ? null : _restaurarBackup,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
