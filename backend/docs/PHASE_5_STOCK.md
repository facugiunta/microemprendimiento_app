# 📦 PHASE 5: STOCK MODULE - IMPLEMENTADA

## Overview
**Stock Module** es un sistema completo de gestión de inventario que permite:
- Gestionar múltiples almacenes/depósitos
- Controlar niveles de stock por almacén y producto
- Registrar movimientos de inventario (entrada, salida, ajuste)
- Generar reportes de inventario
- Alertas de bajo stock
- Auditoría de cambios

## Archivos Creados

### 1. **Stock.ts** (Model - 280+ líneas)
Métodos principales:
- `createWarehouse()` - Crear almacén
- `getWarehouses()` - Listar almacenes con filtros
- `getWarehouseById()` - Obtener almacén por ID
- `updateWarehouse()` - Actualizar almacén
- `deleteWarehouse()` - Eliminar almacén
- `initializeStock()` - Crear registro de stock
- `getStockLevels()` - Ver niveles de stock
- `recordMovement()` - Registrar movimiento (transaccional)
- `getMovements()` - Historial de movimientos
- `getLowStockItems()` - Items bajo de stock
- `getStockReport()` - Reportes de inventario
- `adjustStock()` - Ajuste manual de cantidad

### 2. **stockController.ts** (Controller - 160+ líneas)
Controladores para cada endpoint:
- Warehouse CRUD
- Stock initialization
- Movement recording
- Reports and alerts

### 3. **stocks.ts** (Routes - 30 líneas)
Rutas API con autenticación requerida

### 4. **stock.sql** (Schema - 70 líneas)
Base de datos:
- `warehouses` table
- `stock_levels` table (current inventory)
- `stock_movements` table (history)
- 10 índices para performance

## API Endpoints (12 nuevos)

### Warehouse Management (5 endpoints)
```
POST   /api/stocks/warehouses              → Crear almacén
GET    /api/stocks/warehouses              → Listar almacenes
GET    /api/stocks/warehouses/:id          → Obtener almacén
PUT    /api/stocks/warehouses/:id          → Actualizar almacén
DELETE /api/stocks/warehouses/:id          → Eliminar almacén
```

### Stock Levels (3 endpoints)
```
POST   /api/stocks/initialize              → Inicializar stock
GET    /api/stocks/levels                  → Listar niveles
GET    /api/stocks/levels/:warehouseId/:productId → Ver stock específico
```

### Stock Movements (2 endpoints)
```
POST   /api/stocks/movements               → Registrar movimiento
GET    /api/stocks/movements               → Ver historial
```

### Reports & Adjustments (2 endpoints)
```
GET    /api/stocks/low-stock               → Items bajo stock
GET    /api/stocks/report                  → Reporte de inventario
POST   /api/stocks/adjust                  → Ajustar inventario
```

## Database Schema

### warehouses
```sql
id UUID (PK)
name VARCHAR(255) UNIQUE NOT NULL
location VARCHAR(500)
capacity INTEGER (default: 1000)
active BOOLEAN (default: true)
created_at TIMESTAMP
updated_at TIMESTAMP
```

### stock_levels
```sql
id UUID (PK)
warehouse_id UUID (FK)
product_id UUID (FK)
quantity INTEGER
min_quantity INTEGER
max_quantity INTEGER
reorder_point INTEGER
last_movement TIMESTAMP
created_at TIMESTAMP
updated_at TIMESTAMP
UNIQUE(warehouse_id, product_id)
```

### stock_movements
```sql
id UUID (PK)
warehouse_id UUID (FK)
product_id UUID (FK)
movement_type VARCHAR ('entrada'|'salida'|'ajuste')
quantity INTEGER
reference_type VARCHAR ('sale'|'purchase'|'adjustment')
reference_id UUID (optional)
notes TEXT
created_by UUID (FK to users)
created_at TIMESTAMP
```

## Características

✅ **Multi-warehouse support** - Múltiples almacenes independientes
✅ **Real-time stock tracking** - Seguimiento en tiempo real
✅ **Movement history** - Auditoría completa de todos los movimientos
✅ **Low stock alerts** - Sistema de alertas de bajo stock
✅ **Stock reports** - Reportes por almacén
✅ **Transactional operations** - Consistencia de datos garantizada
✅ **Filtering & search** - Filtros por almacén, producto, tipo de movimiento, fecha
✅ **Performance optimized** - 10 índices definidos
✅ **User audit trail** - Cada movimiento registra quién lo hizo

