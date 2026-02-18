import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../models/sale_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/venta_service.dart';
import '../../services/producto_service.dart';

class SalesSection extends StatefulWidget {
  const SalesSection({super.key});

  @override
  State<SalesSection> createState() => _SalesSectionState();
}

class _SalesSectionState extends State<SalesSection> {
  List<Sale> sales = [];
  List<Product> products = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final ventasResult = await VentaService.listarVentas();
      final productosResult = await ProductoService.listarProductos();

      if (ventasResult['success'] == true) {
        final ventasList = ventasResult['ventas'] as List? ?? [];
        sales = ventasList.whereType<Sale>().toList();
      }
      if (productosResult['success'] == true) {
        final productosList = productosResult['productos'] as List? ?? [];
        products = productosList.whereType<Product>().toList();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showAddSaleDialog() {
    if (products.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Primero crea productos.')));
      return;
    }

    Product selectedProduct = products.first;
    final quantityController = TextEditingController(text: '1');
    final priceController = TextEditingController(
      text: selectedProduct.precioVenta.toStringAsFixed(2),
    );
    final discountController = TextEditingController(text: '0');
    final taxController = TextEditingController(text: '0');
    final notesController = TextEditingController();
    String? paymentMethod;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Venta'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Product>(
                initialValue: selectedProduct,
                items: products
                    .map(
                      (p) => DropdownMenuItem(
                        value: p,
                        child: Text('${p.nombre} (${p.codigo})'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedProduct = value;
                    priceController.text = selectedProduct.precioVenta
                        .toStringAsFixed(2);
                  }
                },
                decoration: const InputDecoration(labelText: 'Producto'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Cantidad'),
              ),
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Precio Unitario'),
              ),
              TextField(
                controller: discountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Descuento'),
              ),
              TextField(
                controller: taxController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Impuesto'),
              ),
              DropdownButtonFormField<String>(
                initialValue: paymentMethod,
                items: const [
                  DropdownMenuItem(value: 'efectivo', child: Text('Efectivo')),
                  DropdownMenuItem(value: 'tarjeta', child: Text('Tarjeta')),
                  DropdownMenuItem(
                    value: 'transferencia',
                    child: Text('Transferencia'),
                  ),
                ],
                onChanged: (value) => paymentMethod = value,
                decoration: const InputDecoration(labelText: 'Método de Pago'),
              ),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notas'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final authProvider = context.read<AuthProvider>();
              final usuarioId = authProvider.user?.id;
              if (usuarioId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Usuario no autenticado')),
                );
                return;
              }

              try {
                final response = await VentaService.registrarVenta(
                  productoId: int.tryParse(selectedProduct.id) ?? 0,
                  cantidad: int.tryParse(quantityController.text) ?? 1,
                  precioUnitario: double.tryParse(priceController.text) ?? 0.0,
                  nota: notesController.text.isEmpty
                      ? null
                      : notesController.text,
                );

                if (mounted) {
                  Navigator.pop(context);
                  if (response['success'] == true) {
                    await _loadData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Venta creada exitosamente'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error al crear venta')),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  double _sumSales() {
    return sales.fold<double>(0, (sum, sale) => sum + sale.total);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Ventas',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Total Ventas',
                    value: '\$${_sumSales().toStringAsFixed(2)}',
                    icon: Icons.shopping_cart,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Transacciones',
                    value: '${sales.length}',
                    icon: Icons.receipt,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddSaleDialog,
              icon: const Icon(Icons.add),
              label: const Text('Nueva Venta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 24),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (sales.isEmpty)
              _buildEmptyState('No hay ventas aún')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sales.length,
                itemBuilder: (context, index) {
                  final sale = sales[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.shade100,
                        child: const Icon(Icons.shopping_cart),
                      ),
                      title: Text(sale.numeroVenta),
                      subtitle: Text(
                        'Total: \$${sale.total.toStringAsFixed(2)} • ${sale.estado}',
                      ),
                      trailing: Text(
                        '${sale.fecha.day}/${sale.fecha.month}/${sale.fecha.year}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.blue.shade700),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.inbox, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
