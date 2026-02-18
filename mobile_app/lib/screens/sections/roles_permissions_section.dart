import 'package:flutter/material.dart';

class RolesPermissionsSection extends StatefulWidget {
  const RolesPermissionsSection({super.key});

  @override
  State<RolesPermissionsSection> createState() =>
      _RolesPermissionsSectionState();
}

class _RolesPermissionsSectionState extends State<RolesPermissionsSection>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<dynamic> roles = [];
  List<dynamic> permissions = [];
  bool loadingRoles = false;
  bool loadingPermissions = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRoles();
    _loadPermissions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRoles() async {
    setState(() => loadingRoles = true);
    try {
      // TODO: Implement role loading from service
      roles = [];
    } finally {
      if (mounted) setState(() => loadingRoles = false);
    }
  }

  Future<void> _loadPermissions() async {
    setState(() => loadingPermissions = true);
    try {
      // TODO: Implement permission loading from service
      permissions = [];
    } finally {
      if (mounted) setState(() => loadingPermissions = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showRoleDialog({Map<String, dynamic>? role}) async {
    final nameController = TextEditingController(text: role?['name'] ?? '');
    final descController = TextEditingController(
      text: role?['description'] ?? '',
    );
    bool active = role?['active'] ?? true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(role == null ? 'Crear rol' : 'Editar rol'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Descripcion'),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: active,
                  onChanged: (value) => setState(() => active = value),
                  title: const Text('Activo'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (result != true) return;

    if (role == null) {
      // TODO: Implement role creation via RoleService
      _showMessage('Crear rol no está implementado aún');
    } else {
      // TODO: Implement role update via RoleService
      _showMessage('Editar rol no está implementado aún');
    }

    _loadRoles();
  }

  Future<void> _showPermissionDialog({Map<String, dynamic>? permission}) async {
    final nameController = TextEditingController(
      text: permission?['name'] ?? '',
    );
    final resourceController = TextEditingController(
      text: permission?['resource'] ?? '',
    );
    final actionController = TextEditingController(
      text: permission?['action'] ?? '',
    );
    final descController = TextEditingController(
      text: permission?['description'] ?? '',
    );
    bool active = permission?['active'] ?? true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(permission == null ? 'Crear permiso' : 'Editar permiso'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: resourceController,
                  decoration: const InputDecoration(labelText: 'Recurso'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: actionController,
                  decoration: const InputDecoration(labelText: 'Accion'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Descripcion'),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: active,
                  onChanged: (value) => setState(() => active = value),
                  title: const Text('Activo'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (result != true) return;

    if (permission == null) {
      // TODO: Implement permission creation via PermissionService
      _showMessage('Crear permiso no está implementado aún');
    } else {
      _showMessage('Edicion no soportada');
    }

    _loadPermissions();
  }

  Future<void> _showAssignPermissionsDialog(Map<String, dynamic> role) async {
    // TODO: Implement role permission management via RoleService
    _showMessage('Gestión de permisos no está implementada aún');
  }

  Future<void> _showAssignRoleToUserDialog(Map<String, dynamic> role) async {
    // TODO: Implement role assignment to user via UserService
    _showMessage('Asignar rol a usuario no está implementado aún');
  }

  Future<void> _confirmDeleteRole(Map<String, dynamic> role) async {
    // TODO: Implement role deletion via RoleService
    _showMessage('Eliminar rol no está implementado aún');
  }

  Future<void> _confirmDeletePermission(Map<String, dynamic> permission) async {
    // TODO: Implement permission deletion via PermissionService
    _showMessage('Eliminar permiso no está implementado aún');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roles y permisos'),
        backgroundColor: Colors.blue.shade700,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Roles'),
            Tab(text: 'Permisos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildRolesTab(), _buildPermissionsTab()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _showRoleDialog();
          } else {
            _showPermissionDialog();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRolesTab() {
    if (loadingRoles) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadRoles,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: roles.length,
        itemBuilder: (context, index) {
          final role = roles[index] as Map<String, dynamic>;
          final permCount = role['permission_count'] ?? 0;
          final userCount = role['user_count'] ?? 0;
          final description = role['description'] ?? 'Sin descripcion';
          final meta = 'Permisos: $permCount | Usuarios: $userCount';
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(role['name'] ?? 'N/A'),
              subtitle: Text('$description\n$meta'),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showRoleDialog(role: role);
                  } else if (value == 'permissions') {
                    _showAssignPermissionsDialog(role);
                  } else if (value == 'assign') {
                    _showAssignRoleToUserDialog(role);
                  } else if (value == 'delete') {
                    _confirmDeleteRole(role);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'permissions', child: Text('Permisos')),
                  PopupMenuItem(
                    value: 'assign',
                    child: Text('Asignar a usuario'),
                  ),
                  PopupMenuItem(value: 'edit', child: Text('Editar')),
                  PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                ],
              ),
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Text(role['name']?.toString().substring(0, 1) ?? 'R'),
              ),
              isThreeLine: true,
              dense: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPermissionsTab() {
    if (loadingPermissions) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadPermissions,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: permissions.length,
        itemBuilder: (context, index) {
          final permission = permissions[index] as Map<String, dynamic>;
          final label = '${permission['resource']}:${permission['action']}';
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(label),
              subtitle: Text(permission['name'] ?? 'Permiso'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmDeletePermission(permission),
              ),
            ),
          );
        },
      ),
    );
  }
}
