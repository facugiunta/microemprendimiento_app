import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mobile_app/config/app_theme.dart';
import 'package:mobile_app/config/router.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/providers/producto_provider.dart';
import 'package:mobile_app/providers/compra_provider.dart';
import 'package:mobile_app/providers/venta_provider.dart';
import 'package:mobile_app/providers/inversion_provider.dart';
import 'package:mobile_app/providers/reporte_provider.dart';
import 'package:mobile_app/providers/auditoria_provider.dart';
import 'package:mobile_app/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_AR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ProductoProvider(), lazy: true),
        ChangeNotifierProvider(create: (_) => CompraProvider(), lazy: true),
        ChangeNotifierProvider(create: (_) => VentaProvider(), lazy: true),
        ChangeNotifierProvider(create: (_) => InversionProvider(), lazy: true),
        ChangeNotifierProvider(create: (_) => ReporteProvider(), lazy: true),
        ChangeNotifierProvider(create: (_) => AuditoriaProvider(), lazy: true),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: 'Mi Emprendimiento',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            routerConfig: appRouter,
            locale: const Locale('es', 'AR'),
          );
        },
      ),
    );
  }
}
