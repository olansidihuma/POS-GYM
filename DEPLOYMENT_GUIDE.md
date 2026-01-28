# 🏋️ Gym Management System - Complete Application

A production-ready Gym Management System with Point of Sale (POS) capabilities built with Flutter, PHP Native (Procedural), and MySQL.

## 📋 Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Quick Start](#quick-start)
- [Installation](#installation)
- [API Documentation](#api-documentation)
- [Security](#security)
- [Screenshots](#screenshots)
- [License](#license)

## ✨ Features

### 🔐 Authentication & Authorization
- Role-based login (Admin & Pegawai)
- JWT token-based authentication
- Auto-login with secure token storage
- Route guards based on user roles

### 👤 Member Management
- Complete member registration with detailed information
- Dynamic regional data (Kabupaten, Kecamatan, Kelurahan)
- Member search and filtering
- Member profile management
- QR code generation for each member

### 💳 Membership System
- New member subscription (Rp45,000/year)
- Membership renewal (Rp35,000/year)
- Automatic expiry date calculation
- Subscription history tracking
- Active/expired status monitoring

### 🪪 Member Card & QR Code
- Digital member card generation
- Customizable card design (background, QR position, text position)
- QR code for quick check-in
- Share card via WhatsApp
- Export card as image

### 🧾 Attendance System
- **Member Attendance**: QR code scanning
- **Non-Member Attendance**: Rp15,000 per visit
- Daily attendance summary
- Attendance history and reports
- Auto-validation of membership status

### 🍔 F&B Point of Sale (POS)
- Product categorization
- Product inventory management
- Shopping cart with quantity selection
- Product-level discounts
- Transaction-level discounts
- Service charge calculation
- Tax calculation
- Multiple payment methods (Cash, Transfer, QRIS)
- Hold/Recall transactions
- Split bill functionality
- Transaction notes
- Bluetooth thermal printer (58mm) integration

### 💸 Financial Management (Admin Only)
- **Expense Tracking**
  - Multiple expense categories
  - Date-based recording
  - Notes and descriptions
- **Income Tracking**
  - Multiple income categories
  - Date-based recording
  - Notes and descriptions

### 📊 Reports & Analytics (Admin Only)
- Profit & Loss reports
- Date range filtering
- Export to PDF
- Export to Excel
- Daily/Monthly summaries

### ⚙️ Master Data Management (Admin Only)
- Product management (CRUD)
- Product category management
- User management
- Role management
- Settings configuration
- Soft delete (Enable/Disable)

### 🖨️ Printer & Receipt Settings
- Bluetooth printer configuration
- Receipt customization
  - Logo upload
  - Shop name and address
  - Footer notes
- Receipt preview
- Persistent printer settings

## 🛠️ Tech Stack

### Frontend
- **Framework**: Flutter (latest stable)
- **State Management**: GetX
- **HTTP Client**: Dio
- **Local Storage**: SharedPreferences
- **QR**: qr_flutter, qr_code_scanner
- **Camera**: image_picker
- **Printer**: blue_thermal_printer
- **Reports**: pdf, excel
- **Date**: intl

### Backend
- **Language**: PHP Native (Procedural)
- **Authentication**: JWT (Custom implementation)
- **Database**: MySQL 5.7+
- **API**: RESTful API with JSON responses

### Database
- **DBMS**: MySQL
- **Tables**: 25 tables with proper relationships
- **Features**: 
  - Foreign keys
  - Soft deletes
  - Timestamps
  - Sample data

## 📁 Project Structure

```
POS-GYM/
├── README.md                          # Main documentation (this file)
├── backend/                           # PHP Backend
│   ├── api/                          # API endpoints
│   │   ├── auth/                     # Authentication
│   │   │   └── login.php
│   │   ├── members/                  # Member management
│   │   │   ├── list.php
│   │   │   ├── create.php
│   │   │   ├── update.php
│   │   │   ├── delete.php
│   │   │   └── detail.php
│   │   ├── membership/               # Membership subscriptions
│   │   │   ├── types.php
│   │   │   ├── subscribe.php
│   │   │   ├── history.php
│   │   │   └── check_status.php
│   │   ├── attendance/               # Attendance system
│   │   │   ├── checkin.php
│   │   │   ├── list.php
│   │   │   └── summary.php
│   │   ├── pos/                      # Point of Sale
│   │   │   ├── categories.php
│   │   │   ├── products.php
│   │   │   ├── create_transaction.php
│   │   │   ├── hold_transaction.php
│   │   │   ├── get_held.php
│   │   │   └── recall_transaction.php
│   │   ├── expenses/                 # Expense management
│   │   │   ├── create.php
│   │   │   ├── list.php
│   │   │   └── types.php
│   │   ├── incomes/                  # Income management
│   │   │   ├── create.php
│   │   │   ├── list.php
│   │   │   └── types.php
│   │   ├── reports/                  # Financial reports
│   │   │   └── profit_loss.php
│   │   └── master/                   # Master data
│   │       ├── regions.php
│   │       └── settings.php
│   ├── config/                       # Configuration files
│   │   ├── database.php              # Database connection
│   │   ├── auth.php                  # JWT authentication
│   │   └── cors.php                  # CORS headers
│   ├── database/                     # Database files
│   │   └── schema.sql                # Complete database schema
│   ├── API_DOCUMENTATION.md          # Complete API reference
│   ├── SETUP.md                      # Backend setup guide
│   ├── SECURITY.md                   # Security guidelines
│   └── README.md                     # Backend documentation
├── frontend/                         # Flutter Frontend
│   └── gym_management_app/
│       ├── lib/
│       │   ├── main.dart            # App entry point
│       │   ├── controllers/         # GetX controllers
│       │   │   ├── auth_controller.dart
│       │   │   ├── member_controller.dart
│       │   │   ├── membership_controller.dart
│       │   │   ├── pos_controller.dart
│       │   │   └── attendance_controller.dart
│       │   ├── models/              # Data models
│       │   │   ├── user_model.dart
│       │   │   ├── member_model.dart
│       │   │   ├── membership_model.dart
│       │   │   ├── product_model.dart
│       │   │   ├── transaction_model.dart
│       │   │   └── attendance_model.dart
│       │   ├── services/            # API services
│       │   │   ├── api_service.dart
│       │   │   ├── auth_service.dart
│       │   │   ├── member_service.dart
│       │   │   ├── membership_service.dart
│       │   │   ├── pos_service.dart
│       │   │   └── attendance_service.dart
│       │   ├── views/               # UI screens
│       │   │   ├── auth/
│       │   │   │   └── login_screen.dart
│       │   │   ├── home/
│       │   │   │   └── home_screen.dart
│       │   │   ├── members/
│       │   │   │   ├── member_list_screen.dart
│       │   │   │   └── member_form_screen.dart
│       │   │   ├── membership/
│       │   │   │   └── subscription_screen.dart
│       │   │   ├── attendance/
│       │   │   │   └── attendance_screen.dart
│       │   │   ├── pos/
│       │   │   │   └── pos_screen.dart
│       │   │   ├── reports/
│       │   │   │   └── report_screen.dart
│       │   │   └── settings/
│       │   │       └── settings_screen.dart
│       │   ├── widgets/             # Reusable widgets
│       │   │   ├── custom_button.dart
│       │   │   ├── custom_textfield.dart
│       │   │   ├── loading_widget.dart
│       │   │   └── error_widget.dart
│       │   ├── routes/              # Navigation
│       │   │   └── app_routes.dart
│       │   └── utils/               # Utilities
│       │       └── constants.dart
│       ├── android/                 # Android configuration
│       │   └── app/src/main/
│       │       └── AndroidManifest.xml
│       ├── pubspec.yaml             # Dependencies
│       ├── README.md                # Frontend documentation
│       ├── QUICKSTART.md            # Quick start guide
│       └── START_HERE.md            # Entry point
└── DEPLOYMENT.md                    # Deployment guide (this section)
```

## 🚀 Quick Start

### Prerequisites
- **PHP**: 7.4 or higher
- **MySQL**: 5.7 or higher
- **Flutter**: Latest stable version
- **Web Server**: Apache/Nginx (with PHP support)
- **Android Studio**: For Android development (or Xcode for iOS)

### 1. Clone Repository
```bash
git clone https://github.com/olansidihuma/POS-GYM.git
cd POS-GYM
```

### 2. Setup Database
```bash
# Import database schema
mysql -u root -p -e "CREATE DATABASE gym_management"
mysql -u root -p gym_management < backend/database/schema.sql
```

### 3. Configure Backend
Edit `backend/config/database.php`:
```php
define('DB_HOST', 'localhost');
define('DB_USER', 'your_username');
define('DB_PASS', 'your_password');
define('DB_NAME', 'gym_management');
```

Edit `backend/config/auth.php` - Change JWT secret:
```php
// Line 21 - Change to a strong random key
$signature = hash_hmac('sha256', $base64UrlHeader . "." . $base64UrlPayload, 'your_random_secret_key_here', true);
```

### 4. Setup Backend Web Server

**For Apache:**
```bash
# Copy backend to web server directory
sudo cp -r backend /var/www/html/gym_management

# Set permissions
sudo chown -R www-data:www-data /var/www/html/gym_management
sudo chmod -R 755 /var/www/html/gym_management
```

**For Development (PHP Built-in Server):**
```bash
cd backend
php -S localhost:8000
```

### 5. Setup Flutter App
```bash
cd frontend/gym_management_app

# Install dependencies
flutter pub get

# Configure API URL
# Edit lib/utils/constants.dart
# Change baseUrl to your backend URL

# Run the app
flutter run
```

### 6. Login Credentials
- **Username**: `admin`
- **Password**: `admin123`
- **⚠️ CHANGE IMMEDIATELY AFTER FIRST LOGIN!**

## 📖 Installation

For detailed installation instructions, see:
- **Backend Setup**: [backend/SETUP.md](backend/SETUP.md)
- **Frontend Setup**: [frontend/gym_management_app/QUICKSTART.md](frontend/gym_management_app/QUICKSTART.md)

## 📚 API Documentation

Complete API documentation is available at:
- **API Reference**: [backend/API_DOCUMENTATION.md](backend/API_DOCUMENTATION.md)
- **Endpoints Summary**: [backend/API_ENDPOINTS_SUMMARY.md](backend/API_ENDPOINTS_SUMMARY.md)

### API Base URL
```
http://your-domain.com/gym_management/backend/api
```

### Authentication
All endpoints (except login) require Bearer token:
```
Authorization: Bearer <your_jwt_token>
```

## 🔒 Security

### Important Security Steps
1. **Change default admin password immediately**
2. **Generate strong JWT secret key**
3. **Configure CORS for production domain**
4. **Enable HTTPS in production**
5. **Set proper file permissions**
6. **Keep PHP and MySQL updated**
7. **Use environment variables for sensitive data**
8. **Regular database backups**

For detailed security guidelines, see: [backend/SECURITY.md](backend/SECURITY.md)

## 📱 Responsive Design

- **Phone**: Portrait orientation
- **Tablet**: Landscape orientation
- Automatic layout adjustment based on screen size

## 🧪 Testing

### Backend API Testing
```bash
# Test login endpoint
curl -X POST http://localhost:8000/api/auth/login.php \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

### Flutter App Testing
```bash
cd frontend/gym_management_app
flutter test
```

## 🎯 Development Rules

- ✅ Clean architecture with separation of concerns
- ✅ No hardcoded values (all dynamic from API/database)
- ✅ Proper error handling and loading states
- ✅ Input validation on both frontend and backend
- ✅ Reusable widgets and components
- ✅ Consistent code style
- ✅ Production-ready code (no prototypes)

## 📊 Database Statistics

- **Tables**: 25
- **Default Roles**: 2 (Admin, Pegawai)
- **Sample Data**: Included for testing
- **Relationships**: Properly defined with foreign keys

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Flutter Team for the amazing framework
- GetX for state management
- All open-source contributors

## 📧 Support

For issues, questions, or contributions:
- Open an issue on GitHub
- Contact: [Your Contact Information]

## 🎉 Status

**✅ PRODUCTION READY**

This application is fully functional and ready for:
- Deployment to production servers
- Testing with real data
- Customization and branding
- App store submission (after proper testing)
- Client delivery

---

**Built with ❤️ for Gym Management and POS needs**
