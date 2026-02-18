import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/models/compra.dart';
import 'package:mobile_app/models/venta.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/providers/compra_provider.dart';
import 'package:mobile_app/providers/producto_provider.dart';
import 'package:mobile_app/providers/reporte_provider.dart';
import 'package:mobile_app/providers/venta_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final now = DateTime.now();
    await Future.wait([
      context.read<ProductoProvider>().cargarProductos(),
      context.read<ProductoProvider>().cargarProductosBajoStock(),
      context.read<CompraProvider>().cargarCompras(),
      context.read<VentaProvider>().cargarVentas(),
      context.read<ReporteProvider>().cargarReporteMensual(now.month, now.year),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final tabs = <Widget>[
      _HomeTab(onReload: _loadData),
      _ProductosTab(),
      _ComprasTab(),
      _VentasTab(),
      _MasTab(onLogout: _logout),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Emprendimiento'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: tabs[_tab],
      floatingActionButton: _buildFab(context),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (value) => setState(() => _tab = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'Productos'),
          NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), label: 'Compras'),
          NavigationDestination(icon: Icon(Icons.trending_up_outlined), label: 'Ventas'),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: 'Mas'),
        ],
      ),
    );
  }

  Widget? _buildFab(BuildContext context) {
    if (_tab == 1) {
      return FloatingActionButton(
        onPressed: () => context.go('/home/productos/crear'),
        child: const Icon(Icons.add),
      );
    }
    if (_tab == 2) {
      return FloatingActionButton(
        onPressed: () => context.go('/home/compras/crear'),
        child: const Icon(Icons.add_shopping_cart),
      );
    }
    if (_tab == 3) {
      return FloatingActionButton(
        onPressed: () => context.go('/home/ventas/crear'),
        child: const Icon(Icons.point_of_sale),
      );
    }
    return null;
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) {
      context.go('/login');
    }
  }
}

class _HomeTab extends StatelessWidget {
  final Future<void> Function() onReload;
  const _HomeTab({required this.onReload});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final reporte = context.watch<ReporteProvider>().reporteActual;
    final productos = context.watch<ProductoProvider>();
    final compras = context.watch<CompraProvider>().compras;
    final ventas = context.watch<VentaProvider>().ventas;

    final compraTotal = _sumCompras(compras);
    final ventaTotal = _sumVentas(ventas);
    final stockBajo = productos.productoBajoStock.length;

    return RefreshIndicator(
      onRefresh: onReload,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Hola, ${auth.user?.name ?? 'usuario'}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(DateFormat('dd/MM/yyyy').format(DateTime.now())),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _kpi('Ventas mes', _money(reporte?.totalVentas ?? ventaTotal), Colors.green.shade700),
              _kpi('Compras mes', _money(reporte?.totalCompras ?? compraTotal), Colors.blue.shade700),
              _kpi('Ganancia', _money(reporte?.gananciaNeta ?? (ventaTotal - compraTotal)), Colors.deepPurple.shade700),
              _kpi('Stock bajo', '$stockBajo', Colors.orange.shade700),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Accesos rapidos'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _quick(context, Icons.add_business, 'Nuevo producto', '/home/productos/crear'),
              _quick(context, Icons.add_shopping_cart, 'Nueva compra', '/home/compras/crear'),
              _quick(context, Icons.point_of_sale, 'Nueva venta', '/home/ventas/crear'),
              _quick(context, Icons.analytics_outlined, 'Reportes', '/home/reportes'),
            ],
          ),
        ],
      ),
    );
  }

  static double _sumCompras(List<Compra> items) {
    return items.fold(0.0, (sum, item) => sum + item.total);
  }

  static double _sumVentas(List<Venta> items) {
    return items.fold(0.0, (sum, item) => sum + item.total);
  }

  static Widget _kpi(String label, String value, Color color) {
    return Builder(
      builder: (context) {
        final width = (MediaQuery.of(context).size.width - 44) / 2;
        return SizedBox(
          width: width,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _quick(BuildContext context, IconData icon, String label, String route) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 44) / 2,
      child: OutlinedButton.icon(
        onPressed: () => context.go(route),
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }

  static String _money(double value) {
    return NumberFormat.currency(locale: 'es_AR', symbol: '\$', decimalDigits: 0).format(value);
  }
}

class _ProductosTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductoProvider>();
    if (provider.isLoading) return const Center(child: CircularProgressIndicator());
    if (provider.productos.isEmpty) return const Center(child: Text('Sin productos'));

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (_, index) {
        final p = provider.productos[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          tileColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text(p.nombre),
          subtitle: Text('Stock: ${p.stock} | Venta: ${_HomeTab._money(p.precioVenta)}'),
          trailing: IconButton(
            onPressed: () => context.go('/home/productos/editar/${p.id}'),
            icon: const Icon(Icons.edit_outlined),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: provider.productos.length,
    );
  }
}

class _ComprasTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CompraProvider>();
    if (provider.isLoading) return const Center(child: CircularProgressIndicator());
    if (provider.compras.isEmpty) return const Center(child: Text('Sin compras'));

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (_, index) {
        final c = provider.compras[index];
        return ListTile(
          tileColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text(c.nombreProducto),
          subtitle: Text('Cant: ${c.cantidad}'),
          trailing: Text(_HomeTab._money(c.total)),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: provider.compras.length,
    );
  }
}

class _VentasTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VentaProvider>();
    if (provider.isLoading) return const Center(child: CircularProgressIndicator());
    if (provider.ventas.isEmpty) return const Center(child: Text('Sin ventas'));

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (_, index) {
        final v = provider.ventas[index];
        return ListTile(
          tileColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text(v.nombreProducto),
          subtitle: Text('Cant: ${v.cantidad}'),
          trailing: Text(_HomeTab._money(v.total)),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: provider.ventas.length,
    );
  }
}

class _MasTab extends StatelessWidget {
  final Future<void> Function() onLogout;
  const _MasTab({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const Icon(Icons.analytics_outlined),
          title: const Text('Reportes'),
          onTap: () => context.go('/home/reportes'),
        ),
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('Historial'),
          onTap: () => context.go('/home/historial'),
        ),
        ListTile(
          leading: const Icon(Icons.verified_user_outlined),
          title: const Text('Auditoria'),
          onTap: () => context.go('/home/auditoria'),
        ),
        ListTile(
          leading: const Icon(Icons.cloud_upload_outlined),
          title: const Text('Backup'),
          onTap: () => context.go('/home/backup'),
        ),
        ListTile(
          leading: const Icon(Icons.settings_outlined),
          title: const Text('Configuracion'),
          onTap: () => context.go('/home/settings'),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Cerrar sesion', style: TextStyle(color: Colors.red)),
          onTap: onLogout,
        ),
      ],
    );
  }
}
