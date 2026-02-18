import 'package:flutter/material.dart';
import './audit_section.dart';
import './backup_section.dart';
import './purchases_section.dart';
import './roles_permissions_section.dart';
import './stock_movements_section.dart';
import './suppliers_section.dart';

class MoreSection extends StatelessWidget {
  const MoreSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Más',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildTile(
            context,
            title: 'Compras',
            subtitle: 'Órdenes de compra y gastos',
            icon: Icons.shopping_bag,
            page: const PurchasesSection(),
          ),
          _buildTile(
            context,
            title: 'Proveedores',
            subtitle: 'Gestiona proveedores',
            icon: Icons.store,
            page: const SuppliersSection(),
          ),
          _buildTile(
            context,
            title: 'Movimientos',
            subtitle: 'Entradas y salidas de stock',
            icon: Icons.compare_arrows,
            page: const StockMovementsSection(),
          ),
          _buildTile(
            context,
            title: 'Auditoría',
            subtitle: 'Historial de permisos y accesos',
            icon: Icons.security,
            page: const AuditSection(),
          ),
          _buildTile(
            context,
            title: 'Roles y permisos',
            subtitle: 'Gestiona acceso de usuarios',
            icon: Icons.admin_panel_settings,
            page: const RolesPermissionsSection(),
          ),
          _buildTile(
            context,
            title: 'Backup',
            subtitle: 'Respaldo y restauración',
            icon: Icons.backup,
            page: const BackupSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget page,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue.shade700),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
      ),
    );
  }
}
