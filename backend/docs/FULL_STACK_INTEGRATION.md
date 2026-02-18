# Full Stack Integration Guide

## Complete System Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                   Flutter Mobile App                         │
│         (iOS/Android with Provider State Management)         │
└────────────────────────┬─────────────────────────────────────┘
                         │
                    HTTP REST API
              (Port 3000, JWT Bearer Tokens)
                         │
┌────────────────────────▼─────────────────────────────────────┐
│              Express.js Backend Server                        │
│         (TypeScript, Strict Mode, 90+ Endpoints)             │
│  - Authentication (JWT, Refresh Tokens)                      │
│  - Customers, Products, Sales, Purchases                     │
│  - Stock Management, Reports, Permissions                    │
└────────────────────────┬─────────────────────────────────────┘
                         │
┌────────────────────────▼─────────────────────────────────────┐
│         PostgreSQL 15 Database (Docker)                       │
│  - 15+ Tables with Relationships                             │
│  - 30+ Performance Indexes                                   │
│  - Transaction Support                                        │
└──────────────────────────────────────────────────────────────┘
```

## Getting Started - Full Stack Setup

### Phase 1: Backend Preparation

**Prerequisites**
- Docker & Docker Compose installed
- Node.js 18+ (if running without Docker)
- PostgreSQL 15 (included in Docker)

**Steps**

1. **Navigate to project root**
   ```bash
   cd c:\Users\Mati\Documents\microemprendimiento_app
   ```

2. **Start Docker containers**
   ```bash
   docker-compose up -d
   ```

   This starts:
   - PostgreSQL database (port 5432)
   - Redis cache (port 6379)
   - PgAdmin web interface (port 5050)
   - Express backend (port 3000)

3. **Verify backend is running**
   ```bash
   curl http://localhost:3000/api/auth/me
   # Should return 401 (unauthenticated) - that's expected
   ```

4. **Check Docker status**
   ```bash
   docker-compose ps
   # All 4 services should show "Up"
   ```

### Phase 2: Database Initialization

1. **Connect to PgAdmin**
   - URL: http://localhost:5050
   - Email: `admin@microemprendimiento.com`
   - Password: `admin`

2. **Verify database contents**
   - Right-click "Servers" → "Register" → "Server"
   - Host: `postgres` (internal Docker DNS)
   - Username: `microemprendimiento_user`
   - Password: `secure_password_123`
   - Database: `microemprendimiento_db`

3. **Check tables exist**
   All these tables should be present:
   - users
   - customers
   - products
   - sales
   - sale_details
   - purchases
   - purchase_details
   - suppliers
   - warehouses
   - stock_levels
   - stock_movements
   - roles
   - permissions
   - role_permissions
   - user_roles

### Phase 3: Frontend Setup

**Prerequisites**
- Flutter SDK 3.0+ installed
- Android Studio / Xcode (for devices/emulators)
- Supported platforms: iOS, Android, Windows, macOS, Web

**Steps**

1. **Navigate to mobile app directory**
   ```bash
   cd mobile_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Verify Flutter setup**
   ```bash
   flutter doctor
   # Check for any missing dependencies
   ```

4. **Run the app**

   **Android/iOS (requires emulator/device)**
   ```bash
   flutter run
   ```

   **Web (browser)**
   ```bash
   flutter run -d chrome
   ```

   **Windows (desktop)**
   ```bash
   flutter run -d windows
   ```

5. **Login credentials**
   - Email: `admin@microemprendimiento.com`
   - Password: `password`

## API Endpoint Categories (90+ Endpoints)

### Authentication (5 endpoints)
```
POST   /api/auth/register              Register new user
POST   /api/auth/login                 Login (returns JWT tokens)
POST   /api/auth/refresh               Refresh access token
GET    /api/auth/me                    Get current user
POST   /api/auth/logout                Logout
```

### Customers (5 endpoints)
```
GET    /api/customers                  List customers (paginated)
GET    /api/customers/:id              Get customer by ID
POST   /api/customers                  Create customer
PUT    /api/customers/:id              Update customer
DELETE /api/customers/:id              Delete customer
```

### Products (7 endpoints)
```
GET    /api/products                   List products (paginated)
GET    /api/products/:id               Get product by ID
POST   /api/products                   Create product
PUT    /api/products/:id               Update product
DELETE /api/products/:id               Delete product
GET    /api/products/search/:query     Search products
GET    /api/products/low-stock         Get low stock items
```

