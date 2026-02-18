import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../models/purchase_model.dart';
import '../../models/supplier_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/compra_service.dart';
import '../../services/producto_service.dart';

class PurchasesSection extends StatefulWidget {
  const PurchasesSection({super.key});

  @override
  State<PurchasesSection> createState() => _PurchasesSectionState();
}

class _PurchasesSectionState extends State<PurchasesSection> {
  List<Purchase> purchases = [];
  List<Supplier> suppliers = [];
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
      final purchasesResult = await CompraService.listarCompras();
      final productsResult = await ProductoService.listarProductos();

      if (purchasesResult['success'] == true) {
        final purchasesList = purchasesResult['compras'] as List? ?? [];
        purchases = purchasesList.whereType<Purchase>().toList();
      }
      if (productsResult['success'] == true) {
        final productsList = productsResult['productos'] as List? ?? [];
        products = productsList.whereType<Product>().toList();
      }
      suppliers = [];
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

  void _showAddPurchaseDialog() {
    if (suppliers.isEmpty || products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero crea proveedores y productos.')),
      );
      return;
    }

    Supplier selectedSupplier = suppliers.first;
    Product selectedProduct = products.first;
    final quantityController = TextEditingController(text: '1');
    final priceController = TextEditingController(
      text: selectedProduct.precioCosto.toStringAsFixed(2),
    );
    final taxController = TextEditingController(text: '0');
    final notesController = TextEditingController();
    String? paymentMethod;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Compra'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Supplier>(
                initialValue: selectedSupplier,
                items: suppliers
                    .map(
                      (s) => DropdownMenuItem(value: s, child: Text(s.nombre)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) selectedSupplier = value;
                },
                decoration: const InputDecoration(labelText: 'Proveedor'),
              ),
              const SizedBox(height: 8),
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
                    priceController.text = selectedProduct.precioCosto
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
                await CompraService.registrarCompra(
                  productoId: int.tryParse(selectedProduct.id) ?? 0,
                  cantidad: int.tryParse(quantityController.text) ?? 1,
                  precioUnitario: double.tryParse(priceController.text) ?? 0.0,
                );

                if (mounted) {
                  Navigator.pop(context);
                  await _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Compra creada exitosamente')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  if (e is Map && e['success'] == true) {
                    await _loadData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Compra creada exitosamente'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  double _sumPurchases() {
    return purchases.fold<double>(0, (sum, purchase) => sum + purchase.total);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compras')),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Total Compras',
                    value: '\$${_sumPurchases().toStringAsFixed(2)}',
                    icon: Icons.shopping_bag,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Órdenes',
                    value: '${purchases.length}',
                    icon: Icons.receipt_long,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddPurchaseDialog,
              icon: const Icon(Icons.add),
              label: const Text('Nueva Compra'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 24),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (purchases.isEmpty)
              _buildEmptyState('No hay compras aún')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: purchases.length,
                itemBuilder: (context, index) {
                  final purchase = purchases[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange.shade100,
                        child: const Icon(Icons.shopping_bag),
                      ),
                      title: Text(purchase.numeroCompra),
                      subtitle: Text(
                        'Total: \$${purchase.total.toStringAsFixed(2)} • ${purchase.estado}',
                      ),
                      trailing: Text(
                        '${purchase.fecha.day}/${purchase.fecha.month}/${purchase.fecha.year}',
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
