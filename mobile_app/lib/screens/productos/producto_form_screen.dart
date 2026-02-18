import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/providers/producto_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductoFormScreen extends StatefulWidget {
  final int? productoId;

  const ProductoFormScreen({super.key, this.productoId});

  @override
  State<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends State<ProductoFormScreen> {
  late TextEditingController _nombreController;
  late TextEditingController _descController;
  late TextEditingController _stockController;
  late TextEditingController _stockMinController;
  late TextEditingController _precioCompraController;
  late TextEditingController _precioVentaController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _descController = TextEditingController();
    _stockController = TextEditingController();
    _stockMinController = TextEditingController();
    _precioCompraController = TextEditingController();
    _precioVentaController = TextEditingController();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descController.dispose();
    _stockController.dispose();
    _stockMinController.dispose();
    _precioCompraController.dispose();
    _precioVentaController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final nombre = _nombreController.text.trim();
    final stock = int.tryParse(_stockController.text) ?? 0;
    final stockMin = int.tryParse(_stockMinController.text) ?? 0;
    final precioCompra = _parseDecimal(_precioCompraController.text);
    final precioVenta = _parseDecimal(_precioVentaController.text);

    if (nombre.isEmpty || precioCompra <= 0 || precioVenta <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Completa nombre y precios validos (usa numeros, ej: 1200 o 1200,50)',
          ),
        ),
      );
      return;
    }

    final productoProvider = context.read<ProductoProvider>();

    bool success;
    if (widget.productoId != null) {
      success = await productoProvider.actualizarProducto(
        widget.productoId!,
        nombre: nombre,
        descripcion: _descController.text,
        stock: stock,
        stockMinimo: stockMin,
        precioCompra: precioCompra,
        precioVenta: precioVenta,
      );
    } else {
      success = await productoProvider.crearProducto(
        nombre: nombre,
        descripcion: _descController.text,
        stock: stock,
        stockMinimo: stockMin,
        precioCompra: precioCompra,
        precioVenta: precioVenta,
      );
    }

    if (success && mounted) {
      context.go('/home/productos');
      return;
    }

    if (mounted) {
      final error = productoProvider.error ?? 'No se pudo guardar el producto';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  double _parseDecimal(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.productoId != null ? 'Editar Producto' : 'Nuevo Producto',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del producto *',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _stockController,
                    decoration: const InputDecoration(labelText: 'Stock'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _stockMinController,
                    decoration: const InputDecoration(
                      labelText: 'Stock mínimo',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _precioCompraController,
                    decoration: const InputDecoration(labelText: 'P. compra *'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _precioVentaController,
                    decoration: const InputDecoration(labelText: 'P. venta *'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Consumer<ProductoProvider>(
                builder: (context, provider, _) => ElevatedButton(
                  onPressed: provider.isLoading ? null : _handleSave,
                  child: provider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
