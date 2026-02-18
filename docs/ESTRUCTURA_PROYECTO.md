# 📁 Estructura del Proyecto Microemprendimiento

## Descripción General

Este proyecto es una aplicación multiplataforma para gestión de microemprendimientos con:
- **Frontend**: Flutter (Android, iOS, macOS, Windows)
- **Backend**: Node.js + Express
- **Base de Datos**: PostgreSQL (Docker)
- **Caché**: Redis (Docker)

---

## 📋 Carpetas Principales

### 📦 `/backend`
Backend Node.js con Express 5. Completamente funcional.

```
backend/
├── src/
│   ├── index.js              # Entry point
│   ├── config/               # Configuración (BD, Redis, migraciones)
│   ├── middleware/           # JWT, validaciones, error handler
│   ├── routes/               # Todas las rutas de API
│   ├── controllers/          # Lógica de negocio
│   └── utils/                # Utilidades (audit, excel)
├── package.json
├── .env
└── Dockerfile
```

**Estado**: ✅ Ejecutándose en `http://0.0.0.0:3000`

---

### 📱 `/mobile_app`
Aplicación Flutter para todos los platforms.

```
mobile_app/
├── lib/                      # Código Dart
├── android/                  # Build Android
├── ios/                      # Build iOS
├── macos/                    # Build macOS
├── windows/                  # Build Windows
├── web/                      # Build Web
└── pubspec.yaml
```

---

### 📚 `/docs`
**Toda la documentación de fases previas del proyecto.**

Contiene:
- Planificación de fases (PHASE_3 a PHASE_7)
- Documentación técnica (ARCHITECTURE, AUTHENTICATION, DOCKER_CONFIGURATION)
- Resúmenes de implementación
- Checklists y verificaciones

**Nota**: Esta documentación es histórica. El `README.md` en raíz es la documentación actual.

---

### 🔧 `/scripts`
Scripts útiles de desarrollo y testing.

- **QUICK_START.ps1**: Script para iniciar rápidamente todo (PowerShell)
- **test-auth.sh**: Testing de autenticación (Bash)

---

### ⚙️ `/config`
Archivos de configuración del proyecto.

- **.eslintrc.json**: Configuración de linting JavaScript
- **.prettierrc**: Configuración de formateo de código

---

## 📄 Archivos en Raíz

| Archivo | Propósito |
|---------|-----------|
| `docker-compose.yml` | ✅ Necesario - Inicia PostgreSQL y Redis |
| `README.md` | ✅ Necesario - Documentación principal |
| `package.json` | ✅ Necesario - Dependencias del proyecto raíz |
| `package-lock.json` | ✅ Necesario - Lock de versiones |
| `.gitignore` | ✅ Necesario - Git config |
| `.env` | ✅ Necesario - Variables de entorno (no subir a git) |
| `startup.log` | ⚠️ Temporal - Generado al startup |

---

## 🚀 Cómo Usar el Proyecto

### 1️⃣ Iniciar el Backend

```bash
# Asegúrate de estar en la raíz
docker-compose up -d        # Inicia PostgreSQL y Redis
cd backend
npm install                 # Una sola vez
npm start                   # Inicia el servidor en puerto 3000
```

### 2️⃣ Iniciar la App Flutter

```bash
# En otra terminal
cd mobile_app
flutter pub get
flutter run                 # Selecciona el device/emulator
```

### 3️⃣ Pruebas Rápidas

```bash
# En PowerShell
.\scripts\QUICK_START.ps1

# O manualmente:
# GET    http://0.0.0.0:3000/health
# POST   http://0.0.0.0:3000/api/auth/register
# POST   http://0.0.0.0:3000/api/auth/login
```

---

## 📊 API Endpoints

El backend proporciona estos endpoints:

```
POST   /api/auth/register               # Registrar usuario
POST   /api/auth/login                  # Login
GET    /api/auth/me                     # Datos del usuario

GET    /api/productos                   # Listar
POST   /api/productos                   # Crear
PUT    /api/productos/:id               # Actualizar
DELETE /api/productos/:id               # Eliminar

GET    /api/compras                     # Listar compras
POST   /api/compras                     # Registrar compra

GET    /api/ventas                      # Listar ventas
POST   /api/ventas                      # Registrar venta

GET    /api/inversiones                 # Listar inversiones
POST   /api/inversiones                 # Crear inversión

GET    /api/reportes/mensual            # Reporte mensual
POST   /api/reportes/feria              # Crear reporte feria

GET    /api/auditoria                   # Historial de cambios

GET    /api/historial/ventas            # Historial completo
GET    /api/historial/compras
GET    /api/historial/todo              # Timeline unificada

POST   /api/backup/crear                # Crear backup
POST   /api/backup/restaurar            # Restaurar backup

GET    /api/exportar/productos          # Exportar a Excel
GET    /api/exportar/ventas
GET    /api/exportar/compras
GET    /api/exportar/inversiones
GET    /api/exportar/reporte-mensual
GET    /api/exportar/auditoria
```

---

## 🔐 Variables de Entorno

### `.env` en raíz
```env
NODE_ENV=production
```

### `backend/.env`
```env
NODE_ENV=development
PORT=3000

DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=postgres_password_secure_123
DB_NAME=microemprendimiento_db

REDIS_HOST=localhost
REDIS_PORT=6379

JWT_SECRET=tu-super-secreto-cambiar-en-produccion
JWT_EXPIRES_IN=7d

CORS_ORIGIN=*
```

---

## 🗄️ Base de Datos

PostgreSQL con 8 tablas:

- `usuarios` - Usuarios registrados
- `productos` - Catálogo de productos
- `compras` - Registro de compras (reposición)
- `ventas` - Registro de ventas
- `inversiones` - Gastos de infraestructura
- `reportes_feria` - Reportes de eventos
- `reportes_feria_items` - Items dentro de reportes
- `auditoria` - Log de todas las acciones

---

## 📈 Roadmap

- ✅ Backend Node.js completamente implementado
- ✅ Base de datos PostgreSQL con 8 tablas
- ✅ Autenticación JWT
- ✅ Auditoría automática de cambios
- ✅ Exportación a Excel
- ✅ Backup/Restauración
- ⏳ Frontend Flutter (en desarrollo)
- ⏳ Conexión Flutter ↔ Backend
- ⏳ Testing automatizado
- ⏳ Deployment a producción

---

## 📞 Soporte

Para más información, consulta:
- `docs/ARCHITECTURE.md` - Arquitectura técnica
- `docs/AUTHENTICATION.md` - Sistema de autenticación
- `docs/README_COMPLETE.txt` - Documentación completa anterior
- `README.md` - Guía principal del proyecto

