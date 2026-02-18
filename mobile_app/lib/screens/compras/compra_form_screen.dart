import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/providers/compra_provider.dart';
import 'package:mobile_app/providers/producto_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class CompraFormScreen extends StatefulWidget {
  const CompraFormScreen({super.key});

  @override
  State<CompraFormScreen> createState() => _CompraFormScreenState();
}

class _CompraFormScreenState extends State<CompraFormScreen> {
  int? _productoSeleccionadoId;
  late TextEditingController _cantidadController;
  late TextEditingController _precioUnitarioController;
  late TextEditingController _proveedorController;
  late TextEditingController _notaController;

  @override
  void initState() {
    super.initState();
    _cantidadController = TextEditingController();
    _precioUnitarioController = TextEditingController();
    _proveedorController = TextEditingController();
    _notaController = TextEditingController();
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    _precioUnitarioController.dispose();
    _proveedorController.dispose();
    _notaController.dispose();
    super.dispose();
  }

  Future<void> _handleRegistrarCompra() async {
    if (_productoSeleccionadoId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona un producto')));
      return;
    }

    final cantidad = int.tryParse(_cantidadController.text) ?? 0;
    final precio = double.tryParse(_precioUnitarioController.text) ?? 0;

    if (cantidad <= 0 || precio <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa cantidad y precio')),
      );
      return;
    }

    final compraProvider = context.read<CompraProvider>();
    final success = await compraProvider.registrarCompra(
      productoId: _productoSeleccionadoId!,
      cantidad: cantidad,
      precioUnitario: precio,
      proveedor: _proveedorController.text,
      nota: _notaController.text,
    );

    if (success && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final productoProvider = context.watch<ProductoProvider>();
    final compraProvider = context.watch<CompraProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registrar Compra',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              initialValue: _productoSeleccionadoId,
              decoration: const InputDecoration(
                labelText: 'Selecciona producto *',
              ),
              items: productoProvider.productos
                  .map(
                    (p) => DropdownMenuItem(value: p.id, child: Text(p.nombre)),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _productoSeleccionadoId = value),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _cantidadController,
              decoration: const InputDecoration(labelText: 'Cantidad *'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _precioUnitarioController,
              decoration: const InputDecoration(labelText: 'Precio unitario *'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _proveedorController,
              decoration: const InputDecoration(
                labelText: 'Proveedor (opcional)',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notaController,
              decoration: const InputDecoration(labelText: 'Nota (opcional)'),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: compraProvider.isLoading
                    ? null
                    : _handleRegistrarCompra,
                child: compraProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Registrar Compra'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
