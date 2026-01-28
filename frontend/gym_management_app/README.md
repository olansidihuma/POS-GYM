# Gym Management System - Flutter App

A complete, production-ready Flutter application for managing gym operations including member management, attendance tracking, POS system, and comprehensive reporting.

## Features

### Member Management
- ✅ Complete member registration with dynamic location fields
- ✅ Member profile with photo upload
- ✅ QR code generation for member cards
- ✅ Member search and filtering
- ✅ Membership expiry tracking

### Membership System
- ✅ Multiple membership packages
- ✅ Automatic expiry calculation
- ✅ Renewal reminders
- ✅ Payment tracking

### Attendance
- ✅ QR code scanner for check-in/check-out
- ✅ Manual attendance recording
- ✅ Real-time attendance statistics
- ✅ Daily, weekly, and monthly reports

### Point of Sale (POS)
- ✅ Product management with categories
- ✅ Shopping cart functionality
- ✅ Multiple payment methods
- ✅ Stock management
- ✅ Receipt generation
- ✅ Bluetooth printer support

### Reports & Analytics
- ✅ Daily/monthly sales reports
- ✅ Financial reports (Admin/Owner only)
- ✅ Attendance reports
- ✅ Member analytics
- ✅ PDF and Excel export

### User Management
- ✅ Role-based access control (Admin, Owner, Staff)
- ✅ JWT authentication
- ✅ Auto-login with token persistence
- ✅ Secure password management

## Tech Stack

- **Framework**: Flutter 3.0+
- **State Management**: GetX
- **HTTP Client**: Dio
- **Local Storage**: SharedPreferences
- **QR Code**: qr_flutter, qr_code_scanner
- **Printing**: blue_thermal_printer
- **PDF/Excel**: pdf, excel packages
- **Architecture**: Clean Architecture (MVC pattern)

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── controllers/              # GetX controllers
│   ├── auth_controller.dart
│   ├── member_controller.dart
│   ├── pos_controller.dart
│   ├── attendance_controller.dart
│   └── membership_controller.dart
├── models/                   # Data models
│   ├── user_model.dart
│   ├── member_model.dart
│   ├── product_model.dart
│   ├── transaction_model.dart
│   ├── attendance_model.dart
│   └── membership_model.dart
├── services/                 # API services
│   ├── api_service.dart
│   ├── auth_service.dart
│   ├── member_service.dart
│   ├── pos_service.dart
│   ├── attendance_service.dart
│   └── membership_service.dart
├── views/                    # UI screens
│   ├── auth/
│   ├── home/
│   ├── members/
│   ├── membership/
│   ├── attendance/
│   ├── pos/
│   ├── reports/
│   └── settings/
├── widgets/                  # Reusable widgets
│   ├── custom_button.dart
│   ├── custom_textfield.dart
│   ├── loading_widget.dart
│   └── error_widget.dart
├── routes/                   # Navigation
│   └── app_routes.dart
└── utils/                    # Constants & utilities
    └── constants.dart
```

## Installation

### Prerequisites
- Flutter SDK 3.0 or higher
- Android Studio / VS Code with Flutter extensions
- Android SDK (for Android development)
- Xcode (for iOS development, macOS only)

### Setup

1. **Clone the repository**
   ```bash
   cd /home/runner/work/POS-GYM/POS-GYM/frontend/gym_management_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint**
   
   Edit `lib/utils/constants.dart`:
   ```dart
   static const String baseUrl = 'http://your-server-ip/gym_management/backend/api';
   ```

4. **Run the app**
   ```bash
   # Check available devices
   flutter devices
   
   # Run on connected device/emulator
   flutter run
   
   # Run in release mode
   flutter run --release
   ```

## Build for Production

### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS (macOS only)
```bash
flutter build ios --release
# Follow Xcode instructions for App Store submission
```

## Configuration

### API Integration

The app connects to the backend API at:
```
http://localhost/gym_management/backend/api
```

Key endpoints:
- `/auth/login.php` - User authentication
- `/members/*` - Member management
- `/membership/*` - Membership operations
- `/attendance/*` - Attendance tracking
- `/products/*` - Product management
- `/transactions/*` - POS transactions
- `/reports/*` - Report generation

### Authentication

The app uses JWT Bearer tokens for authentication:
- Token stored in SharedPreferences
- Automatically added to all API requests
- Auto-logout on 401 responses

### Permissions

The app requires the following permissions:
- **Camera**: QR code scanning
- **Internet**: API communication
- **Bluetooth**: Thermal printer
- **Storage**: Photo uploads, report downloads

## User Roles & Permissions

### Admin
- Full system access
- User management
- Master data management
- All reports and analytics

### Owner
- Member management
- Financial reports
- POS operations
- Attendance tracking

### Staff
- Member registration
- Attendance recording
- POS operations
- Basic reports

## Responsive Design

The app is optimized for:
- **Phone Portrait** (320px - 600px): Single column layout
- **Tablet Landscape** (600px+): Multi-column grid layout

## Screenshots

> Add screenshots of key screens here

## Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Code analysis
flutter analyze
```

## Troubleshooting

### Common Issues

1. **API Connection Failed**
   - Check network connectivity
   - Verify API base URL in constants.dart
   - Ensure backend server is running

2. **QR Scanner Not Working**
   - Grant camera permissions
   - Check AndroidManifest.xml permissions

3. **Bluetooth Printer Not Connecting**
   - Enable Bluetooth permissions
   - Pair printer in device settings first

4. **Build Errors**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## Performance Optimization

- Image caching with cached_network_image
- Pagination for large data lists
- Lazy loading for products
- Efficient state management with GetX

## Security

- JWT token authentication
- Secure password storage
- Role-based access control
- Input validation
- SQL injection prevention (backend)

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License.

## Support

For issues and questions:
- Create an issue on GitHub
- Email: support@gymmanagement.com

## Changelog

### Version 1.0.0 (Current)
- Initial release
- Member management
- Attendance tracking
- POS system
- Basic reporting
- Role-based access control

### Planned Features
- Push notifications for membership expiry
- Workout plan management
- Trainer assignment
- Online payment integration
- Mobile app for members
- Dashboard analytics
- Barcode scanner support

## Credits

Developed with ❤️ using Flutter

---

**Note**: This is a production-ready template. Customize according to your specific requirements.
