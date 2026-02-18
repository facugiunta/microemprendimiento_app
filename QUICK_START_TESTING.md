# QUICK START - Testing the Flutter App

## Prerequisites

1. **Backend Running**
   ```bash
   cd backend
   npm start
   # Should output: Server running on http://localhost:3000
   ```

2. **Flutter SDK Installed**
   ```bash
   flutter --version
   ```

3. **Dependencies Installed**
   ```bash
   cd mobile_app
   flutter pub get
   ```

---

## Run on Android Emulator

### Start Emulator
```bash
# List available emulators
emulator -list-avds

# Start specific emulator
emulator -avd Pixel_5_API_33  # or your emulator name

# Wait for emulator to fully boot (look for "Boot completed" in adb shell)
```

### Run App
```bash
cd mobile_app
flutter run

# Or with verbose output for debugging
flutter run -v

# Or specify Android device
flutter run -d emulator-5554
```

### Verify Connection
```bash
# Check if emulator can reach backend gateway
adb shell ping 10.0.2.2

# If ping fails, backend isn't accessible
# Make sure backend is running on port 3000
```

---

## Run on iOS Simulator

### Start Simulator
```bash
# List available simulators
xcrun simctl list devices

# Start specific iPhone simulator
open -a Simulator  # Opens default simulator

# Or create new simulator
xcrun simctl create "iPhone 15" com.apple.CoreSimulator.SimDeviceType.iPhone-15 com.apple.CoreSimulator.SimRuntime.iOS-17-0
```

### Run App
```bash
cd mobile_app
flutter run
# OR
flutter run -d iPhone-15-simulator
```

### Verify Connection
```bash
# In Simulator terminal
ping localhost
# Should get responses from backend on 127.0.0.1:3000
```

---

## Run on macOS

### Requirements
- macOS Monterey 12+ 
- Xcode command line tools: `xcode-select --install`

### Run App
```bash
cd mobile_app
flutter run -d macos
```

### Verify
```bash
# Check backend accessible from macOS
curl http://localhost:3000/api/health
# Should return: {"status":"ok"}
```

---

## Run on Windows

### Requirements
- Visual Studio or Visual Studio Build Tools
- CMake
- Windows SDK

### Run App
```bash
cd mobile_app
flutter run -d windows
```

### Verify
```bash
# Check backend accessible from Windows
curl http://localhost:3000/api/health
# Should return: {"status":"ok"}
```

---

## Common Issues & Solutions

### Issue: "Network is unreachable" on Android
**Solution:**
1. Check emulator can see host machine:
   ```bash
   adb shell ping 10.0.2.2
   ```
2. If ping fails, restart emulator:
   ```bash
   emulator -avd Pixel_5_API_33 -no-snapshot-load
   ```
3. Verify backend is actually running:
   ```bash
   curl http://localhost:3000/api/health
   ```

### Issue: "Connection refused" on any platform
**Solution:**
1. Verify backend is running:
   ```bash
   # In backend directory
   npm start
   ```
2. Check backend port:
   ```bash
   netstat -an | grep 3000  # macOS/Linux
   netstat -ano | findstr :3000  # Windows
   ```

### Issue: "SSL Certificate Problem" or HTTPS errors
**Solution:**
- Development setup uses HTTP, not HTTPS
- Check api_config.dart uses `http://` not `https://`
- Android network_security_config.xml allows cleartext on localhost/10.0.2.2

### Issue: "Timeout after 15 seconds"
**Solution:**
1. Increase timeout in lib/config/api_config.dart:
   ```dart
   static const int timeoutSeconds = 30;  // Change from 15
   ```
2. Verify backend performance:
   ```bash
   # Check backend logs for slow response times
   ```

### Issue: App won't compile
**Solution:**
```bash
# Clean build
cd mobile_app
flutter clean
flutter pub get
flutter run

# Or with verbose output
flutter run -v
```

---

## Debug Mode Features

### Hot Reload (while app is running)
```bash
# In terminal where flutter run is executing
r  # Hot reload (code changes only)
R  # Full restart (code + state reset)
q  # Quit
```

### Enable Debug Logging
Edit lib/services/api_service.dart in `_handleResponse()`:
```dart
print('REQUEST: $method $path');
print('RESPONSE: ${response.statusCode}');
if (response.statusCode == 200) {
  print('BODY: ${response.body}');
}
```

---

## Testing Checklist

After launching app:

- [ ] **Splash Screen**: Should see logo with fade animation, then redirect to login/home
- [ ] **Login Flow**: 
  - [ ] Enter test email: test@test.com
  - [ ] Enter test password: password123
  - [ ] Click "Ingresar" → Should redirect to home
- [ ] **Home Screen**:
  - [ ] See greeting with current date
  - [ ] See monthly summary cards (Ventas, Compras, etc)
  - [ ] See quick action buttons
  - [ ] See stock bajo warning if products have low stock
- [ ] **Products**:
  - [ ] Create new product → See in list
  - [ ] Edit product → See changes
  - [ ] Delete product → Disappear from list
- [ ] **Sales**:
  - [ ] Create new sale → See in history
  - [ ] Filter by date range
  - [ ] See total amounts
- [ ] **Settings**:
  - [ ] Toggle dark/light mode → Theme changes
  - [ ] See user info
  - [ ] Logout → Back to login screen

---

## Performance Tips

1. **For Faster Startup**: Run with release mode on physical devices
   ```bash
   flutter run --release
   ```

2. **For Development**: Use debug mode with hot reload
   ```bash
   flutter run -d emulator-5554
   # Then press 'r' for hot reload while editing
   ```

3. **Monitor Performance**:
   - Open DevTools:
     ```bash
     flutter pub global activate devtools
     devtools
     # Opens http://localhost:9100
     ```

---

## Production Build

When ready to release:

```bash
# Android APK
flutter build apk --release

# iOS App
flutter build ios --release

# macOS Notarization required for distribution
flutter build macos --release
```

Output locations:
- Android APK: `build/app/outputs/flutter-apk/app-release.apk`
- iOS IPA: `build/ios/ipa/`
- macOS APP: `build/macos/Build/Products/Release/`

---

**Need Help?** Check logs with `flutter run -v` for detailed error messages.
