import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/models/compra.dart';
import 'package:mobile_app/models/inversion.dart';
import 'package:mobile_app/models/venta.dart';
import 'package:mobile_app/services/historial_service.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = true;
  String? _error;
  List<Venta> _ventas = [];
  List<Compra> _compras = [];
  List<Inversion> _inversiones = [];
  List<Map<String, dynamic>> _reportes = [];
  List<Map<String, dynamic>> _timeline = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        HistorialService.obtenerHistorialVentas(),
        HistorialService.obtenerHistorialCompras(),
        HistorialService.obtenerHistorialInversiones(),
        HistorialService.obtenerHistorialReportes(),
        HistorialService.obtenerTimelineUnificado(),
      ]);

      setState(() {
        _ventas = List<Venta>.from(results[0]['ventas'] ?? []);
        _compras = List<Compra>.from(results[1]['compras'] ?? []);
        _inversiones = List<Inversion>.from(results[2]['inversiones'] ?? []);
        _reportes = List<Map<String, dynamic>>.from(results[3]['reportes'] ?? []);
        _timeline = List<Map<String, dynamic>>.from(results[4]['timeline'] ?? []);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Ventas'),
            Tab(text: 'Compras'),
            Tab(text: 'Inversiones'),
            Tab(text: 'Reportes'),
            Tab(text: 'Todo'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Padding(padding: const EdgeInsets.all(16), child: Text(_error!)))
          : RefreshIndicator(
              onRefresh: _loadAll,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildVentas(),
                  _buildCompras(),
                  _buildInversiones(),
                  _buildReportes(),
                  _buildTimeline(),
                ],
              ),
            ),
    );
  }

  Widget _buildVentas() {
    if (_ventas.isEmpty) return const _Empty('Sin historial de ventas');
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _ventas.length,
      itemBuilder: (_, i) {
        final v = _ventas[i];
        return Card(
          child: ListTile(
            title: Text(v.nombreProducto),
            subtitle: Text('${_fmtDate(v.fecha)} · Cant: ${v.cantidad}'),
            trailing: Text(_money(v.total)),
          ),
        );
      },
    );
  }

  Widget _buildCompras() {
    if (_compras.isEmpty) return const _Empty('Sin historial de compras');
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _compras.length,
      itemBuilder: (_, i) {
        final c = _compras[i];
        return Card(
          child: ListTile(
            title: Text(c.nombreProducto),
            subtitle: Text('${_fmtDate(c.fecha)} · Cant: ${c.cantidad}'),
            trailing: Text(_money(c.total)),
          ),
        );
      },
    );
  }

  Widget _buildInversiones() {
    if (_inversiones.isEmpty) return const _Empty('Sin historial de inversiones');
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _inversiones.length,
      itemBuilder: (_, i) {
        final inv = _inversiones[i];
        return Card(
          child: ListTile(
            title: Text(inv.nombre),
            subtitle: Text('${_fmtDate(inv.fecha)} · ${inv.categoria}'),
            trailing: Text(_money(inv.monto)),
          ),
        );
      },
    );
  }

  Widget _buildReportes() {
    if (_reportes.isEmpty) return const _Empty('Sin historial de reportes');
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _reportes.length,
      itemBuilder: (_, i) {
        final r = _reportes[i];
        final nombre = (r['nombre_feria'] ?? 'Reporte').toString();
        final fecha = DateTime.tryParse((r['fecha_feria'] ?? '').toString());
        final ganancia = double.tryParse('${r['ganancia_neta'] ?? 0}') ?? 0.0;
        return Card(
          child: ListTile(
            title: Text(nombre),
            subtitle: Text(fecha != null ? _fmtDate(fecha) : 'Sin fecha'),
            trailing: Text(_money(ganancia)),
          ),
        );
      },
    );
  }

  Widget _buildTimeline() {
    if (_timeline.isEmpty) return const _Empty('Sin movimientos en timeline');
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _timeline.length,
      itemBuilder: (_, i) {
        final item = _timeline[i];
        final tipo = (item['tipo'] ?? '').toString();
        final descripcion = (item['descripcion'] ?? '').toString();
        final fecha = DateTime.tryParse((item['fecha'] ?? '').toString());
        final monto = double.tryParse('${item['monto'] ?? 0}') ?? 0.0;
        return Card(
          child: ListTile(
            leading: CircleAvatar(child: Text(tipo.isEmpty ? '?' : tipo[0].toUpperCase())),
            title: Text(descripcion.isEmpty ? tipo : descripcion),
            subtitle: Text(fecha != null ? _fmtDate(fecha) : 'Sin fecha'),
            trailing: Text(_money(monto)),
          ),
        );
      },
    );
  }

  String _fmtDate(DateTime d) => DateFormat('dd/MM/yyyy HH:mm').format(d);

  String _money(double value) =>
      NumberFormat.currency(locale: 'es_AR', symbol: '\$', decimalDigits: 2).format(value);
}

class _Empty extends StatelessWidget {
  final String text;
  const _Empty(this.text);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 80),
        Center(child: Text(text)),
      ],
    );
  }
}
