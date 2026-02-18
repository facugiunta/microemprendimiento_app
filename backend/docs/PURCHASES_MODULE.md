# Módulo de Compras - Documentación Técnica

## Descripción General
El módulo de compras proporciona todas las funcionalidades para gestionar operaciones de compra, incluyendo:
- Creación y gestión de compras a proveedores
- Seguimiento de detalles de línea de compra
- Gestión de proveedores
- Reportes diarios y por rango de fechas
- Control de estado de recepción

## Base de Datos

### Esquema (backend/db/purchases.sql)

#### Tabla: suppliers
```sql
- id: UUID (PRIMARY KEY)
- nombre: TEXT (NOT NULL)
- email: TEXT (UNIQUE)
- telefono: TEXT
- contacto_persona: TEXT
- direccion: TEXT
- ciudad: TEXT
- codigo_postal: TEXT
- pais: TEXT
- estado: TEXT ('activo' | 'inactivo')
- plazo_pago: INTEGER (DEFAULT 30)
- notas: TEXT
- creado_en: TIMESTAMP
- actualizado_en: TIMESTAMP
```

#### Tabla: purchases
```sql
- id: UUID (PRIMARY KEY)
- numero_compra: TEXT (UNIQUE)
- fecha: TIMESTAMP
- proveedor_id: UUID (FOREIGN KEY → suppliers)
- usuario_id: UUID (FOREIGN KEY → users)
- total: DECIMAL(10,2)
- impuesto: DECIMAL(10,2) (DEFAULT 0)
- estado: TEXT ('pendiente' | 'recibida' | 'cancelada')
- fecha_pago: TIMESTAMP
- metodo_pago: TEXT
- notas: TEXT
- creado_en: TIMESTAMP
- actualizado_en: TIMESTAMP
```

#### Tabla: purchase_details
```sql
- id: UUID (PRIMARY KEY)
- compra_id: UUID (FOREIGN KEY → purchases)
- producto_id: UUID (FOREIGN KEY → products)
- cantidad: INTEGER
- precio_unitario: DECIMAL(10,2)
- subtotal: DECIMAL(10,2)
- creado_en: TIMESTAMP
```

## Modelos TypeScript

### Supplier Model (src/models/Supplier.ts)
**Funciones:**
- `createSupplier(data)` - Crear nuevo proveedor
- `findSupplierById(id)` - Buscar proveedor por ID
- `getAllSuppliers(activeOnly)` - Obtener proveedores
- `updateSupplier(id, data)` - Actualizar proveedor
- `deleteSupplier(id)` - Eliminar proveedor

### Purchase Model (src/models/Purchase.ts)
**Funciones:**
- `createPurchase(data, detalles)` - Crear compra con detalles (transacción)
- `findPurchaseById(id)` - Obtener compra con detalles
- `getAllPurchases()` - Obtener todas las compras
- `getPurchasesBySupplier(proveedor_id)` - Compras de un proveedor
- `getPurchasesByDate(startDate, endDate)` - Compras por rango de fechas
- `updatePurchase(id, data)` - Actualizar compra
- `deletePurchase(id)` - Eliminar compra
- `getDailyPurchasesReport(date)` - Reporte diario

## API Endpoints

### Autenticación (requerida para todas las rutas)
Todas las rutas requieren token JWT en header: `Authorization: Bearer {token}`

### Proveedores - `/api/suppliers`
```
POST   /api/suppliers
├─ Body: { nombre, email?, telefono?, contacto_persona?, direccion?, ciudad?, codigo_postal?, pais?, plazo_pago?, notas? }
└─ Response: { id, nombre, email, telefono, ... }

GET    /api/suppliers?includeInactive=true
└─ Response: [{ id, nombre, email, telefono, ... }]

GET    /api/suppliers/:id
└─ Response: { id, nombre, email, telefono, ... }

PUT    /api/suppliers/:id
├─ Body: { nombre?, email?, telefono?, contacto_persona?, ... }
└─ Response: { id, nombre, email, ... }

DELETE /api/suppliers/:id
└─ Response: { message: 'Proveedor eliminado' }
```