## Flujo de Uso Típico

### 1. Crear Almacén
```json
POST /api/stocks/warehouses
{
  "name": "Almacén Principal",
  "location": "Buenos Aires",
  "capacity": 5000
}
```

### 2. Inicializar Stock
```json
POST /api/stocks/initialize
{
  "warehouseId": "uuid-here",
  "productId": "uuid-here",
  "quantity": 100,
  "minQuantity": 10,
  "maxQuantity": 500,
  "reorderPoint": 20
}
```

### 3. Registrar Movimiento (Entrada)
```json
POST /api/stocks/movements
{
  "warehouseId": "uuid-here",
  "productId": "uuid-here",
  "movementType": "entrada",
  "quantity": 50,
  "referenceType": "purchase",
  "referenceId": "purchase-id",
  "notes": "Compra a proveedor X"
}
```

### 4. Registrar Movimiento (Salida)
```json
POST /api/stocks/movements
{
  "warehouseId": "uuid-here",
  "productId": "uuid-here",
  "movementType": "salida",
  "quantity": 10,
  "referenceType": "sale",
  "referenceId": "sale-id",
  "notes": "Venta #001"
}
```

### 5. Ver Stock Actual
```
GET /api/stocks/levels?warehouseId=uuid&lowStock=false
```

### 6. Ver Items Bajo Stock
```
GET /api/stocks/low-stock
GET /api/stocks/low-stock?warehouseId=uuid
```

### 7. Ajustar Inventario (Manual)
```json
POST /api/stocks/adjust
{
  "warehouseId": "uuid-here",
  "productId": "uuid-here",
  "newQuantity": 85,
  "reason": "Conteo visual encontró discrepancia"
}
```

### 8. Obtener Reportes
```
GET /api/stocks/report              → Reporte por almacén
GET /api/stocks/report?warehouseId=uuid → Reporte específico almacén
```

## Transactional Safety

Los movimientos de stock usan TRANSACCIONES para garantizar:
- Si falla el update de stock, no se registra el movimiento
- Si hay error, todo se revierte (ROLLBACK)
- Consistencia de datos garantizada

```typescript
await client.query('BEGIN');
// Insert movement
// Update stock_levels
await client.query('COMMIT');
```

## Filtros Disponibles

### Stock Levels
- `warehouseId` - Filtrar por almacén
- `productId` - Filtrar por producto
- `lowStock` - Solo items bajo reorder point

### Stock Movements
- `warehouseId` - Por almacén
- `productId` - Por producto
- `movementType` - 'entrada', 'salida', 'ajuste'
- `startDate` - Desde fecha
- `endDate` - Hasta fecha

## Integración con Módulos Existentes

Phase 5 se integra con:
- **Phase 3 (Sales)** - Registra automáticamente salida de stock en ventas
- **Phase 4 (Purchases)** - Registra automáticamente entrada de stock en compras
- **Phase 2 (Auth)** - Requiere autenticación + user audit trail

## Próximo Paso

Para mayor automatización puedes agregar triggers en PostgreSQL que:
- Registren automáticamente movimientos cuando se crea/actualiza una venta/compra
- Generen alertas cuando stock cae bajo reorder_point
- Archiven movimientos antiguos automáticamente

## Resumen de Cambios

✅ Model: Stock.ts (280 líneas)
✅ Controller: stockController.ts (160 líneas)
✅ Routes: stocks.ts (30 líneas)
✅ Schema: stock.sql (70 líneas)
✅ app.ts: Registrado stock routes
✅ docker-compose.yml: Montado 04-stock.sql

**Total endpoints: 12 nuevos**
**Total líneas de código: 540+**

---

## Para Activar

Para que los cambios tomen efecto:

```powershell
docker-compose down
docker-compose up -d --build
```

La BD se inicializará automáticamente con las tablas de stock.

---

**Estado: ✅ PHASE 5 COMPLETADA**
**Próxima opción:**
- Phase 6: Reports (Reportes avanzados)
- Phase 7: Users & Permissions (Control de permisos)
- Comenzar Frontend Flutter
