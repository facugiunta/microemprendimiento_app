# 📱 Sistema de Gestión de Microemprendimientos - FULL STACK

Aplicación completa de gestión integral de ventas, compras, inversiones y stock con backend Node.js/Express y frontend Flutter multiplataforma.

**Stack Completo:**
- ✅ **Frontend**: Flutter 3.41+ (Android, iOS, macOS, Windows)
- ✅ **Backend**: Node.js/Express com PostgreSQL
- ✅ **Autenticación**: JWT con token refresh
- ✅ **Estado**: Provider pattern con 8 providers
- ✅ **Diseño**: Material Design 3 completo
- ✅ **Datos**: PostgreSQL + Redis caché

---

## 🚀 INICIO RÁPIDO (5 minutos)

### Opción 1: Con Docker (Recomendado)

```bash
# 1. Levanta todo (backend + base de datos)
docker-compose up -d

# 2. Instala Flutter (si no tienes)
# https://flutter.dev/docs/get-started/install

# 3. Inicia la app Flutter
cd mobile_app
flutter pub get
flutter run

# 4. Prueba con estas credenciales
Email: test@test.com
Password: password123
```

### Opción 2: Sin Docker (Desarrollo Local)

```bash
# 1. Backend
cd backend
npm install
npm run dev          # Puerto 3000

# 2. Frontend (en otra terminal)
cd mobile_app
flutter pub get
flutter run

# 3. Credenciales de prueba
Email: test@test.com
Password: password123
```

---

## 📁 Estructura del Proyecto

```
microemprendimiento_app/
├── backend/                          # Node.js/Express
│   ├── src/
│   │   ├── routes/                   # 30+ API endpoints
│   │   ├── models/                   # 8 data models
│   │   ├── services/                 # Business logic
│   │   ├── middleware/               # Auth, validation
│   │   └── config/                   # Database, env
│   ├── database/
│   │   ├── migrations/               # PostgreSQL schema
│   │   └── seeds/                    # Initial data
│   └── package.json
│
├── mobile_app/                       # Flutter 3.41+
│   ├── lib/
│   │   ├── config/                   # API, theme, router
│   │   ├── models/                   # Data classes (8)
│   │   ├── services/                 # API integration (10)
│   │   ├── providers/                # State management (8)
│   │   ├── screens/                  # UI screens (17+)
│   │   ├── widgets/                  # Common components
│   │   └── main.dart
│   ├── android/                      # Android config
│   ├── ios/                          # iOS config
│   ├── macos/                        # macOS config
│   ├── windows/                      # Windows config
│   └── pubspec.yaml
│
├── docker-compose.yml                # PostgreSQL + Redis
├── .env                              # Configuration
└── docs/                             # Additional docs
```

---

## 🎯 CARACTERÍSTICAS IMPLEMENTADAS

### 📱 Frontend Flutter (COMPLETO)
- ✅ **Autenticación**: Register, Login, Session management
- ✅ **Gestión de Productos**: CRUD + búsqueda + alertas de stock bajo
- ✅ **Ventas**: Registro + historial + filtros por fecha
- ✅ **Compras**: Registro + historial + gestión de proveedores
- ✅ **Inversiones**: Tracking con 7 categorías predefinidas
- ✅ **Reportes**: Resumen mensual + reportes de ferias
- ✅ **Historial Unificado**: 5 pestañas (Ventas/Compras/Inversiones/Reportes/Todo)
- ✅ **Configuración**: Temas oscuro/claro, información de usuario
- ✅ **Material Design 3**: Colores personalizados (Emerald + Amber)
- ✅ **Responsive**: Funciona en todos los tamaños de pantalla

### 🔧 Backend API (COMPLETO)
- ✅ **30+ Endpoints** listos para consumir
- ✅ **JWT Authentication** con token refresh
- ✅ **CRUD completo** para todos los módulos
- ✅ **Filtros avanzados** (por fecha, categoría, estado)
- ✅ **Validación** en todos los endpoints
- ✅ **Error handling** consistente
- ✅ **PostgreSQL** como base de datos principal
- ✅ **Redis** para caché y sesiones

---

## 🌐 Acceder a los Servicios

| Servicio | URL | Notas |
|----------|-----|-------|
| **Backend** | http://localhost:3000 | API endpoints |
| **PgAdmin** | http://localhost:5050 | admin@example.com / admin |
| **PostgreSQL** | localhost:5432 | Solo con Docker |
| **Redis** | localhost:6379 | Solo con Docker |
| **Firebase** | (Configurar si necesitas) | Push notifications |

---

## 📱 Ejecutar en Diferentes Plataformas

### Android (Emulador)
```bash
cd mobile_app
flutter run

# O en específico
emulator -avd Pixel_5_API_33
flutter run -d emulator-5554
```

### iOS (Simulador)
```bash
cd mobile_app
flutter run -d iPhone
# O abrir en Xcode: open ios/Runner.xcworkspace
```

### macOS
```bash
cd mobile_app
flutter run -d macos
```

### Windows
```bash
cd mobile_app
flutter run -d windows
```

---

## 🔐 Configuración de Seguridad

### Platforms Configurados ✅

**Android:**
- ✅ Internet permission añadida
- ✅ Cleartext traffic permitido para localhost y 10.0.2.2
- ✅ Network security config implementado

**macOS:**
- ✅ Network client entitlements activados
- ✅ Network server entitlements para sandbox seguro

**iOS:**
- ✅ Network access habilitado por defecto