### Sales (8 endpoints)
```
GET    /api/sales                      List sales (paginated)
GET    /api/sales/:id                  Get sale by ID
POST   /api/sales                      Create sale transaction
GET    /api/sales/customer/:id         Get customer's sales
GET    /api/sales/date/:date           Get sales by date
PUT    /api/sales/:id                  Update sale
DELETE /api/sales/:id                  Delete sale
GET    /api/sales/summary              Sales summary
```

### Purchases (13 endpoints)
```
GET    /api/purchases                  List purchases (paginated)
GET    /api/purchases/:id              Get purchase by ID
POST   /api/purchases                  Create purchase
PUT    /api/purchases/:id              Update purchase
DELETE /api/purchases/:id              Delete purchase
GET    /api/suppliers                  List suppliers
POST   /api/suppliers                  Create supplier
PUT    /api/suppliers/:id              Update supplier
DELETE /api/suppliers/:id              Delete supplier
GET    /api/suppliers/:id              Get supplier
GET    /api/purchases/supplier/:id     Get supplier's purchases
... (8 more purchase-related)
```

### Stock Management (12 endpoints)
```
GET    /api/stocks/levels              Get stock levels (all products)
GET    /api/stocks/low-stock           Get low stock alerts
POST   /api/stocks/adjust              Adjust stock quantity
GET    /api/stocks/movements           Get stock movement history
GET    /api/stocks/report              Stock inventory report
GET    /api/stocks/warehouse/:id       Get warehouse stock
POST   /api/stocks/transfer            Transfer between warehouses
... (5 more stock-related)
```

### Reports & Analytics (18 endpoints)
```
GET    /api/reports/sales/daily        Daily sales report
GET    /api/reports/sales/monthly      Monthly sales report
GET    /api/reports/sales/top-products Top selling products
GET    /api/reports/sales/by-customer  Sales by customer
GET    /api/reports/purchases/summary  Purchase summary
GET    /api/reports/inventory/valuation Inventory valuation
GET    /api/reports/financial/revenue Total revenue
GET    /api/reports/financial/expenses Total expenses
GET    /api/reports/financial/profit   Profit analysis
GET    /api/reports/trends/sales       Sales trends
GET    /api/reports/dashboard          Complete dashboard
... (7 more reporting endpoints)
```

### Permissions & RBAC (22 endpoints)
```
GET    /api/roles                      List roles
POST   /api/roles                      Create role
GET    /api/roles/:id                  Get role details
PUT    /api/roles/:id                  Update role
DELETE /api/roles/:id                  Delete role
GET    /api/permissions                List permissions
POST   /api/role-permissions           Assign permission to role
DELETE /api/role-permissions/:id       Remove permission
GET    /api/user-roles                 Get user's roles
POST   /api/user-roles                 Assign role to user
DELETE /api/user-roles/:id             Remove role from user
GET    /api/users                      List users
GET    /api/users/:id                  Get user details
GET    /api/users/role/:role           Get users by role
POST   /api/audit-logs                 Audit trail of actions
... (7 more permissions endpoints)
```

## API Usage Examples

### 1. Authentication Flow

**Login**
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@microemprendimiento.com",
    "password": "password"
  }'
```

Response:
```json
{
  "message": "Login successful",
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid",
    "email": "admin@microemprendimiento.com",
    "name": "Admin User",
    "active": true
  }
}
```

**Refresh Token**
```bash
curl -X POST http://localhost:3000/api/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }'
```

### 2. Protected Endpoint (with token)

**Get Customers**
```bash
curl -X GET http://localhost:3000/api/customers?page=1&limit=50 \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

### 3. Create Resource

**Create Customer**
```bash
curl -X POST http://localhost:3000/api/customers \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Acme Corp",
    "email": "info@acme.com",
    "phone": "+1234567890",
    "address": "123 Business Ave"
  }'
```

**Create Sales Transaction**
```bash
curl -X POST http://localhost:3000/api/sales \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "customer_id": "customer-uuid",
    "details": [
      {
        "product_id": "product-uuid-1",
        "quantity": 5,
        "unit_price": 29.99
      },
      {
        "product_id": "product-uuid-2",
        "quantity": 2,
        "unit_price": 49.99
      }
    ],
    "notes": "Rush delivery requested"
  }'
```

