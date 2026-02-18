import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/providers/venta_provider.dart';
import 'package:mobile_app/providers/producto_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class VentaFormScreen extends StatefulWidget {
  const VentaFormScreen({super.key});

  @override
  State<VentaFormScreen> createState() => _VentaFormScreenState();
}

class _VentaFormScreenState extends State<VentaFormScreen> {
  int? _productoSeleccionadoId;
  late TextEditingController _cantidadController;
  late TextEditingController _precioUnitarioController;
  late TextEditingController _notaController;

  @override
  void initState() {
    super.initState();
    _cantidadController = TextEditingController();
    _precioUnitarioController = TextEditingController();
    _notaController = TextEditingController();
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    _precioUnitarioController.dispose();
    _notaController.dispose();
    super.dispose();
  }

  Future<void> _handleRegistrarVenta() async {
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

    final productoProvider = context.read<ProductoProvider>();
    int stockDisponible = 0;
    for (final p in productoProvider.productos) {
      if (p.id == _productoSeleccionadoId) {
        stockDisponible = p.stock;
        break;
      }
    }

    if (cantidad > stockDisponible) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Stock insuficiente. Disponible: $stockDisponible, solicitado: $cantidad',
          ),
        ),
      );
      return;
    }

    final ventaProvider = context.read<VentaProvider>();
    final success = await ventaProvider.registrarVenta(
      productoId: _productoSeleccionadoId!,
      cantidad: cantidad,
      precioUnitario: precio,
      nota: _notaController.text,
    );

    if (success && mounted) {
      if (ventaProvider.advertenciaStock) {
        showDialog(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('⚠️ Advertencia de Stock'),
            content: Text(ventaProvider.mensajeAdvertencia ?? 'Stock bajo'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(c);
                  context.pop();
                },
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
      } else {
        context.pop();
      }
      return;
    }

    if (mounted) {
      final error = ventaProvider.error ?? 'No se pudo registrar la venta';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final productoProvider = context.watch<ProductoProvider>();
    final ventaProvider = context.watch<VentaProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registrar Venta',
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
              onChanged: (value) {
                setState(() => _productoSeleccionadoId = value);
              },
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
              controller: _notaController,
              decoration: const InputDecoration(labelText: 'Nota (opcional)'),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: ventaProvider.isLoading
                    ? null
                    : _handleRegistrarVenta,
                child: ventaProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Registrar Venta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
