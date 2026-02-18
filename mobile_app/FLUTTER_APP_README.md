# Flutter Mobile App for Microemprendimiento

## Overview
This is a complete Flutter application that consumes the 90+ REST API endpoints from the Express.js backend. The app uses Provider for state management, HTTP client for API communication, and follows clean architecture principles.

## Project Structure

```
lib/
├── main.dart                          # App entry point with Provider setup
├── models/                            # Data models with JSON serialization
│   ├── user_model.dart               # User & AuthResponse models
│   ├── customer_model.dart           # Customer model
│   ├── product_model.dart            # Product model
│   └── sale_model.dart               # Sale & SaleDetail models
├── services/                          # API client and business logic
│   └── api_service.dart              # HTTP client with 90+ endpoints
├── providers/                         # State management
│   └── auth_provider.dart            # Authentication state & token handling
├── screens/                           # UI screens
│   ├── login_screen.dart             # Login/Register screen
│   ├── dashboard_screen.dart         # Main app navigation
│   └── sections/                     # Feature sections
│       ├── sales_section.dart        # Sales management
│       ├── customers_section.dart    # Customer management
│       ├── products_section.dart     # Product management
│       └── reports_section.dart      # Analytics & reports
└── pubspec.yaml                       # Dependencies configuration
```

## Architecture

### 1. Models Layer (`models/`)
- **user_model.dart**: `User` and `AuthResponse` classes for authentication
- **customer_model.dart**: Customer entity with CRUD operations
- **product_model.dart**: Product catalog management
- **sale_model.dart**: Sales transactions with detail items

All models include:
- `fromJson()` factory constructor for API response deserialization
- `toJson()` method for request body serialization
- Type conversion handling (String ↔ Double for prices)

### 2. Service Layer (`services/`)
- **api_service.dart**: HTTP client that wraps all backend endpoints
  - Base URL: `http://localhost:3000/api`
  - JWT token management with Bearer authentication
  - 90+ API methods organized by module:
    - Auth (5 endpoints)
    - Customers (5 endpoints)
    - Products (7 endpoints)
    - Sales (8 endpoints)
    - Reports (18 endpoints)
    - Stock (12 endpoints)
  - Error handling and response mapping via `ApiResponse` wrapper class

### 3. Provider Layer (`providers/`)
- **auth_provider.dart**: ChangeNotifier for authentication state
  - Token persistence via `shared_preferences`
  - Auto-login on app start if valid token exists
  - Login/Register workflows
  - User profile management
  - Logout with token cleanup

### 4. Screen Layer (`screens/`)

#### Login Screen
- Email/Password authentication
- Register form toggling
- Form validation
- Error feedback
- Auto-routes to Dashboard on successful login

#### Dashboard Screen (Main App)
- Bottom navigation with 4 tabs
- User info display in AppBar
- Logout functionality
- Routes to feature sections

#### Feature Sections
1. **Sales Section**
   - View sales list
   - Create new sales
   - Sales summary metrics
   
2. **Customers Section**
   - List all customers
   - Create new customers
   - Edit customer details (pending)
   
3. **Products Section**
   - View product inventory
   - Create products
   - Display pricing and stock levels
   
4. **Reports Section**
   - Dashboard with key metrics
   - Date range filtering
   - Sales, customer, and product summaries
   - Top products listing
   - Revenue analytics

## Dependencies

From `pubspec.yaml`:
```yaml
provider: ^6.1.5+1          # State management
http: ^1.6.0                # HTTP requests
sqflite: ^2.4.2             # Local database (optional)
shared_preferences: ^2.5.4  # Token persistence
flutter_test                # Testing
```

## Setup & Running

### Prerequisites
- Flutter 3.0+ with Dart 3.0+
- Backend running on `http://localhost:3000`
- PostgreSQL database initialized (see backend README)

### Steps
1. Navigate to mobile app directory:
   ```bash
   cd mobile_app
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

4. Use these credentials to login:
   - Email: `admin@microemprendimiento.com` (or any registered email)
   - Password: `password` (or registered password)

## API Integration

### Authentication Flow
1. User submits login credentials
2. `ApiService.login()` sends POST to `/api/auth/login`
3. Backend returns JWT tokens (access + refresh)
4. `AuthProvider` saves token to `shared_preferences`
5. Token added to all future requests as `Authorization: Bearer <token>`
6. App routes to Dashboard on success

### CRUD Operations Example
```dart
// Create customer
final customer = Customer(
  name: 'John Doe',
  email: 'john@example.com',
  phone: '+1234567890',
  address: '123 Main St',
);
final response = await apiService.createCustomer(customer);

// Read customers
final response = await apiService.getCustomers(page: 1, limit: 50);

// Parse response
if (response.success) {
  final customers = (response.data['customers'] as List)
    .map((c) => Customer.fromJson(c))
    .toList();
}
```

## State Management Pattern

The app uses Provider's `MultiProvider` pattern:

```dart
MultiProvider(
  providers: [
    Provider<ApiService>.value(value: apiService),
    ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
  ],
  child: MyApp(),
)
```

- `ApiService`: Singleton providing HTTP methods
- `AuthProvider`: ChangeNotifier for user state and authentication
- Screens consume these providers via `context.read()` and `Consumer<>`

## Key Features Implemented

✅ **Authentication**
- Login with email/password
- Register new users
- Automatic token persistence
- Token auto-refresh on app reboot
- Logout with cleanup

✅ **Customers Management**
- View all customers
- Create new customers
- Form validation
- List display with search-ready structure

✅ **Products Management**
- Browse product catalog
- Create products with pricing
- Track inventory levels
- Display product details

✅ **Sales Module**
- View sales history
- Create sales transactions
- Sales summary cards
- Daily metrics

✅ **Reports & Analytics**
- Dashboard with KPIs
- Revenue tracking
- Customer metrics
- Product performance
- Date range filtering
- Top products listing

## Error Handling

All API responses go through `ApiResponse` wrapper:
```dart
class ApiResponse {
  final bool success;
  final dynamic data;
  final String message;
}
```

This provides consistent error handling across the app.

## Future Enhancements

- [ ] Offline mode with sqflite caching
- [ ] Image upload for products
- [ ] Advanced reporting with charts
- [ ] Purchase order management
- [ ] Stock movement tracking
- [ ] Supplier management UI
- [ ] Push notifications
- [ ] Print sales receipts
- [ ] Export reports to PDF/Excel

## Troubleshooting

### Connection Issues
- Ensure backend is running: `docker-compose up`
- Check backend is on `localhost:3000`
- Verify network connectivity

### Compilation Errors
- Run `flutter clean` then `flutter pub get`
- Check Dart/Flutter versions match pubspec requirements
- Rebuild: `flutter run --release`

### Authentication Issues
- Tokens expire after 15 minutes
- App auto-refreshes on startup if valid token exists
- Clear app data to force re-login: `flutter clean`

## Testing the Complete Flow

1. **Startup**: App boots, checks for saved token
2. **Login**: Enter credentials, token persists
3. **Navigate**: Use bottom tabs to explore features
4. **CRUD**: Create customers/products through dialogs
5. **View**: Lists populate from backend API
6. **Logout**: Clear token, return to login screen

## Performance Considerations

- Pagination implemented in list endpoints (page, limit params)
- LazyListView for large product/customer lists planned
- Token caching to avoid extra auth calls
- Provider optimization to minimize rebuilds

## Code Quality

- Follows Dart/Flutter style guidelines
- Type-safe API responses
- Error handling on all network calls
- Proper resource cleanup in StatefulWidget.dispose()
- Consistent naming conventions (camelCase for variables, PascalCase for classes)