## Flutter App Features

### Login/Register
- ✅ Email/password authentication
- ✅ Auto-login from saved tokens
- ✅ Error messages on failure
- ✅ Toggle between login/register modes

### Dashboard
- ✅ 4 main sections (Sales, Customers, Products, Reports)
- ✅ User profile display
- ✅ Logout functionality
- ✅ Bottom navigation tabs

### Sales Management
- View sales history
- Create new sales
- Summary metrics
- Daily totals

### Customer Management
- List all customers
- Create new customers
- Customer details
- Edit functionality (planned)

### Product Management
- Browse catalog
- View pricing & stock
- Create new products
- Search functionality (planned)

### Reports & Analytics
- Dashboard KPIs
- Revenue tracking
- Customer metrics
- Product performance
- Date range filtering
- Top products

## Common Tasks

### Create a New Customer via Flutter App
1. Launch app → Login
2. Navigate to "Clientes" (Customers) tab
3. Click "Nuevo Cliente" button
4. Fill form:
   - Name: `Empresa XYZ`
   - Email: `info@empresa.com`
   - Phone: `+1234567890`
   - Address: `Calle Principal 123`
5. Click "Crear" → Success message

### Create a Sales Transaction
1. In Dashboard → "Ventas" tab
2. Click "Nueva Venta"
3. Select customer from dropdown
4. Add products and quantities
5. Review total
6. Confirm sale

### View Reports
1. Navigate to "Reportes" tab
2. Select date range (defaults to last 30 days)
3. View KPIs:
   - Total sales revenue
   - Transaction count
   - Customer count
   - Product count
4. See top products and summary tables

## Monitoring & Debugging

### Backend Logs
```bash
docker-compose logs -f backend
```

### Database Access
- PgAdmin: http://localhost:5050
- Connect to PostgreSQL 15-alpine

### API Testing
Tools: Postman, Insomnia, or curl
- Base URL: `http://localhost:3000/api`
- All endpoints require Bearer token (except `/auth/login`, `/auth/register`)

### Flutter Debugging
```bash
flutter run --verbose
# Shows detailed logs

flutter logs
# In another terminal, shows app logs
```

## Deployment Checklist

- [ ] Backend Docker containers running healthy
- [ ] PostgreSQL database initialized with all schema
- [ ] Backend API responding on localhost:3000
- [ ] Flutter app dependencies installed (`flutter pub get`)
- [ ] Valid user credentials for login
- [ ] Network connectivity between app and backend

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Backend won't start | Check port 3000 is free, run `docker-compose up` |
| Database errors | Verify PostgreSQL is healthy: `docker ps` |
| App can't connect | Ensure backend on `localhost:3000`, check firewall |
| Login fails | Verify credentials exist, check backend logs |
| Tokens expire | App auto-refreshes on restart, 15min user session |
| Compilation errors | Run `flutter clean && flutter pub get` |

## Performance Tips

- Use pagination (limit 50 items per page)
- Implement local caching for frequently accessed data
- Batch API calls when possible
- Refresh UI only on data changes
- Use `const` constructors for UI widgets

## Development Workflow

1. **Backend changes**: Restart backend container
2. **Database changes**: Schema updates auto-applied by migrations
3. **Flutter changes**: Hot reload (`r` in terminal) for quick iteration
4. **Full reload**: `R` if hot reload fails

## Security Considerations

- ✅ JWT tokens with 15-min expiration
- ✅ Refresh tokens for session continuation
- ✅ Passwords hashed with bcryptjs
- ✅ CORS configured for local development
- ✅ Role-based access control (RBAC) on backend
- ✅ Tokens stored securely in `shared_preferences`

## Next Steps

1. **Run the complete system**:
   ```bash
   docker-compose up
   cd mobile_app && flutter run
   ```

2. **Test core flows**:
   - Login/logout
   - CRUD operations
   - Reports viewing

3. **Verify data persistence**:
   - Create customers/products
   - Check in PgAdmin
   - Confirm data survives app restart

4. **Enhance features**:
   - Add more screens
   - Implement offline mode
   - Add charts to reports
   - Push notifications

---

**Total Implementation**: 90+ REST API endpoints + Complete Flutter frontend with Provider state management
