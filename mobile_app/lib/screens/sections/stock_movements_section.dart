import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../models/stock_movement_model.dart';
import '../../models/warehouse_model.dart';
import '../../services/producto_service.dart';

class StockMovementsSection extends StatefulWidget {
  const StockMovementsSection({super.key});

  @override
  State<StockMovementsSection> createState() => _StockMovementsSectionState();
}

class _StockMovementsSectionState extends State<StockMovementsSection> {
  List<StockMovement> movements = [];
  List<Warehouse> warehouses = [];
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
      final productsResult = await ProductoService.listarProductos();

      if (productsResult['success'] == true) {
        final productsList = productsResult['productos'] as List? ?? [];
        products = productsList.whereType<Product>().toList();
      }
      movements = [];
      warehouses = [];
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

  void _showAddMovementDialog() {
    if (warehouses.isEmpty || products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero crea almacenes y productos.')),
      );
      return;
    }

    Warehouse selectedWarehouse = warehouses.first;
    Product selectedProduct = products.first;
    String movementType = 'entrada';
    final quantityController = TextEditingController(text: '1');
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar Movimiento'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Warehouse>(
                initialValue: selectedWarehouse,
                items: warehouses
                    .map((w) => DropdownMenuItem(value: w, child: Text(w.name)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) selectedWarehouse = value;
                },
                decoration: const InputDecoration(labelText: 'Almacén'),
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
                  if (value != null) selectedProduct = value;
                },
                decoration: const InputDecoration(labelText: 'Producto'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: movementType,
                items: const [
                  DropdownMenuItem(value: 'entrada', child: Text('Entrada')),
                  DropdownMenuItem(value: 'salida', child: Text('Salida')),
                  DropdownMenuItem(value: 'ajuste', child: Text('Ajuste')),
                ],
                onChanged: (value) {
                  if (value != null) movementType = value;
                },
                decoration: const InputDecoration(labelText: 'Tipo'),
              ),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Cantidad'),
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
              try {
                // TODO: Implement stock movement recording

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Feature not yet implemented'),
                    ),
                  );
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
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
  }

  void _showAddWarehouseDialog() {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final capacityController = TextEditingController(text: '1000');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Almacén'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Ubicación'),
              ),
              TextField(
                controller: capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Capacidad'),
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
              try {
                // TODO: Implement warehouse creation

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Feature not yet implemented'),
                    ),
                  );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Movimientos de Stock')),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showAddMovementDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Nuevo Movimiento'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showAddWarehouseDialog,
                    icon: const Icon(Icons.warehouse),
                    label: const Text('Nuevo Almacén'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (movements.isEmpty)
              _buildEmptyState('No hay movimientos registrados')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: movements.length,
                itemBuilder: (context, index) {
                  final movement = movements[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple.shade100,
                        child: const Icon(Icons.compare_arrows),
                      ),
                      title: Text(
                        '${movement.productName} (${movement.productCode})',
                      ),
                      subtitle: Text(
                        '${movement.movementType} • ${movement.quantity} • ${movement.warehouseName}',
                      ),
                      trailing: Text(
                        '${movement.createdAt.day}/${movement.createdAt.month}',
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
