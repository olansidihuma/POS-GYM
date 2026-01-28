# Quick Start Guide - Gym Management App

## Project Overview

This is a complete, production-ready Flutter application for Gym Management with the following features:

### ✅ Implemented Features

1. **Authentication System**
   - Login with JWT token
   - Auto-login with saved credentials
   - Role-based access control (Admin, Owner, Staff)
   - Secure token management

2. **Member Management**
   - Create, Read, Update, Delete members
   - Member profile with photo upload
   - Dynamic location fields (Provinsi, Kabupaten, Kecamatan, Kelurahan)
   - QR code generation for member cards
   - Search and filter functionality
   - Responsive list/grid view

3. **Membership System**
   - Multiple membership packages
   - Subscribe new members
   - Renew existing memberships
   - Automatic expiry calculation
   - Expiring membership alerts
   - Payment tracking

4. **Attendance Tracking**
   - QR code scanner for check-in/check-out
   - Manual attendance recording
   - Real-time attendance statistics
   - Daily attendance list
   - Duration tracking
   - Active member monitoring

5. **Point of Sale (POS)**
   - Product catalog with categories
   - Shopping cart with quantity management
   - Multiple payment methods
   - Stock validation
   - Transaction processing
   - Responsive layout (phone & tablet)

6. **Reports & Analytics**
   - Sales reports
   - Attendance reports
   - Financial reports (Admin/Owner)
   - Export to PDF/Excel
   - Date range filtering

7. **Settings**
   - User profile management
   - Change password
   - System configuration
   - Logout functionality

### 📁 Project Structure

```
gym_management_app/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── controllers/                 # State management
│   │   ├── auth_controller.dart
│   │   ├── member_controller.dart
│   │   ├── pos_controller.dart
│   │   ├── attendance_controller.dart
│   │   └── membership_controller.dart
│   ├── models/                      # Data models
│   │   ├── user_model.dart
│   │   ├── member_model.dart
│   │   ├── product_model.dart
│   │   ├── transaction_model.dart
│   │   ├── attendance_model.dart
│   │   └── membership_model.dart
│   ├── services/                    # API integration
│   │   ├── api_service.dart
│   │   ├── auth_service.dart
│   │   ├── member_service.dart
│   │   ├── pos_service.dart
│   │   ├── attendance_service.dart
│   │   └── membership_service.dart
│   ├── views/                       # UI screens
│   │   ├── auth/login_screen.dart
│   │   ├── home/home_screen.dart
│   │   ├── members/
│   │   │   ├── member_list_screen.dart
│   │   │   └── member_form_screen.dart
│   │   ├── membership/subscription_screen.dart
│   │   ├── attendance/attendance_screen.dart
│   │   ├── pos/pos_screen.dart
│   │   ├── reports/report_screen.dart
│   │   └── settings/settings_screen.dart
│   ├── widgets/                     # Reusable components
│   │   ├── custom_button.dart
│   │   ├── custom_textfield.dart
│   │   ├── loading_widget.dart
│   │   └── error_widget.dart
│   ├── routes/                      # Navigation
│   │   └── app_routes.dart
│   └── utils/                       # Constants
│       └── constants.dart
├── android/
│   └── app/src/main/AndroidManifest.xml  # Permissions
├── pubspec.yaml                     # Dependencies
├── analysis_options.yaml            # Linting rules
├── .gitignore
└── README.md                        # Documentation
```

### 🚀 Quick Setup

1. **Install Flutter** (if not already installed)
   ```bash
   # Download from https://flutter.dev/docs/get-started/install
   # Or use Flutter Version Manager (FVM)
   ```

