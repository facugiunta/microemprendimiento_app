import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/models/auditoria.dart';
import 'package:mobile_app/providers/auditoria_provider.dart';

class AuditoriaScreen extends StatefulWidget {
  const AuditoriaScreen({super.key});

  @override
  State<AuditoriaScreen> createState() => _AuditoriaScreenState();
}

class _AuditoriaScreenState extends State<AuditoriaScreen> {
  String? _accion;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  Future<void> _load() async {
    await context.read<AuditoriaProvider>().cargarAuditoria(
      accion: _accion,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuditoriaProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Auditoria')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: _accion,
                    decoration: const InputDecoration(labelText: 'Filtrar accion'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Todas')),
                      DropdownMenuItem(value: 'CREAR', child: Text('CREAR')),
                      DropdownMenuItem(value: 'ACTUALIZAR', child: Text('ACTUALIZAR')),
                      DropdownMenuItem(value: 'ELIMINAR', child: Text('ELIMINAR')),
                      DropdownMenuItem(value: 'COMPRA', child: Text('COMPRA')),
                      DropdownMenuItem(value: 'VENTA', child: Text('VENTA')),
                      DropdownMenuItem(value: 'INVERSION', child: Text('INVERSION')),
                      DropdownMenuItem(value: 'LOGIN', child: Text('LOGIN')),
                      DropdownMenuItem(value: 'EXPORTAR', child: Text('EXPORTAR')),
                    ],
                    onChanged: (value) {
                      setState(() => _accion = value);
                      _load();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
              ],
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.error != null
                ? Center(child: Text(provider.error!))
                : provider.auditoria.isEmpty
                ? const Center(child: Text('Sin movimientos de auditoria'))
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: provider.auditoria.length,
                      itemBuilder: (_, i) => _item(provider.auditoria[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _item(Auditoria a) {
    return Card(
      child: ListTile(
        title: Text('${a.accion} · ${a.entidad}'),
        subtitle: Text(
          '${a.descripcion ?? 'Sin descripcion'}\n${DateFormat('dd/MM/yyyy HH:mm').format(a.fecha)}',
        ),
        isThreeLine: true,
      ),
    );
  }
}