### Compras - `/api/purchases`
```
POST   /api/purchases
├─ Body: {
│   proveedor_id: UUID,
│   usuario_id: UUID,
│   impuesto?: number,
│   metodo_pago?: string,
│   notas?: string,
│   detalles: [
│     { producto_id: UUID, cantidad: number, precio_unitario: number },
│     ...
│   ]
│ }
└─ Response: {
    id, numero_compra, fecha, proveedor_id, usuario_id,
    total, impuesto, estado, detalles: [...]
  }

GET    /api/purchases
└─ Response: [{ id, numero_compra, fecha, total, proveedor_id, detalles: [...], ... }]

GET    /api/purchases/:id
└─ Response: { id, numero_compra, fecha, total, proveedor_id, detalles: [...], ... }

GET    /api/purchases/proveedor/:proveedor_id
└─ Response: [{ id, numero_compra, fecha, total, ... }]

GET    /api/purchases/reporte/diario?date=2026-02-17
└─ Response: {
    fecha: date,
    total_compras: number,
    total_proveedores: number,
    gasto_total: number,
    promedio_compra: number,
    compras_recibidas: number,
    compras_pendientes: number
  }

GET    /api/purchases/rango-fechas?startDate=2026-01-01&endDate=2026-02-17
└─ Response: [{ id, numero_compra, fecha, total, ... }]

PUT    /api/purchases/:id
├─ Body: { estado?, impuesto?, total?, fecha_pago?, metodo_pago?, notas? }
└─ Response: { id, numero_compra, estado, total, ... }

DELETE /api/purchases/:id
└─ Response: { message: 'Compra eliminada' }
```

## Controladores

### supplierController.ts
Maneja todas las operaciones CRUD para proveedores con validación de entrada y manejo de errores.

### purchaseController.ts
Operaciones de compra incluyendo:
- Creación automática de números de compra
- Cálculo de totales con impuestos
- Reportes diarios y por rango de fechas
- Gestión transaccional (compra + detalles)
- Control de estado (pendiente, recibida, cancelada)

## Rutas

### suppliers.ts
Define endpoints `/api/suppliers` con protección de autenticación.

### purchases.ts
Define endpoints `/api/purchases` incluyendo reportes y filtrados por proveedor/fechas.

## Variables de Entorno Requeridas

```env
NODE_ENV=development
PORT=3000
DATABASE_URL=postgresql://admin:Admin123!@localhost:5432/microemprendimiento
JWT_ACCESS_SECRET=your_access_secret_here
JWT_REFRESH_SECRET=your_refresh_secret_here
```

## Instalación y Prueba

### 1. Inicializar base de datos
```bash
# Ejecutar scripts SQL
psql $DATABASE_URL -f db/init.sql
psql $DATABASE_URL -f db/sales.sql
psql $DATABASE_URL -f db/purchases.sql
```

### 2. Iniciar backend
```bash
cd backend
npm run dev
```

### 3. Ejemplos de uso (con cURL)

**Crear proveedor:**
```bash
curl -X POST http://localhost:3000/api/suppliers \
  -H "Authorization: Bearer {YOUR_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "nombre": "Distribuidora ABC",
    "email": "contacto@distribuida.com",
    "telefono": "555-5678",
    "contacto_persona": "Juan García",
    "ciudad": "Barcelona",
    "plazo_pago": 45
  }'
```

**Crear compra:**
```bash
curl -X POST http://localhost:3000/api/purchases \
  -H "Authorization: Bearer {YOUR_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "proveedor_id": "SUPPLIER_UUID",
    "usuario_id": "USER_UUID",
    "impuesto": 150,
    "metodo_pago": "transferencia",
    "notas": "Compra de inventario",
    "detalles": [
      {
        "producto_id": "PROD_UUID",
        "cantidad": 50,
        "precio_unitario": 150
      }
    ]
  }'
```

**Obtener reporte diario de compras:**
```bash
curl -X GET "http://localhost:3000/api/purchases/reporte/diario?date=2026-02-17" \
  -H "Authorization: Bearer {YOUR_TOKEN}"
```

**Actualizar estado de compra a recibida:**
```bash
curl -X PUT http://localhost:3000/api/purchases/PURCHASE_UUID \
  -H "Authorization: Bearer {YOUR_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "estado": "recibida",
    "fecha_pago": "2026-02-20"
  }'
```

## Características de Seguridad

- ✅ Autenticación JWT requerida para todas las rutas
- ✅ Validación de entrada en todos los controladores
- ✅ Transacciones de base de datos para operaciones críticas
- ✅ Borrado en cascada para mantener integridad referencial
- ✅ Índices de base de datos para optimización de queries
- ✅ Manejo robusto de errores

## Diferencias con Módulo de Ventas

| Aspecto | Ventas | Compras |
|---------|--------|---------|
| Entidad relacionada | Clientes | Proveedores |
| Número | VTA-{timestamp} | CMP-{timestamp} |
| Estados | pendiente, completada, cancelada | pendiente, recibida, cancelada |
| Descuentos | Sí | No |
| Impuestos | Se suman | Se suman |
| Reportes | Por cliente | Por proveedor |
| Plazo | N/A | Plazo de pago (por proveedor) |

## Próximos Pasos

- [ ] Módulo de Stock y Movimientos
- [ ] Módulo de Inversiones
- [ ] Sincronización de stock tras compra/venta
- [ ] Módulo de Reportes Avanzados
- [ ] Autenticación Frontend (Flutter)
- [ ] Sincronización Offline (SQLite)
