# Módulo de Ventas - Documentación Técnica

## Descripción General
El módulo de ventas proporciona todas las funcionalidades para gestionar operaciones de venta, incluyendo:
- Creación y gestión de ventas
- Seguimiento de detalles de línea de venta
- Reportes diarios y por rango de fechas
- Gestión de clientes
- Gestión de productos/inventario

## Base de Datos

### Esquema (backend/db/sales.sql)

#### Tabla: customers
```sql
- id: UUID (PRIMARY KEY)
- nombre: TEXT (NOT NULL)
- email: TEXT (UNIQUE)
- telefono: TEXT
- direccion: TEXT
- ciudad: TEXT
- codigo_postal: TEXT
- estado: TEXT ('activo' | 'inactivo')
- notas: TEXT
- creado_en: TIMESTAMP
- actualizado_en: TIMESTAMP
```

#### Tabla: products
```sql
- id: UUID (PRIMARY KEY)
- codigo: TEXT (UNIQUE, NOT NULL)
- nombre: TEXT (NOT NULL)
- descripcion: TEXT
- categoria: TEXT
- precio_costo: DECIMAL(10,2) (NOT NULL)
- precio_venta: DECIMAL(10,2) (NOT NULL)
- stock_actual: INTEGER (DEFAULT 0)
- stock_minimo: INTEGER (DEFAULT 0)
- unidad_medida: TEXT (DEFAULT 'unidad')
- imagen: TEXT
- activo: BOOLEAN (DEFAULT true)
- creado_en: TIMESTAMP
- actualizado_en: TIMESTAMP
```

#### Tabla: sales
```sql
- id: UUID (PRIMARY KEY)
- numero_venta: TEXT (UNIQUE)
- fecha: TIMESTAMP
- cliente_id: UUID (FOREIGN KEY → customers)
- usuario_id: UUID (FOREIGN KEY → users)
- total: DECIMAL(10,2)
- descuento: DECIMAL(10,2) (DEFAULT 0)
- impuesto: DECIMAL(10,2) (DEFAULT 0)
- estado: TEXT ('pendiente' | 'completada' | 'cancelada')
- metodo_pago: TEXT
- notas: TEXT
- creado_en: TIMESTAMP
- actualizado_en: TIMESTAMP
```

#### Tabla: sale_details
```sql
- id: UUID (PRIMARY KEY)
- venta_id: UUID (FOREIGN KEY → sales)
- producto_id: UUID (FOREIGN KEY → products)
- cantidad: INTEGER
- precio_unitario: DECIMAL(10,2)
- subtotal: DECIMAL(10,2)
- creado_en: TIMESTAMP
```

## Modelos TypeScript

### Customer Model (src/models/Customer.ts)
**Funciones:**
- `createCustomer(data)` - Crear nuevo cliente
- `findCustomerById(id)` - Buscar cliente по ID
- `getAllCustomers()` - Obtener todos los clientes
- `updateCustomer(id, data)` - Actualizar cliente
- `deleteCustomer(id)` - Eliminar cliente

### Product Model (src/models/Product.ts)
**Funciones:**
- `createProduct(data)` - Crear nuevo producto
- `findProductById(id)` - Buscar producto por ID
- `findProductByCodigo(codigo)` - Buscar por código
- `getAllProducts(activeOnly)` - Obtener productos
- `getLowStockProducts()` - Productos con stock bajo
- `updateProduct(id, data)` - Actualizar producto
- `deleteProduct(id)` - Eliminar producto

### Sale Model (src/models/Sale.ts)
**Funciones:**
- `createSale(data, detalles)` - Crear venta con detalles (transacción)
- `findSaleById(id)` - Obtener venta con detalles
- `getAllSales()` - Obtener todas las ventas
- `getSalesByCustomer(cliente_id)` - Ventas de un cliente
- `getSalesByDate(startDate, endDate)` - Ventas por rango de fechas
- `updateSale(id, data)` - Actualizar venta
- `deleteSale(id)` - Eliminar venta
- `getDailySalesReport(date)` - Reporte diario

## API Endpoints

### Autenticación (requerida para todas las rutas)
Todas las rutas requieren token JWT en header: `Authorization: Bearer {token}`

### Clientes - `/api/customers`
```
POST   /api/customers
├─ Body: { nombre, email?, telefono?, direccion?, ciudad?, codigo_postal?, notas? }
└─ Response: { id, nombre, email, ... }

GET    /api/customers
└─ Response: [{ id, nombre, email, ... }]

GET    /api/customers/:id
└─ Response: { id, nombre, email, ... }

PUT    /api/customers/:id
├─ Body: { nombre?, email?, telefono?, ... }
└─ Response: { id, nombre, email, ... }

DELETE /api/customers/:id
└─ Response: { message: 'Cliente eliminado' }
```

### Productos - `/api/products`
```
POST   /api/products
├─ Body: { codigo, nombre, precio_costo, precio_venta, stock_actual?, stock_minimo?, unidad_medida?, categoria?, descripcion? }
└─ Response: { id, codigo, nombre, precio_venta, ... }

GET    /api/products?includeInactive=true
└─ Response: [{ id, codigo, nombre, ... }]

GET    /api/products/bajo-stock
└─ Response: [{ id, codigo, nombre, stock_actual, stock_minimo, ... }]

GET    /api/products/codigo/:codigo
└─ Response: { id, codigo, nombre, precio_venta, stock_actual, ... }

GET    /api/products/:id
└─ Response: { id, codigo, nombre, ... }

PUT    /api/products/:id
├─ Body: { codigo?, nombre?, precio_costo?, precio_venta?, stock_actual?, ... }
└─ Response: { id, codigo, nombre, ... }

DELETE /api/products/:id
└─ Response: { message: 'Producto eliminado' }
```

