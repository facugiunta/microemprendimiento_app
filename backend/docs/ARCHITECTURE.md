# 🎯 ARQUITECTURA DEL MÓDULO DE VENTAS

## Diagrama de Arquitectura

```
┌─────────────────────────────────────────────────────────────────┐
│                     API REST EXPRESS.JS                         │
│                      (Puerto 3000)                              │
└────────────┬──────────────────────────────────────┬─────────────┘
             │                                      │
      ┌──────▼─────────┐                   ┌───────▼──────────┐
      │  Routes Layer  │                   │  Auth Middleware │
      ├────────────────┤                   └───────┬──────────┘
      │ auth.ts        │                           │
      │ customers.ts   │◄──────────────────────────┘
      │ products.ts    │      JWT Token
      │ sales.ts       │      Validation
      └────────┬───────┘
               │
      ┌────────▼──────────────────┐
      │  Controllers Layer        │
      ├──────────────────────────┤
      │ authController.ts        │
      │ customerController.ts    │
      │ productController.ts     │
      │ salesController.ts       │
      └────────┬─────────────────┘
               │
      ┌────────▼──────────────────┐
      │  Models Layer            │
      ├──────────────────────────┤
      │ User.ts                  │
      │ Customer.ts              │
      │ Product.ts               │
      │ Sale.ts                  │
      └────────┬─────────────────┘
               │
      ┌────────▼──────────────────────────┐
      │  PostgreSQL Database              │
      ├───────────────────────────────────┤
      │ ┌─────────────┐  ┌──────────────┐ │
      │ │   users     │  │  customers   │ │
      │ └─────────────┘  └──────────────┘ │
      │ ┌─────────────┐  ┌──────────────┐ │
      │ │  products   │  │    sales     │ │
      │ └─────────────┘  └──────────────┘ │
      │ ┌─────────────────────────────┐   │
      │ │      sale_details           │   │
      │ └─────────────────────────────┘   │
      └───────────────────────────────────┘
```

## Flujo de Datos: Crear Venta

```
CLIENT                 API                CONTROLLER           MODEL            DATABASE
  │                    │                      │                   │                │
  ├─ POST /sales ─────►│                      │                   │                │
  │   + detalles       │                      │                   │                │
  │                    ├─ authenticateToken()─┤                   │                │
  │                    │   (JWT verify)       │                   │                │
  │                    │◄────────┤            │                   │                │
  │                    ├─────────────────────►│                   │                │
  │                    │ createSale(req,res)  │                   │                │
  │                    │                      ├─ createSale()────►│                │
  │                    │                      │   (transact.)     │                │
  │                    │                      │                   ├─ BEGIN ───────►│
  │                    │                      │                   │                │
  │                    │                      │                   ├─ INSERT sale ─►│
  │                    │                      │                   │                │
  │                    │                      │                   ├─ INSERT ...   │
  │                    │                      │                   │   details ────►│
  │                    │                      │                   │                │
  │                    │                      │                   ├─ COMMIT ──────►│
  │                    │                      │◄────────────────┤                │
  │                    │◄──────────────────────┤                   │                │
  │◄─────── Sale JSON─────────────────────────┤                   │                │
  │   (201 CREATED)                           │                   │                │
```

## Mapeo de Endpoints a Funciones

### CUSTOMERS
```
POST   /api/customers           → customerController.createCustomer
GET    /api/customers           → customerController.getCustomers
GET    /api/customers/:id       → customerController.getCustomerById
PUT    /api/customers/:id       → customerController.updateCustomer
DELETE /api/customers/:id       → customerController.deleteCustomer
```

### PRODUCTS
```
POST   /api/products            → productController.createProduct
GET    /api/products            → productController.getProducts
GET    /api/products/bajo-stock → productController.getLowStockProducts
GET    /api/products/codigo/:   → productController.getProductByCode
GET    /api/products/:id        → productController.getProductById
PUT    /api/products/:id        → productController.updateProduct
DELETE /api/products/:id        → productController.deleteProduct
```

### SALES
```
POST   /api/sales               → salesController.createSale
GET    /api/sales               → salesController.getSales
GET    /api/sales/:id           → salesController.getSaleById
GET    /api/sales/cliente/:id   → salesController.getSalesByCustomer
GET    /api/sales/reporte/diario→ salesController.getDailySalesReport
GET    /api/sales/rango-fechas  → salesController.getSalesByDateRange
PUT    /api/sales/:id           → salesController.updateSale
DELETE /api/sales/:id           → salesController.deleteSale
```

## Estructura de Carpetas

```
backend/
├── dist/                       # TypeScript compilado
├── db/
│   ├── init.sql               # Schema usuarios
│   └── sales.sql              # Schema ventas
├── src/
│   ├── app.ts                 # Express app
│   ├── controllers/           # Lógica de negocios
│   │   ├── authController.ts
│   │   ├── customerController.ts
│   │   ├── productController.ts
│   │   └── salesController.ts
│   ├── middleware/
│   │   └── authMiddleware.ts  # JWT validation
│   ├── models/                # Data access layer
│   │   ├── User.ts
│   │   ├── Customer.ts
│   │   ├── Product.ts
│   │   └── Sale.ts
│   ├── routes/                # Route definitions
│   │   ├── auth.ts
│   │   ├── customers.ts
│   │   ├── products.ts
│   │   └── sales.ts
│   └── utils/
│       ├── db.ts              # PostgreSQL pool
│       └── jwt.ts             # JWT helpers
├── app.js                      # Entry point
├── package.json
└── tsconfig.json
```