**Windows:**
- ✅ No se requiere configuración especial

### API Configuration
```dart
// Automático según plataforma:
// Android:  http://10.0.2.2:3000/api (emulator gateway)
// iOS/macOS/Windows: http://localhost:3000/api
```

---

## 📚 Documentación Completa

### Para Empezar
- **[QUICK_START_TESTING.md](QUICK_START_TESTING.md)** ← Empieza aquí
- **[PLATFORM_CONFIGURATION_COMPLETE.md](PLATFORM_CONFIGURATION_COMPLETE.md)** - Configuración de plataformas

### Para Entender la App
- **[FLUTTER_APP_FINAL_SUMMARY.md](FLUTTER_APP_FINAL_SUMMARY.md)** - Resumen completo de la app Flutter
- **[FLUTTER_APP_VERIFICATION_CHECKLIST.md](FLUTTER_APP_VERIFICATION_CHECKLIST.md)** - Checklist de verificación

### Backend
- **[BACKEND_STATUS.md](BACKEND_STATUS.md)** - Estado del backend y endpoints
- **[AUTHENTICATION.md](AUTHENTICATION.md)** - Sistema de autenticación JWT
- **[SALES_MODULE.md](SALES_MODULE.md)** - Módulo de Ventas
- **[PURCHASES_MODULE.md](PURCHASES_MODULE.md)** - Módulo de Compras
- **[DOCKER_SETUP.md](DOCKER_SETUP.md)** - Guía de Docker

---

## 🛠️ Desarrollo

### Instalar Dependencias
```bash
# Backend
cd backend
npm install

# Frontend
cd mobile_app
flutter pub get
```

### Ejecutar en Modo Desarrollo

**Backend (con auto-reload):**
```bash
cd backend
npm run dev
```

**Frontend (con hot reload):**
```bash
cd mobile_app
flutter run
# Presiona 'r' para hot reload
# Presiona 'R' para full restart
```

### Estructura de Carpetas Explicada

**Backend (`backend/src/`):**
- `routes/` - Definición de endpoints
- `models/` - Esquemas de base de datos
- `services/` - Lógica de negocio
- `middleware/` - Auth, validación, errores

**Frontend (`mobile_app/lib/`):**
- `config/` - API, tema, rutas (3 archivos)
- `models/` - Clases de datos (8 archivos)
- `services/` - Integración con API (10 archivos)
- `providers/` - State management (8 archivos)
- `screens/` - Interfaz de usuario (17+ archivos)
- `widgets/` - Componentes reutilizables

---

## 🐛 Troubleshooting

### La app no se conecta al backend
```bash
# Verifica que el backend esté corriendo
curl http://localhost:3000/api/health

# Android emulator especialmente
adb shell ping 10.0.2.2
```

### La compilación falla
```bash
cd mobile_app
flutter clean
flutter pub get
flutter run -v  # Verbose para ver error detallado
```

### Docker no inicia
```bash
# Verifica estatus
docker ps -a

# Ver logs
docker logs microemprendimiento_backend

# Reiniciar
docker-compose restart
```

---

## 🚀 Prepararse para Producción

### Backend
```bash
# Build optimizado
npm run build

# Prueba en modo production
npm start

# Configura variables de entorno reales:
# - DATABASE_URL (base de datos externa)
# - JWT_SECRET (secret seguro)
# - NODE_ENV=production
```

### Frontend
```bash
# Android APK
flutter build apk --release

# iOS IPA
flutter build ios --release

# macOS
flutter build macos --release

# Windows EXE
flutter build windows --release
```

---

## 📊 Estadísticas del Proyecto

| Recurso | Cantidad |
|---------|----------|
| **Endpoints Backend** | 30+ |
| **Pantallas Flutter** | 17+ |
| **Proveedores (State)** | 8 |
| **Servicios API** | 10 |
| **Modelos de Datos** | 8 |
| **Líneas de Código** | 3500+ (solo Flutter) |
| **Dependencias** | 15 (flutter) + 12 (backend) |
| **Plataformas** | 4 (Android, iOS, macOS, Windows) |

---

## 🎨 Diseño Visual

**Material Design 3:**
- Color Primario: Emerald Green (#2E7D32)
- Color Secundario: Amber (#FF8F00)
- Tipografía: Poppins (títulos) + Inter (cuerpo)
- Temas: Light y Dark mode completos
- Responsive: Funciona en todos los tamaños

---

## ✅ Checklist Completado

- ✅ Flutter app completa (17+ screens)
- ✅ Backend Node.js (30+ endpoints)
- ✅ Autenticación JWT
- ✅ State management con Providers
- ✅ Material Design 3
- ✅ Multiplataforma (Android, iOS, macOS, Windows)
- ✅ Documentación completa
- ✅ Configuración de plataformas
- ✅ Manejo de errores robusto
- ✅ Validación de formularios

---

## 📞 Soporte

Si encuentras problemas:

1. **Revisa los archivos de documentación**
2. **Verifica que el backend esté corriendo** (`curl http://localhost:3000/api/health`)
3. **Limpia caché de Flutter** (`flutter clean && flutter pub get`)
4. **Ejecuta en modo verbose** (`flutter run -v`)
5. **Revisa logs** (`docker logs microemprendimiento_backend`)

---

**Última actualización**: Después de configuración de plataformas y biblioteca de widgets
**Estado**: ✅ LISTO PARA USAR
**Versión**: 1.0.0

