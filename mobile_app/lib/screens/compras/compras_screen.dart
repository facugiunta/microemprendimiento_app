import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/providers/compra_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class ComprasScreen extends StatefulWidget {
  const ComprasScreen({super.key});

  @override
  State<ComprasScreen> createState() => _ComprasScreenState();
}

class _ComprasScreenState extends State<ComprasScreen> {
  String _filtroSeleccionado = 'todos';

  @override
  void initState() {
    super.initState();
    context.read<CompraProvider>().cargarCompras();
  }

  @override
  Widget build(BuildContext context) {
    final compraProvider = context.watch<CompraProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Historial de Compras',
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
                children: ['Hoy', 'Este Mes', 'Histórico', 'Personalizado']
                    .map(
                      (filtro) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filtro),
                          selected: _filtroSeleccionado == filtro,
                          onSelected: (_) {
                            setState(() => _filtroSeleccionado = filtro);
                            compraProvider.cargarCompras();
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          Expanded(
            child: compraProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : compraProvider.compras.isEmpty
                ? Center(
                    child: Text(
                      'No hay compras',
                      style: GoogleFonts.inter(color: Colors.grey.shade600),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: compraProvider.compras.length,
                    itemBuilder: (context, index) {
                      final compra = compraProvider.compras[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(compra.nombreProducto),
                          subtitle: Text(
                            'Cantidad: ${compra.cantidad} | ${compra.proveedor ?? 'Sin proveedor'}',
                          ),
                          trailing: Text(
                            '\$${compra.total.toStringAsFixed(2)}',
                          ),
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
