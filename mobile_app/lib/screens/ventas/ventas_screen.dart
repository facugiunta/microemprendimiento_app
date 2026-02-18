import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/providers/venta_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen({super.key});

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  String _filtroSeleccionado = 'todos';

  @override
  void initState() {
    super.initState();
    context.read<VentaProvider>().cargarVentas();
  }

  @override
  Widget build(BuildContext context) {
    final ventaProvider = context.watch<VentaProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Historial de Ventas',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Hoy', 'Este Mes', 'Este Año', 'Personalizado']
                    .map(
                      (filtro) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filtro),
                          selected: _filtroSeleccionado == filtro,
                          onSelected: (_) {
                            setState(() => _filtroSeleccionado = filtro);
                            ventaProvider.cargarVentas();
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          Expanded(
            child: ventaProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ventaProvider.ventas.isEmpty
                ? Center(
                    child: Text(
                      'No hay ventas',
                      style: GoogleFonts.inter(color: Colors.grey.shade600),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: ventaProvider.ventas.length,
                    itemBuilder: (context, index) {
                      final venta = ventaProvider.ventas[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(venta.nombreProducto),
                          subtitle: Text('Cantidad: ${venta.cantidad}'),
                          trailing: Text('\$${venta.total.toStringAsFixed(2)}'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