## Diagrama ER - Base de Datos

```
┌──────────────┐
│    USERS     │
├──────────────┤
│ id (UUID) PK │
│ email        │
│ password     │
│ nombre       │
│ rol          │
│ estado       │
└──────┬───────┘
       │
       │ 1 : N
       │
       ▼
┌──────────────────┐         ┌──────────────────┐
│   SALES          │────────►│   CUSTOMERS      │
├──────────────────┤  M : 1  ├──────────────────┤
│ id (UUID) PK     │         │ id (UUID) PK     │
│ numero_venta     │         │ nombre           │
│ fecha            │         │ email            │
│ cliente_id FK    │         │ telefono         │
│ usuario_id FK    │         │ direccion        │
│ total            │         │ ciudad           │
│ descuento        │         │ estado           │
│ impuesto         │         └──────────────────┘
│ estado           │
│ metodo_pago      │
└────────┬──────────┘
         │
         │ 1 : N
         │
         ▼
┌────────────────────┐      ┌──────────────────┐
│  SALE_DETAILS      │      │    PRODUCTS      │
├────────────────────┤      ├──────────────────┤
│ id (UUID) PK       │◄─────│ id (UUID) PK     │
│ venta_id FK        │ M:1  │ codigo           │
│ producto_id FK◌────┼──────┤ nombre           │
│ cantidad           │      │ precio_costo     │
│ precio_unitario    │      │ precio_venta     │
│ subtotal           │      │ stock_actual     │
└────────────────────┘      │ stock_minimo     │
                            │ categoria        │
                            │ activo           │
                            └──────────────────┘
```

## Secuencia de Transacciones - Crear Venta

```
1. Cliente envía POST /api/sales con:
   - cliente_id
   - usuario_id
   - descuento (opcional)
   - impuesto (opcional)
   - metodo_pago
   - detalles: []

2. /routes/sales.ts valida token JWT

3. /controllers/salesController.createSale():
   - Valida datos
   - Calcula subtotales de líneas
   - Suma total = subtotales - descuento + impuesto

4. /models/Sale.createSale():
   - BEGIN transacción
   - INSERT sales (genera numero_venta único)
   - FOR EACH detalle: INSERT sale_details
   - COMMIT
   - Retorna Sale completa con detalles

5. Response: 201 CREATED {sale data + detalles}
```

## Flujo de Autenticación

```
1. Usuario se registra/login
2. Backend emite:
   - accessToken (JWT, 15 min) ← para requests
   - refreshToken (JWT, 7 dias) ← para renovar

3. Cliente incluye en headers:
   Authorization: Bearer {accessToken}

4. Middleware authMiddleware.ts:
   - Extrae token del header
   - Verifica con JWT_ACCESS_SECRET
   - Valida expiración
   - Si válido: siguiente request
   - Si inválido: 403 Forbidden

5. Cuando expira accessToken:
   - Cliente usa refreshToken en POST /api/auth/refresh
   - Backend retorna nuevo accessToken
```

## Control de Seguridad

```
┌─────────────┐
│ JWT Token   │
├─────────────┤
│ Header: {   │
│   alg:HS256 │
│ }           │
│             │
│ Payload: {  │
│   id:       │ ◄──── User UUID
│   email:    │ ◄──── Email
│   rol:      │ ◄──── Role
│   iat:      │ ◄──── Issued at
│   exp:      │ ◄──── Expiration
│ }           │
│             │
│ Signature:  │ ◄──── Signed with JWT_ACCESS_SECRET
│   HMACSHA.. │
└─────────────┘
```

## Niveles de Acceso

```
┌─────────────────────────────────────────┐
│ TODOS (sin autenticación)               │
├─────────────────────────────────────────┤
│ - GET /api/health                       │
│ - POST /api/auth/register               │
│ - POST /api/auth/login                  │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ AUTENTICADOS (valid JWT token)          │
├─────────────────────────────────────────┤
│ - GET /api/auth/me                      │
│ - POST /api/customers                   │
│ - GET /api/products                     │
│ - POST /api/sales                       │
│ - GET /api/sales/reporte/diario         │
│ - ... (21 endpoints más)                │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ AUTORIZACIÓN POR ROL (futuro)           │
├─────────────────────────────────────────┤
│ admin    → todos los endpoints          │
│ gerente  → lectura + reportes           │
│ vendedor → crear y ver sus ventas       │
└─────────────────────────────────────────┘
```

## Flujo de Error Handling

```
Request
  │
  ├─ Validación de entrada
  │  ├─ 400 Bad Request (falta dato)
  │  └─ 409 Conflict (duplicado)
  │
  ├─ Autenticación
  │  ├─ 401 Unauthorized (sin token)
  │  └─ 403 Forbidden (token inválido)
  │
  ├─ Búsqueda de recurso
  │  └─ 404 Not Found
  │
  └─ Error de BD
     └─ 500 Internal Server Error

Response con error:
{ "error": "Descripción del error" }
```

---

**Nota:** Esta arquitectura permite escalar fácilmente a nuevos módulos (Compras, Stock, Inversiones) siguiendo el mismo patrón: Routes → Controllers → Models → DB