### Ventas - `/api/sales`
```
POST   /api/sales
├─ Body: {
│   cliente_id: UUID,
│   usuario_id: UUID,
│   descuento?: number,
│   impuesto?: number,
│   metodo_pago?: string,
│   notas?: string,
│   detalles: [
│     { producto_id: UUID, cantidad: number, precio_unitario: number },
│     ...
│   ]
│ }
└─ Response: {
    id, numero_venta, fecha, cliente_id, usuario_id,
    total, descuento, impuesto, estado, detalles: [...]
  }

GET    /api/sales
└─ Response: [{ id, numero_venta, fecha, total, cliente_id, detalles: [...], ... }]

GET    /api/sales/:id
└─ Response: { id, numero_venta, fecha, total, cliente_id, detalles: [...], ... }

GET    /api/sales/cliente/:cliente_id
└─ Response: [{ id, numero_venta, fecha, total, ... }]

GET    /api/sales/reporte/diario?date=2026-02-17
└─ Response: {
    fecha: date,
    total_ventas: number,
    total_clientes: number,
    ingresos_totales: number,
    promedio_venta: number,
    ventas_completadas: number,
    ventas_pendientes: number
  }

GET    /api/sales/rango-fechas?startDate=2026-01-01&endDate=2026-02-17
└─ Response: [{ id, numero_venta, fecha, total, ... }]

PUT    /api/sales/:id
├─ Body: { estado?, descuento?, impuesto?, total?, metodo_pago?, notas? }
└─ Response: { id, numero_venta, estado, total, ... }

DELETE /api/sales/:id
└─ Response: { message: 'Venta eliminada' }
```

## Controladores

### customerController.ts
Maneja todas las operaciones CRUD para clientes con validación de entrada y manejo de errores.

### productController.ts
Gestiona productos incluyendo búsqueda por código, alertas de stock bajo y control de disponibilidad.

### salesController.ts
Operaciones de venta incluyendo:
- Creación automática de números de venta
- Cálculo de totales con descuentos e impuestos
- Reportes diarios y por rango de fechas
- Gestión transaccional (venta + detalles)

## Rutas

### customers.ts
Define endpoints `/api/customers` con protección de autenticación.

### products.ts
Define endpoints `/api/products` incluyendo búsqueda por código y alertas de stock.

### sales.ts
Define endpoints `/api/sales` con reportes y filtrados por cliente/fechas.

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
# Ejecutar ambos scripts SQL
psql $DATABASE_URL -f db/init.sql
psql $DATABASE_URL -f db/sales.sql
```

### 2. Iniciar backend
```bash
cd backend
npm run dev
```

### 3. Ejemplos de uso (con cURL)

**Registrar usuario:**
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@test.com",
    "password": "SecurePass123!",
    "nombre": "Juan Pérez"
  }'
```

**Crear cliente:**
```bash
curl -X POST http://localhost:3000/api/customers \
  -H "Authorization: Bearer {YOUR_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "nombre": "Tienda Local",
    "email": "tienda@example.com",
    "telefono": "555-1234",
    "ciudad": "Madrid"
  }'
```

**Crear producto:**
```bash
curl -X POST http://localhost:3000/api/products \
  -H "Authorization: Bearer {YOUR_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "codigo": "PROD001",
    "nombre": "Laptop",
    "precio_costo": 500,
    "precio_venta": 800,
    "stock_actual": 10,
    "stock_minimo": 2,
    "categoria": "Electrónica"
  }'
```

**Crear venta:**
```bash
curl -X POST http://localhost:3000/api/sales \
  -H "Authorization: Bearer {YOUR_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "cliente_id": "CLIENT_UUID",
    "usuario_id": "USER_UUID",
    "descuento": 50,
    "impuesto": 100,
    "metodo_pago": "efectivo",
    "notas": "Primera venta",
    "detalles": [
      {
        "producto_id": "PROD_UUID",
        "cantidad": 2,
        "precio_unitario": 800
      }
    ]
  }'
```

**Obtener reporte diario:**
```bash
curl -X GET "http://localhost:3000/api/sales/reporte/diario?date=2026-02-17" \
  -H "Authorization: Bearer {YOUR_TOKEN}"
```

## Características de Seguridad

- ✅ Autenticación JWT requerida para todas las rutas
- ✅ Validación de entrada en todos los controladores
- ✅ Transacciones de base de datos para operaciones críticas
- ✅ Borrado en cascada para mantener integridad referencial
- ✅ Índices de base de datos para optimización de queries
- ✅ Manejo robusto de errores

## Próximos Pasos

- [ ] Módulo de Compras (similar a Ventas)
- [ ] Gestión de Stock y Movimientos
- [ ] Módulo de Inversiones
- [ ] Módulo de Reportes Avanzados
- [ ] Autenticación Frontend (Flutter)
- [ ] Sincronización Offline (SQLite)
