# 🚀 Getting Started Now

## Option 1: Fastest Setup (Automated - 2 minutes)

```powershell
# Run the quick start script
cd c:\Users\Mati\Documents\microemprendimiento_app
.\QUICK_START.ps1

# Then start Flutter in the same directory
cd mobile_app
flutter run
```

## Option 2: Manual Setup (5 minutes)

### Step 1: Start Backend Services
```bash
cd c:\Users\Mati\Documents\microemprendimiento_app
docker-compose up -d

# Verify (should show "Up" status)
docker-compose ps
```

### Step 2: Prepare Flutter App
```bash
cd mobile_app
flutter pub get
```

### Step 3: Run the App
```bash
# Choose one based on your target platform:

# For Android emulator or device
flutter run

# For iOS (macOS only)
flutter run -d ios

# For Chrome browser
flutter run -d chrome

# For Windows desktop
flutter run -d windows
```

### Step 4: Login
- **Email**: `admin@microemprendimiento.com`
- **Password**: `password`

**You're in! 🎉**

---

## What You Can Do Immediately

### ✅ Explore Customers
1. Tap **Clientes** (Customers) tab
2. See 5 preloaded customers
3. Add a new customer → Click "Nuevo Cliente" button
4. Fill the form and save

### ✅ Browse Products  
1. Tap **Productos** (Products) tab
2. See 10 preloaded products with pricing
3. Add a new product → Click "Nuevo Producto" button

### ✅ Create a Sale
1. Tap **Ventas** (Sales) tab
2. Click "Nueva Venta" (New Sale)
3. Select a customer
4. Add products and quantities
5. Confirm the transaction

### ✅ View Analytics
1. Tap **Reportes** (Reports) tab
2. See business metrics:
   - Total sales revenue
   - Number of transactions
   - Customer count
   - Top selling products
3. Change date range to filter data

---

## Common Commands

### Docker Management
```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# View logs
docker-compose logs -f backend

# Restart specific service
docker-compose restart backend
```

### Flutter Development
```bash
# Installation
flutter pub get

# Run with hot reload
flutter run

# Build APK (Android)
flutter build apk --release

# Build for production
flutter build apk --release --obfuscate --split-per-abi

# Clean and rebuild
flutter clean && flutter pub get && flutter run
```

### Database Access
```
URL: http://localhost:5050
Email: admin@microemprendimiento.com
Password: admin
```

---

## Troubleshooting

### "Connection refused" Error
**Problem**: App can't reach backend
**Solution**: 
1. Check Docker: `docker-compose ps`
2. Verify backend: `curl http://localhost:3000/api/auth/me`
3. Restart if needed: `docker-compose restart backend`

### "Login failed" Error
**Problem**: Credentials not working
**Solution**:
1. Verify user exists: Check PgAdmin database
2. Check backend logs: `docker-compose logs backend`
3. Reset with fresh Docker: `docker-compose down && docker-compose up -d`

### Flutter Won't Start
**Problem**: Compilation errors
**Solution**:
```bash
flutter clean
flutter pub get
flutter run -v  # verbose for detailed logs
```

### Port Already in Use
**Problem**: Port 3000 or 5432 occupied
**Solution**:
```bash
# Find process using port
netstat -ano | findstr 3000

# Kill process (Windows)
taskkill /PID <PID> /F

# Or change Docker port in docker-compose.yml
```

---

## Next Steps After Login

### 1. Test the Complete Flow
- [ ] Create a new customer
- [ ] Create a product
- [ ] Create a sales transaction
- [ ] View the transaction in history
- [ ] Check PgAdmin to see data in database

### 2. Explore API Endpoints
- Best tool: Postman or Insomnia
- Base URL: `http://localhost:3000/api`
- Get token from login response
- Add to header: `Authorization: Bearer <token>`

### 3. Review the Code
- Backend: `backend/app.ts` - main API implementation
- Frontend models: `mobile_app/lib/models/` - data structures
- API client: `mobile_app/lib/services/api_service.dart`
- State management: `mobile_app/lib/providers/auth_provider.dart`

### 4. Customize for Your Needs
- Add new fields to models
- Create additional screens
- Implement new business logic
- Add more reporting features

---

## Key Files to Know

### Backend
- `backend/app.ts` - Main application (all 90+ endpoints)
- `backend/package.json` - Dependencies

### Database  
- Schema auto-initialized in `postgres_data` volume
- Access via PgAdmin at http://localhost:5050

### Mobile App
- `mobile_app/lib/main.dart` - App entry point
- `mobile_app/lib/services/api_service.dart` - API communication (90+ methods)
- `mobile_app/lib/models/` - Data structures
- `mobile_app/lib/screens/` - UI screens

### Documentation
- `FULL_STACK_INTEGRATION.md` - Complete technical docs
- `mobile_app/FLUTTER_APP_README.md` - Flutter details
- `IMPLEMENTATION_SUMMARY.md` - What's been built

---

## Architecture At a Glance

```
Flutter App (iOS/Android/Web)
        ↓ (HTTP REST + JWT Bearer Token)
Express.js Backend (http://localhost:3000)
        ↓ (SQL Queries)
PostgreSQL Database (localhost:5432)
```

All 90+ API endpoints are ready to use from the Flutter app.

---

## Performance Tips

- Pagination is built-in (set limit & page numbers)
- Data loads from backend when needed
- Token refreshes automatically
- UI responds smoothly to fast actions

---

## Questions?

See detailed docs:
- **FULL_STACK_INTEGRATION.md** - Complete guide with all endpoints
- **mobile_app/FLUTTER_APP_README.md** - Flutter architecture
- Code comments in backend - Implementation details

---

**Everything is ready to use. Just run it! 🎉**