2. **Navigate to project**
   ```bash
   cd /home/runner/work/POS-GYM/POS-GYM/frontend/gym_management_app
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Configure API endpoint**
   
   Edit `lib/utils/constants.dart`:
   ```dart
   static const String baseUrl = 'http://YOUR_IP_ADDRESS/gym_management/backend/api';
   ```
   
   Replace `YOUR_IP_ADDRESS` with your backend server IP.

5. **Run the app**
   ```bash
   # Check connected devices
   flutter devices
   
   # Run on emulator/device
   flutter run
   
   # Run in debug mode with hot reload
   flutter run --debug
   
   # Run in release mode (optimized)
   flutter run --release
   ```

### 📱 Testing the App

**Default Login Credentials** (configure in your backend):
- **Admin**: username: `admin`, password: `admin123`
- **Owner**: username: `owner`, password: `owner123`
- **Staff**: username: `staff`, password: `staff123`

### 🔧 Build for Production

**Android APK:**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**Android App Bundle (Google Play):**
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

**iOS (macOS only):**
```bash
flutter build ios --release
# Then open in Xcode for App Store submission
```

### 🎨 Customization

**App Name:**
- Edit `android/app/src/main/AndroidManifest.xml`: Change `android:label`
- Edit `ios/Runner/Info.plist`: Change `CFBundleName`

**App Icon:**
```bash
# Use flutter_launcher_icons package
flutter pub run flutter_launcher_icons:main
```

**Colors & Theme:**
- Edit `lib/utils/constants.dart`: Modify `AppColors` class

**API Endpoints:**
- Edit `lib/utils/constants.dart`: Update endpoint paths

### 📦 Key Dependencies

- **get**: ^4.6.6 (State management & routing)
- **dio**: ^5.4.0 (HTTP client)
- **shared_preferences**: ^2.2.2 (Local storage)
- **qr_flutter**: ^4.1.0 (QR code generation)
- **qr_code_scanner**: ^1.0.1 (QR scanning)
- **image_picker**: ^1.0.7 (Photo upload)
- **blue_thermal_printer**: ^1.2.2 (Bluetooth printing)
- **pdf**: ^3.10.7 (PDF generation)
- **excel**: ^4.0.2 (Excel export)
- **intl**: ^0.18.1 (Date formatting)

### 🔒 Security Features

- JWT token authentication
- Secure token storage with SharedPreferences
- Auto-logout on token expiration
- Role-based access control
- Input validation on all forms
- Secure API communication

### 📱 Responsive Design

- **Portrait (Phone)**: Single column layout
- **Landscape (Tablet)**: Multi-column grid layout
- Adaptive UI components based on screen size

### 🐛 Common Issues & Solutions

**1. API Connection Failed**
```
Solution: 
- Verify backend is running
- Check API URL in constants.dart
- Ensure device/emulator has network access
- For Android emulator, use 10.0.2.2 instead of localhost
```

**2. Camera Permission Denied**
```
Solution:
- Check AndroidManifest.xml has camera permission
- Manually grant permission in device settings
```

**3. Build Errors**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### 📊 Testing

```bash
# Run all tests
flutter test

# Code analysis
flutter analyze

# Format code
flutter format lib/
```

### 🔄 Backend Integration

**Required Backend Endpoints:**

```
POST /auth/login.php
GET  /members/list.php
POST /members/create.php
PUT  /members/update.php
DELETE /members/delete.php
GET  /membership/packages.php
POST /membership/subscribe.php
POST /attendance/check-in.php
POST /attendance/check-out.php
GET  /products/list.php
POST /transactions/create.php
GET  /reports/*
```

**Request/Response Format:**

```json
// Success Response
{
  "success": true,
  "message": "Operation successful",
  "data": { ... }
}

// Error Response
{
  "success": false,
  "message": "Error description"
}
```

### 📝 Notes

- All API requests automatically include JWT token in Authorization header
- Images are cached locally for performance
- Pagination is implemented for large lists
- Forms include validation
- Loading states are shown during API calls
- Error messages are user-friendly

### 🚀 Next Steps

1. Connect to your backend API
2. Test all features thoroughly
3. Customize branding (colors, logo, app name)
4. Configure Bluetooth printer
5. Test QR scanner with real member cards
6. Generate test data for members and products
7. Build and deploy to devices/stores

### 💡 Tips

- Use **hot reload** (press 'r' in terminal) during development
- Use **hot restart** (press 'R') if state needs reset
- Check logs with `flutter logs`
- Use Flutter DevTools for debugging
- Test on both phone and tablet for responsive design

### 📧 Support

For questions or issues:
- Check README.md for detailed documentation
- Review code comments in source files
- Consult Flutter documentation: https://flutter.dev/docs

---

**Created by**: Flutter Development Team  
**Version**: 1.0.0  
**Last Updated**: 2024

Happy Coding! 🎉
