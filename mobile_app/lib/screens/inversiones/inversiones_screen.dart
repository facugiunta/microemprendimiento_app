import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/providers/inversion_provider.dart';
import 'package:mobile_app/models/inversion.dart';
import 'package:google_fonts/google_fonts.dart';

class InversionesScreen extends StatefulWidget {
  const InversionesScreen({super.key});

  @override
  State<InversionesScreen> createState() => _InversionesScreenState();
}

class _InversionesScreenState extends State<InversionesScreen> {
  String _categoriaSeleccionada = 'Todas';

  @override
  void initState() {
    super.initState();
    context.read<InversionProvider>().cargarInversiones();
  }

  @override
  Widget build(BuildContext context) {
    final inversionProvider = context.watch<InversionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Inversiones',
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
                children: ['Todas', ...Inversion.categorias]
                    .map(
                      (cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: _categoriaSeleccionada == cat,
                          onSelected: (_) {
                            setState(() => _categoriaSeleccionada = cat);
                            inversionProvider.cargarInversiones(
                              categoria: cat == 'Todas' ? null : cat,
                            );
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          Expanded(
            child: inversionProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : inversionProvider.inversiones.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.attach_money,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay inversiones',
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: inversionProvider.inversiones.length,
                    itemBuilder: (context, index) {
                      final inv = inversionProvider.inversiones[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(inv.nombre),
                          subtitle: Text(inv.categoria),
                          trailing: SizedBox(
                            width: 150,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('\$${inv.monto.toStringAsFixed(2)}'),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => inversionProvider
                                      .eliminarInversion(inv.id),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/home/inversiones/crear'),
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.add),
      ),
    );
  }
}
