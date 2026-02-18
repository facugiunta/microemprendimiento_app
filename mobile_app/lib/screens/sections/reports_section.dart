import 'package:flutter/material.dart';

class ReportsSection extends StatefulWidget {
  const ReportsSection({super.key});

  @override
  State<ReportsSection> createState() => _ReportsSectionState();
}

class _ReportsSectionState extends State<ReportsSection> {
  Map<String, dynamic> dashboardData = {};
  bool isLoading = false;
  DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    selectedDateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    );
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => isLoading = true);
    try {
      // TODO: Load dashboard data from service
      dashboardData = {};
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

  Future<void> _selectDateRange() async {
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: selectedDateRange,
    );

    if (result != null) {
      setState(() => selectedDateRange = result);
      _loadDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sales = dashboardData['sales'] as List? ?? [];
    final purchases = dashboardData['purchases'] as List? ?? [];
    final profit = dashboardData['profit'] as List? ?? [];
    final inventory = dashboardData['inventory'] as List? ?? [];
    final topProducts = dashboardData['topProducts'] as List? ?? [];
    final totalRevenue = _sumDouble(sales, 'daily_revenue');
    final totalPurchases = _sumDouble(purchases, 'total_cost');
    final totalProfit = _sumDouble(profit, 'profit');

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => _loadDashboard(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Reportes',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _selectDateRange,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                selectedDateRange != null
                    ? '${selectedDateRange!.start.day}/${selectedDateRange!.start.month} - ${selectedDateRange!.end.day}/${selectedDateRange!.end.month}'
                    : 'Seleccionar rango',
              ),
            ),
            const SizedBox(height: 24),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children: [
                  // Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Total Ventas',
                          value: '\$${totalRevenue.toStringAsFixed(2)}',
                          icon: Icons.trending_up,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Compras',
                          value: '\$${totalPurchases.toStringAsFixed(2)}',
                          icon: Icons.shopping_bag,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Ganancia',
                          value: '\$${totalProfit.toStringAsFixed(2)}',
                          icon: Icons.attach_money,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Inventario',
                          value: '${_sumInt(inventory, 'total_products')}',
                          icon: Icons.inventory,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Top Products Section
                  const Text(
                    'Productos Más Vendidos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildTopProductsList(topProducts),
                  const SizedBox(height: 24),

                  // Recent Sales Section
                  const Text(
                    'Resumen de Ventas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildSalesSummaryTable(
                    totalRevenue,
                    totalPurchases,
                    totalProfit,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
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

  Widget _buildTopProductsList(List topProducts) {
    if (topProducts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'Sin datos disponibles',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: topProducts.length,
      itemBuilder: (context, index) {
        final product = topProducts[index] as Map<String, dynamic>;
        final totalQty = product['total_quantity_sold'] ?? 0;
        final productName = product['nombre'] ?? product['name'] ?? 'N/A';
        return ListTile(
          leading: CircleAvatar(child: Text('${index + 1}')),
          title: Text(productName),
          trailing: Text(
            '$totalQty unidades',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  Widget _buildSalesSummaryTable(
    double totalRevenue,
    double totalPurchases,
    double totalProfit,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey.shade100),
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Métrica',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        'Valor',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Ventas Totales'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        '\$${totalRevenue.toStringAsFixed(2)}',
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Compras Totales'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        '\$${totalPurchases.toStringAsFixed(2)}',
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Ganancia Total'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        '\$${totalProfit.toStringAsFixed(2)}',
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _sumDouble(List items, String key) {
    return items.fold<double>(
      0,
      (sum, item) => sum + (double.tryParse(item[key]?.toString() ?? '0') ?? 0),
    );
  }

  int _sumInt(List items, String key) {
    return items.fold<int>(
      0,
      (sum, item) => sum + (int.tryParse(item[key]?.toString() ?? '0') ?? 0),
    );
  }
}
