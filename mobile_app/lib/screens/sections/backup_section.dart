import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BackupSection extends StatelessWidget {
  const BackupSection({super.key});

  static const String backupCommand =
      'docker-compose exec postgres pg_dump -U postgres microemprendimiento_db > backup.sql';
  static const String restoreCommand =
      'docker-compose exec -T postgres psql -U postgres -d microemprendimiento_db < backup.sql';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Respaldo y Restauración',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Usa estos comandos desde la carpeta del proyecto. '
            'Los backups guardan la base de datos completa.',
          ),
          const SizedBox(height: 24),
          _buildCommandCard(context, title: 'Backup', command: backupCommand),
          const SizedBox(height: 16),
          _buildCommandCard(context, title: 'Restore', command: restoreCommand),
          const SizedBox(height: 24),
          const Text(
            'Consejo: guarda los backups en una carpeta con fecha.\n'
            'Ej: backups/backup-2026-02-17.sql',
          ),
        ],
      ),
    );
  }

  Widget _buildCommandCard(
    BuildContext context, {
    required String title,
    required String command,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SelectableText(command),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: command));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Comando copiado')),
                    );
                  }
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copiar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
