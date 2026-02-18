# 🔐 PHASE 7: USERS & PERMISSIONS - IMPLEMENTADA

## Overview
**Users & Permissions Module** es un sistema completo de control de acceso (RBAC - Role-Based Access Control) que proporciona:
- Gestión de roles
- Gestión de permisos granulares
- Asignación de roles a usuarios
- Verificación de permisos
- Auditoría de acceso
- Multi-usuario con control de acceso

## Archivos Creados

### 1. **Permissions.ts** (Model - 350+ líneas)
Métodos principales:

**Role Management:**
- `createRole()` - Crear rol
- `getRoles()` - Listar roles con filtros
- `getRoleById()` - Obtener rol específico
- `updateRole()` - Actualizar rol
- `deleteRole()` - Eliminar rol (con cascada)

**Permission Management:**
- `createPermission()` - Crear permiso
- `getPermissions()` - Listar permisos con filtros
- `getPermissionById()` - Obtener permiso específico
- `deletePermission()` - Eliminar permiso

**Role-Permission Assignment:**
- `assignPermissionToRole()` - Asignar permiso a rol
- `removePermissionFromRole()` - Remover permiso de rol
- `getRolePermissions()` - Ver permisos de un rol
- `assignPermissionsToRole()` - Asignar múltiples permisos

**User-Role Assignment:**
- `assignRoleToUser()` - Asignar rol a usuario
- `removeRoleFromUser()` - Remover rol de usuario
- `getUserRoles()` - Ver roles de un usuario
- `assignRolesToUser()` - Asignar múltiples roles

**Permission Verification:**
- `getUserPermissions()` - Ver todos los permisos de un usuario
- `userHasPermission()` - Verificar permiso específico
- `userHasAnyPermission()` - Verificar si tiene alguno de los permisos
- `getUsersByRole()` - Listar usuarios con un rol

**Audit:**
- `logPermissionCheck()` - Registrar verificación de permiso
- `getUserActivityLog()` - Ver historial de actividades

### 2. **permissionsController.ts** (Controller - 250+ líneas)
Controladores para:
- CRUD de roles (5 endpoints)
- CRUD de permisos (4 endpoints)
- Gestión de role-permissions (4 endpoints)
- Gestión de user-roles (5 endpoints)
- Verificación de permisos (2 endpoints)
- Listado de usuarios por rol (1 endpoint)
- Auditoría (1 endpoint)

### 3. **permissions.ts** (Routes - 40 líneas)
22 rutas API con autenticación requerida

### 4. **permissions.sql** (Schema - 150+ líneas)
Base de datos:
- `roles` table - 5 roles predefinidos
- `permissions` table - 30+ permisos predefinidos
- `role_permissions` table - muchos-a-muchos
- `user_roles` table - muchos-a-muchos
- `permission_logs` table - auditoría
- 15 índices para performance

### 5. **permissionMiddleware.ts** (Utility - 100+ líneas)
Middleware para:
- `checkPermission()` - Verificar permiso específico
- `checkAnyPermission()` - Verificar alguno de los permisos
- `getUserSecurityInfo()` - Obtener info de roles/permisos
- `hasPermission()` - Utility function
- `getUserPermissionSet()` - Get all user permissions as Set

## Roles Predefinidos

| Rol | Descripción | Permisos |
|-----|-------------|----------|
| `admin` | Administrador del sistema | Todos los permisos |
| `manager` | Gerente de operaciones | Read/Create/Update en ventas, compras, clientes, productos, stock; Export de reportes |
| `sales` | Vendedor | Create/Read/Update en sales; Read/Create en customers; Read en products |
| `warehouse` | Personal de almacén | Read/Create/Update en stock; Read en products |
| `viewer` | Solo lectura | Read en todos los módulos |

## Permisos Predefinidos

### Sales (5 permisos)
- `sales:create` - Crear ventas
- `sales:read` - Ver ventas
- `sales:update` - Modificar ventas
- `sales:delete` - Eliminar ventas
- `sales:export` - Exportar reportes

### Purchases (5 permisos)
- `purchases:create` - Crear compras
- `purchases:read` - Ver compras
- `purchases:update` - Modificar compras
- `purchases:delete` - Eliminar compras
- `purchases:export` - Exportar reportes

### Customers (4 permisos)
- `customers:create` - Crear clientes
- `customers:read` - Ver clientes
- `customers:update` - Modificar clientes
- `customers:delete` - Eliminar clientes

### Products (4 permisos)
- `products:create` - Crear productos
- `products:read` - Ver productos
- `products:update` - Modificar productos
- `products:delete` - Eliminar productos

