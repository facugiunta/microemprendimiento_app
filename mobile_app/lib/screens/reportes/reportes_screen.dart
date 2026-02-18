import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/models/reporte_mensual.dart';
import 'package:mobile_app/providers/reporte_provider.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  late int _mes;
  late int _anio;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _mes = now.month;
    _anio = now.year;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  Future<void> _load() async {
    final provider = context.read<ReporteProvider>();
    await Future.wait([
      provider.cargarReporteMensual(_mes, _anio),
      provider.cargarHistorialReportesMensuales(),
      provider.cargarReportesFeria(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReporteProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _mes,
                    decoration: const InputDecoration(labelText: 'Mes'),
                    items: List.generate(12, (i) => i + 1)
                        .map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text(m.toString().padLeft(2, '0')),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _mes = value);
                      provider.cargarReporteMensual(_mes, _anio);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _anio,
                    decoration: const InputDecoration(labelText: 'Año'),
                    items: List.generate(
                      6,
                      (i) => DateTime.now().year - i,
                    ).map((a) => DropdownMenuItem(value: a, child: Text('$a'))).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _anio = value);
                      provider.cargarReporteMensual(_mes, _anio);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCurrentMonthlyReport(provider.reporteActual, colorScheme),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.event_note),
                title: const Text('Reporte de Feria'),
                subtitle: const Text('Crear reporte detallado por feria'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/home/reportes/feria'),
              ),
            ),
            const SizedBox(height: 16),
            Text('Historial mensual', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (provider.isLoading && provider.reportesMensuales.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else if (provider.reportesMensuales.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Sin datos de reportes mensuales aún'),
                ),
              )
            else
              ...provider.reportesMensuales.map(_buildHistoryItem),
            if (provider.error != null) ...[
              const SizedBox(height: 12),
              Text(
                provider.error!,
                style: TextStyle(color: colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentMonthlyReport(ReporteMensual? reporte, ColorScheme colors) {
    if (reporte == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No se pudo cargar el reporte mensual'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resumen del periodo $_mes/$_anio'),
            const SizedBox(height: 12),
            _metric('Ventas', _money(reporte.totalVentas), Colors.green),
            _metric('Compras', _money(reporte.totalCompras), Colors.blue),
            _metric('Inversiones', _money(reporte.totalInversiones), Colors.orange),
            _metric(
              'Ganancia neta',
              _money(reporte.gananciaNeta),
              reporte.gananciaNeta >= 0 ? Colors.green : colors.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(ReporteMensual item) {
    return Card(
      child: ListTile(
        title: Text(item.mes.isEmpty ? 'Mes sin nombre' : item.mes),
        subtitle: Text(
          'Ventas: ${_money(item.totalVentas)} | Compras: ${_money(item.totalCompras)}',
        ),
        trailing: Text(
          _money(item.gananciaNeta),
          style: TextStyle(
            color: item.gananciaNeta >= 0 ? Colors.green : Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _metric(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  String _money(double value) {
    return NumberFormat.currency(
      locale: 'es_AR',
      symbol: '\$',
      decimalDigits: 2,
    ).format(value);
  }
}
