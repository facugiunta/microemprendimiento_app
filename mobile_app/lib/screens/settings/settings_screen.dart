import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/config/app_theme.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final usuario = authProvider.usuario;

    return Scaffold(
      appBar: AppBar(title: const Text('Configuracion')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Datos del usuario', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nombre: ${usuario?.name ?? 'N/A'}'),
                    const SizedBox(height: 8),
                    Text('Email: ${usuario?.email ?? 'N/A'}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Apariencia', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) => Card(
                child: SwitchListTile(
                  title: const Text('Tema oscuro'),
                  value: themeProvider.isDarkMode,
                  onChanged: (_) => themeProvider.toggleTheme(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: const ListTile(title: Text('Version'), subtitle: Text('1.0.0')),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text('Cerrar sesion'),
                      content: const Text('Estas seguro?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(c),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await authProvider.logout();
                            if (context.mounted) context.go('/login');
                          },
                          child: const Text('Cerrar sesion'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Cerrar sesion'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