### Stock (4 permisos)
- `stock:create` - Crear movimientos
- `stock:read` - Ver niveles
- `stock:update` - Ajustar stock
- `stock:manage` - Gestionar almacenes

### Reports (2 permisos)
- `reports:read` - Ver reportes
- `reports:export` - Exportar reportes

### Users (4 permisos)
- `users:create` - Crear usuarios
- `users:read` - Ver usuarios
- `users:update` - Modificar usuarios
- `users:delete` - Eliminar usuarios
- `users:manage` - Gestionar roles/permisos

### Settings (1 permiso)
- `settings:manage` - Gestionar configuración

## API Endpoints (22 nuevos)

### Roles Management (5)
```
POST   /api/permissions/roles                → Crear rol
GET    /api/permissions/roles                → Listar roles
GET    /api/permissions/roles/:id            → Obtener rol
PUT    /api/permissions/roles/:id            → Actualizar rol
DELETE /api/permissions/roles/:id            → Eliminar rol
```

### Permissions Management (4)
```
POST   /api/permissions/permissions          → Crear permiso
GET    /api/permissions/permissions          → Listar permisos
GET    /api/permissions/permissions/:id      → Obtener permiso
DELETE /api/permissions/permissions/:id      → Eliminar permiso
```

### Role-Permission Assignment (4)
```
POST   /api/permissions/roles/:id/permissions              → Asignar permiso
DELETE /api/permissions/roles/:id/permissions              → Remover permiso
GET    /api/permissions/roles/:id/permissions              → Ver permisos del rol
POST   /api/permissions/roles/:id/permissions/bulk         → Asignar múltiples
```

### User-Role Assignment (5)
```
POST   /api/permissions/users/assign-role                  → Asignar rol
DELETE /api/permissions/users/:id/roles                    → Remover rol
GET    /api/permissions/users/:id/roles                    → Ver roles del usuario
POST   /api/permissions/users/:id/roles/bulk               → Asignar múltiples roles
GET    /api/permissions/users/:id/permissions              → Ver permisos del usuario
```

### Permission Checks (2)
```
GET    /api/permissions/check                              → Verificar permiso específico
POST   /api/permissions/check/:userId                      → Verificar alguno de los permisos
```

### Listing (1)
```
GET    /api/permissions/roles/:id/users                    → Listar usuarios con rol
```

### Audit (1)
```
GET    /api/permissions/users/:id/activity                 → Ver activity log
```

## Ejemplos de Uso

### 1. Crear Rol
```bash
curl -X POST http://localhost:3000/api/permissions/roles \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"supervisor","description":"Supervisor de área"}'
```

### 2. Crear Permiso
```bash
curl -X POST http://localhost:3000/api/permissions/permissions \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Generate Reports","description":"Generar reportes","resource":"reports","action":"generate"}'
```

### 3. Asignar Permiso a Rol
```bash
curl -X POST http://localhost:3000/api/permissions/roles/ROLE_ID/permissions \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"roleId":"ROLE_ID","permissionId":"PERMISSION_ID"}'
```

### 4. Asignar Rol a Usuario
```bash
curl -X POST http://localhost:3000/api/permissions/users/assign-role \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"userId":"USER_ID","roleId":"ROLE_ID"}'
```

### 5. Ver Permisos de Usuario
```bash
curl http://localhost:3000/api/permissions/users/USER_ID/permissions \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 6. Verificar Permiso
```bash
curl "http://localhost:3000/api/permissions/check?userId=USER_ID&resource=sales&action=create" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Respuesta:
# {"hasPermission":true}
```

### 7. Ver Activity Log
```bash
curl "http://localhost:3000/api/permissions/users/USER_ID/activity?limit=50" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Usando en Routes (Con Protección de Permisos)

```typescript
// routes/sales.ts
import { Router } from 'express';
import { authenticateToken } from '../middleware/authMiddleware';
import { checkPermission, checkAnyPermission } from '../middleware/permissionMiddleware';
import * as salesController from '../controllers/salesController';

const router = Router();

router.use(authenticateToken);

// Require sales:create permission
router.post('/', 
  checkPermission('sales', 'create'),
  salesController.createSale
);

// Require sales:read permission
router.get('/',
  checkPermission('sales', 'read'),
  salesController.getSales
);

// Require sales:export or manager role
router.get('/export',
  checkPermission('sales', 'export'),
  salesController.exportSales
);

export default router;
```

## Database Schema

### roles
```sql
id UUID (PK)
name VARCHAR(255) UNIQUE
description TEXT
active BOOLEAN
created_at TIMESTAMP
updated_at TIMESTAMP
```

