import 'package:flutter/material.dart';
import '../../models/audit_log_model.dart';

class AuditSection extends StatefulWidget {
  const AuditSection({super.key});

  @override
  State<AuditSection> createState() => _AuditSectionState();
}

class _AuditSectionState extends State<AuditSection> {
  List<AuditLog> logs = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => isLoading = true);
    try {
      // TODO: Implement audit log loading from service
      logs = [];
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auditoría')),
      body: RefreshIndicator(
        onRefresh: _loadLogs,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (logs.isEmpty)
              _buildEmptyState('No hay registros de auditoría')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: log.allowed
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        child: Icon(log.allowed ? Icons.check : Icons.block),
                      ),
                      title: Text('${log.resource} • ${log.action}'),
                      subtitle: Text(log.allowed ? 'Permitido' : 'Bloqueado'),
                      trailing: Text(
                        '${log.createdAt.day}/${log.createdAt.month}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.inbox, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
