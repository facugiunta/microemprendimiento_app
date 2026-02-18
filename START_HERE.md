# ✅ INICIO INMEDIATO - 5 PASOS

Sigue estos 5 pasos en orden para tener la app funcionando en **menos de 5 minutos**.

---

## PASO 1: Inicia el Backend (30 segundos)

### Si usas Docker (Recomendado)
```bash
docker-compose up -d
# Espera 5 segundos, luego verifica:
curl http://localhost:3000/api/health
# Deberías ver: {"status":"ok"}
```

### Si no usas Docker
```bash
cd backend
npm install
npm run dev
# Espera a ver: "Server running on http://localhost:3000"
```

---

## PASO 2: Inicia Flutter (1 minuto)

### En otra terminal (o en VSCode abre terminal nueva)
```bash
cd mobile_app
flutter pub get
# Espera a que termine (puede tomar 30 segundos)
```

---

## PASO 3: Elige tu dispositivo (1 minuto)

Elige UNA opción según qué tengas disponible:

### A) Android Emulator (Más fácil)
```bash
flutter run
# Se abrirá automáticamente en el emulador por defecto
```

### B) iOS Simulator
```bash
flutter run -d iPhone
```

### C) macOS
```bash
flutter run -d macos
```

### D) Windows Desktop
```bash
flutter run -d windows
```

---

## PASO 4: La app se abrirá con estas opciones

Verás una pantalla de **SPLASH SCREEN** (logo con animación) que redirige automáticamente a:
- **LOGIN** si no estás logueado
- **HOME** si ya estás logueado

---

## PASO 5: Inicia sesión con estas credenciales

```
Email:    test@test.com
Password: password123
```

**¡LISTO!** 🎉 Ahora estás dentro de la app!

---

## ¿Qué Puedes Hacer Ahora?

En el HOME verás una barra de navegación con 5 opciones:

1. **Inicio** - Dashboard con resumen del mes
2. **Productos** - Ver, crear, editar productos
3. **Reportes** - Resumen mensual y reportes de ferias
4. **Historial** - Ver todo lo que pasó (5 pestañas)
5. **Más** - Auditoría, backup, configuración

### Acciones Rápidas que Puedes Hacer:

- **Crear Producto**: Toca "Productos" → botón + → Completa formulario
- **Registrar Venta**: Toca "Inicio" → botón "Nueva Venta" → Selecciona producto
- **Registrar Compra**: Toca "Inicio" → botón "Nueva Compra" → Ingresa datos
- **Ver Historial**: Toca "Historial" → Selecciona pestaña (Ventas/Compras/etc)
- **Cambiar tema**: Toca "Más" → "Settings" → Toggle de tema oscuro

---

## Si Algo No Funciona

### "No se abre la app"
```bash
# Might means dependencies not installed
flutter clean
flutter pub get
flutter run -v  # Ver error en detalle
```

### "Error de conexión (No se conecta al backend)"

**Android Emulator:**
```bash
# Verifica que se vea el backend
adb shell ping 10.0.2.2
# Si no responde, reinicia el emulador
emulator -avd Pixel_5_API_33 -no-snapshot-load
```

**iOS/macOS/Windows:**
```bash
# Verifica que el backend esté corriendo
curl http://localhost:3000/api/health
# Deberías ver: {"status":"ok"}
```

### "No puedo loguearm"

1. Verifica credenciales:
   - Email: `test@test.com`
   - Password: `password123`

2. Si quieres crear nuevo usuario:
   - Toca "Crear cuenta" en la pantalla de login
   - Lleña el formulario con datos válidos

---

## Modo QA / Testing

Eres desarrollador y quieres ver logs de API?

Edita `mobile_app/lib/services/api_service.dart` y descomenta:
```dart
print('REQUEST: $method $path');
print('RESPONSE: ${response.statusCode}');
```

Verás todos los llamados a la API en la consola de Flutter.

---

## Hot Reload (Desarrollo)

Mientras la app está corriendo, si cambias código:

- Presiona **`r`** para hot reload (cambios en los widgets)
- Presiona **`R`** para full restart (cambios en state/providers)
- Presiona **`q`** para salir

---

## Documentación Completa

Si necesitas más detalles:

- **[FLUTTER_APP_FINAL_SUMMARY.md](FLUTTER_APP_FINAL_SUMMARY.md)** - Resumen técnico
- **[QUICK_START_TESTING.md](QUICK_START_TESTING.md)** - Cómo probar en diferentes plataformas
- **[PLATFORM_CONFIGURATION_COMPLETE.md](PLATFORM_CONFIGURATION_COMPLETE.md)** - Configuración de Android/macOS
- **[README.md](README.md)** - Documentación general del proyecto

---

## Troubleshooting Rápido

| Problema | Solución |
|----------|----------|
| App no abre | `flutter clean && flutter pub get && flutter run -v` |
| No se conecta | Verifica `curl http://localhost:3000/api/health` |
| Login falla | Credenciales: `test@test.com` / `password123` |
| Emulator no ve backend | Ejecuta: `adb shell ping 10.0.2.2` |
| Cambios no se ven | Presiona `r` en terminal para hot reload |

---

## Próximos Pasos (Opcional)

Cuando estés listo para más:

- Crear productos y registrar ventas/compras
- Probar en dispositivo físico (Android o iOS)
- Ver reportes mensuales
- Emiti reportes de ferias
- Explorar todas las pantallas

---

**¡Contáctame si hay problemas!**

El sistema está 100% funcional y listo para probar. Toda la interacción es real y se guarda en la base de datos PostgreSQL.

---

**Tiempo total estimado desde 0**: 5 minutos ⚡