### permissions
```sql
id UUID (PK)
name VARCHAR(255)
description TEXT
resource VARCHAR(100)
action VARCHAR(50)
active BOOLEAN
created_at TIMESTAMP
updated_at TIMESTAMP
UNIQUE(resource, action)
```

### role_permissions
```sql
id UUID (PK)
role_id UUID (FK to roles)
permission_id UUID (FK to permissions)
created_at TIMESTAMP
UNIQUE(role_id, permission_id)
```

### user_roles
```sql
id UUID (PK)
user_id UUID (FK to users)
role_id UUID (FK to roles)
created_at TIMESTAMP
UNIQUE(user_id, role_id)
```

### permission_logs
```sql
id UUID (PK)
user_id UUID (FK to users)
resource VARCHAR(100)
action VARCHAR(50)
allowed BOOLEAN
ip_address VARCHAR(45)
user_agent TEXT
created_at TIMESTAMP
```

## Características

✅ **RBAC (Role-Based Access Control)** - Control granular por roles
✅ **5 Roles Predefinidos** - Admin, Manager, Sales, Warehouse, Viewer
✅ **30+ Permisos** - Cobertura completa de módulos
✅ **Muchos-a-Muchos** - Usuarios → Roles → Permisos
✅ **Middleware de Permisos** - Protección en routes
✅ **Auditoría** - Log completo de acceso
✅ **Transaccional** - Integridad de datos garantizada
✅ **Performance Optimized** - 15 índices

## Seguridad

✅ Verificación de permisos en middleware
✅ Auditoría de acceso en permission_logs
✅ Roles y permisos en BD (no en JWT)
✅ Validación en cada endpoint
✅ Transacciones para integridad
✅ Índices para velocidad

## Casos de Uso

### Caso 1: Multi-usuario con roles diferentes
```typescript
// Admin crea usuario como vendedor
POST /api/auth/register { email, password, name }
POST /api/permissions/users/USERID/roles/bulk { roleIds: [SALES_ROLE_ID] }

// Vendedor solo puede crear/leer ventas
GET /api/sales ✅ (tiene sales:read)
POST /api/sales ✅ (tiene sales:create)
POST /api/purchases ❌ (no tiene purchases:create)
```

### Caso 2: Auditoría de quién hizo qué
```typescript
// Cada acción se registra en permission_logs
GET /api/permissions/users/USER_ID/activity
// Retorna: quién, qué recurso, qué acción, cuándo, permitido/denegado
```

### Caso 3: Dinámico - Crear nuevo rol con permisos
```typescript
POST /api/permissions/roles { name: "accountant" }
POST /api/permissions/roles/NEW_ROLE_ID/permissions/bulk 
  { permissionIds: [REPORTS_READ, FINANCIAL_READ, ...] }
```

## Próximas Mejoras

1. **Resource-level permissions** - `sales:create_own` vs `sales:create_any`
2. **ACLs (Access Control Lists)** - Permisos a nivel de documento
3. **Attribute-based Access Control (ABAC)** - Basado en atributos
4. **Permission delegation** - Delegar permisos temporalmente
5. **Role hierarchy** - Roles heredando de otros roles
6. **Cached permissions** - Redis para verificaciones rápidas

## Resumen de Cambios

✅ Model: Permissions.ts (350+ líneas)
✅ Controller: permissionsController.ts (250+ líneas)
✅ Routes: permissions.ts (40 líneas)
✅ Middleware: permissionMiddleware.ts (100+ líneas)
✅ Schema: permissions.sql (150+ líneas)
✅ app.ts: Registrado permissions routes
✅ docker-compose.yml: Montado 05-permissions.sql

**Total endpoints: 22 nuevos**
**Total líneas de código: 890+**
**Total endpoints en backend: 68 + 22 = 90**

---

## Para Activar

```powershell
docker-compose down
docker-compose up -d --build
```

El sistema creará automáticamente:
- 5 roles (admin, manager, sales, warehouse, viewer)
- 30+ permisos
- Asignaciones predefinidas

---

**Estado: ✅ PHASE 7 COMPLETADA**

## Backend Status Final:
- Phase 2: Authentication (5 endpoints) ✅
- Phase 3: Sales (20 endpoints) ✅
- Phase 4: Purchases (13 endpoints) ✅
- Phase 5: Stock (12 endpoints) ✅
- Phase 6: Reports (18 endpoints) ✅
- Phase 7: Users & Permissions (22 endpoints) ✅
- **TOTAL: 90 ENDPOINTS** ✅

---

**Próxima opción:**
1. **Frontend Flutter** - Empezar app móvil
2. **Phase 8: Notifications** - Email, push, webhooks
3. **Phase 9: Integrations** - APIs externas, pagos
4. **Testing & QA** - Suite de tests
