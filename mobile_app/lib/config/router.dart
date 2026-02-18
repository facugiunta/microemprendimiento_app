import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/screens/splash/splash_screen.dart';
import 'package:mobile_app/screens/auth/login_screen.dart';
import 'package:mobile_app/screens/auth/register_screen.dart';
import 'package:mobile_app/screens/home/home_screen.dart';
import 'package:mobile_app/screens/productos/productos_screen.dart';
import 'package:mobile_app/screens/productos/producto_form_screen.dart';
import 'package:mobile_app/screens/compras/compras_screen.dart';
import 'package:mobile_app/screens/compras/compra_form_screen.dart';
import 'package:mobile_app/screens/ventas/ventas_screen.dart';
import 'package:mobile_app/screens/ventas/venta_form_screen.dart';
import 'package:mobile_app/screens/inversiones/inversiones_screen.dart';
import 'package:mobile_app/screens/inversiones/inversion_form_screen.dart';
import 'package:mobile_app/screens/reportes/reportes_screen.dart';
import 'package:mobile_app/screens/reportes/reporte_feria_screen.dart';
import 'package:mobile_app/screens/historial/historial_screen.dart';
import 'package:mobile_app/screens/auditoria/auditoria_screen.dart';
import 'package:mobile_app/screens/backup/backup_screen.dart';
import 'package:mobile_app/screens/settings/settings_screen.dart';

// GoRouter configuration
final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'productos',
          builder: (context, state) => const ProductosScreen(),
          routes: [
            GoRoute(
              path: 'crear',
              builder: (context, state) => const ProductoFormScreen(),
            ),
            GoRoute(
              path: 'editar/:id',
              builder: (context, state) {
                final id = state.pathParameters['id'];
                return ProductoFormScreen(productoId: int.tryParse(id ?? ''));
              },
            ),
          ],
        ),
        GoRoute(
          path: 'compras',
          builder: (context, state) => const ComprasScreen(),
          routes: [
            GoRoute(
              path: 'crear',
              builder: (context, state) => const CompraFormScreen(),
            ),
          ],
        ),
        GoRoute(
          path: 'ventas',
          builder: (context, state) => const VentasScreen(),
          routes: [
            GoRoute(
              path: 'crear',
              builder: (context, state) => const VentaFormScreen(),
            ),
          ],
        ),
        GoRoute(
          path: 'inversiones',
          builder: (context, state) => const InversionesScreen(),
          routes: [
            GoRoute(
              path: 'crear',
              builder: (context, state) => const InversionFormScreen(),
            ),
            GoRoute(
              path: 'editar/:id',
              builder: (context, state) {
                final id = state.pathParameters['id'];
                return InversionFormScreen(inversionId: int.tryParse(id ?? ''));
              },
            ),
          ],
        ),
        GoRoute(
          path: 'reportes',
          builder: (context, state) => const ReportesScreen(),
          routes: [
            GoRoute(
              path: 'feria',
              builder: (context, state) => const ReporteFeriaScreen(),
            ),
          ],
        ),
        GoRoute(
          path: 'historial',
          builder: (context, state) => const HistorialScreen(),
        ),
        GoRoute(
          path: 'auditoria',
          builder: (context, state) => const AuditoriaScreen(),
        ),
        GoRoute(
          path: 'backup',
          builder: (context, state) => const BackupScreen(),
        ),
        GoRoute(
          path: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Error: ${state.error}'))),
);
