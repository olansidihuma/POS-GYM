# 🚀 Quick Start Guide - Gym Management System

## 📖 Documentation Index

**Start Here:**
1. **PROJECT_OVERVIEW.md** - Complete project summary and requirements checklist
2. **DEPLOYMENT_GUIDE.md** - Full deployment and setup instructions
3. **README.md** - Original project requirements

**Backend Documentation:**
- `backend/SETUP.md` - Backend installation guide
- `backend/API_DOCUMENTATION.md` - Complete API reference
- `backend/API_ENDPOINTS_SUMMARY.md` - Quick endpoint reference
- `backend/SECURITY.md` - Security guidelines

**Frontend Documentation:**
- `frontend/gym_management_app/START_HERE.md` - Flutter app entry point
- `frontend/gym_management_app/QUICKSTART.md` - Quick setup guide
- `frontend/gym_management_app/README.md` - App documentation

---

## ⚡ 5-Minute Quick Start

### Prerequisites
```bash
# Required
- PHP 7.4+
- MySQL 5.7+
- Flutter (latest stable)
```

### Step 1: Database Setup
```bash
# Create and import database
mysql -u root -p -e "CREATE DATABASE gym_management"
mysql -u root -p gym_management < backend/database/schema.sql
```

### Step 2: Configure Backend
```bash
# Edit backend/config/database.php
# Set your database credentials:
DB_HOST = localhost
DB_USER = your_username
DB_PASS = your_password
DB_NAME = gym_management
```

### Step 3: Start Backend
```bash
# Option 1: PHP Built-in Server (Development)
cd backend
php -S localhost:8000

# Option 2: Apache/Nginx (Production)
# Copy backend folder to web server root
sudo cp -r backend /var/www/html/gym_management
```

### Step 4: Configure Flutter App
```bash
# Edit frontend/gym_management_app/lib/utils/constants.dart
# Set your API URL:
static const String baseUrl = 'http://localhost:8000/api';
```

### Step 5: Install Dependencies & Run
```bash
cd frontend/gym_management_app
flutter pub get
flutter run
```

### Step 6: Login
```
Username: admin
Password: admin123
⚠️ CHANGE IMMEDIATELY AFTER FIRST LOGIN!
```

---

## 📊 What's Included

### Backend (28 API Endpoints)
✅ Authentication (JWT)
✅ Member Management (5 endpoints)
✅ Membership Subscriptions (4 endpoints)
✅ Attendance System (3 endpoints)
✅ POS/F&B Sales (6 endpoints)
✅ Expenses Management (3 endpoints)
✅ Incomes Management (3 endpoints)
✅ Financial Reports (1 endpoint)
✅ Master Data (2 endpoints)

### Frontend (10 Screens)
✅ Login & Authentication
✅ Home Dashboard
✅ Member List & Registration
✅ Membership Subscription
✅ Attendance with QR Scanner
✅ POS System
✅ Financial Reports (PDF/Excel)
✅ Settings

### Database (25 Tables)
✅ Complete schema with relationships
✅ Sample data included
✅ Foreign keys configured
✅ Default admin user

---

## 🔒 Important Security Steps

```bash
# 1. Change default admin password
# Login and change via app or direct SQL:
UPDATE users SET password = '$2y$10$YOUR_NEW_HASH' WHERE username = 'admin';

# 2. Generate strong JWT secret
# Edit backend/config/auth.php line 21
# Replace 'gym_secret_key_2024' with random 32+ character string

# 3. Configure CORS for production
# Edit backend/config/cors.php
# Change from '*' to specific domain:
header('Access-Control-Allow-Origin: https://your-domain.com');

# 4. Enable HTTPS in production
# Configure SSL certificate in Apache/Nginx
```

---

## 📁 Project Structure

```
POS-GYM/
├── backend/                    # PHP Backend
│   ├── api/                   # 28 API endpoints
│   ├── config/                # Configuration files
│   ├── database/              # SQL schema
│   └── [documentation]
├── frontend/                   # Flutter Frontend
│   └── gym_management_app/
│       ├── lib/               # Dart code
│       │   ├── controllers/   # GetX controllers
│       │   ├── models/        # Data models
│       │   ├── services/      # API services
│       │   ├── views/         # UI screens
│       │   ├── widgets/       # Reusable widgets
│       │   └── routes/        # Navigation
│       └── [documentation]
├── DEPLOYMENT_GUIDE.md        # Full deployment guide
├── PROJECT_OVERVIEW.md        # Complete project summary
└── QUICK_START.md            # This file
```

---

## 🧪 Testing

### Test Backend API
```bash
# Test login endpoint
curl -X POST http://localhost:8000/api/auth/login.php \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'

# Expected response: JWT token + user data
```

### Test Flutter App
```bash
cd frontend/gym_management_app
flutter doctor    # Check Flutter setup
flutter test      # Run tests
flutter run       # Run on device/emulator
```

---

## 📦 Dependencies

### Backend
- PHP 7.4+ with mysqli extension
- MySQL 5.7+
- Apache/Nginx (or PHP built-in server)

### Frontend
- Flutter SDK (latest stable)
- 15 packages (in pubspec.yaml):
  - get (state management)
  - dio (HTTP client)
  - shared_preferences (storage)
  - qr_flutter, qr_code_scanner
  - image_picker, blue_thermal_printer
  - pdf, excel (reports)
  - And more...

---

## 🐛 Troubleshooting

### Database Connection Error
```
✓ Check MySQL is running: sudo systemctl status mysql
✓ Verify credentials in backend/config/database.php
✓ Ensure database exists: SHOW DATABASES;
```

### API Not Responding
```
✓ Check backend server is running
✓ Verify CORS headers in backend/config/cors.php
✓ Check PHP errors: tail -f /var/log/apache2/error.log
```

### Flutter App Not Connecting
```
✓ Check API URL in lib/utils/constants.dart
✓ For Android emulator use: http://10.0.2.2:8000
✓ For iOS simulator use: http://localhost:8000
✓ For physical device use: http://YOUR_IP:8000
```

### Login Failed
```
✓ Check username/password: admin/admin123
✓ Verify users table exists and has data
✓ Check PHP password_verify function is available
```

---

## 📚 Learn More

### Backend Development
- Read: `backend/API_DOCUMENTATION.md`
- Study: `backend/config/auth.php` for JWT implementation
- Explore: `backend/api/` folder structure

### Frontend Development
- Read: `frontend/gym_management_app/README.md`
- Study: `lib/controllers/` for GetX patterns
- Explore: `lib/services/` for API integration

### Deployment
- Read: `DEPLOYMENT_GUIDE.md`
- Follow: `backend/SECURITY.md`
- Check: `PROJECT_OVERVIEW.md`

---

## ✅ Verification Checklist

After setup, verify:
- [ ] Database created and populated
- [ ] Backend server running
- [ ] API login endpoint works
- [ ] Flutter app runs without errors
- [ ] Can login with admin/admin123
- [ ] Dashboard displays properly
- [ ] Can create a member
- [ ] Can record attendance
- [ ] POS screen loads products
- [ ] Default password changed

---

## 🎯 Default Credentials

**Admin User:**
- Username: `admin`
- Password: `admin123`
- Role: Admin (full access)

**⚠️ CRITICAL: Change default password immediately!**

---

## 📊 Quick Stats

- **Total Files**: 80+
- **Lines of Code**: 11,000+
- **API Endpoints**: 28
- **UI Screens**: 10
- **Database Tables**: 25
- **Documentation**: 60,000+ characters

---

## 🤝 Support

For issues or questions:
1. Check documentation files
2. Review troubleshooting section above
3. Check API_DOCUMENTATION.md for API details
4. Open an issue on GitHub

---

## 🎉 You're Ready!

Your Gym Management System is fully implemented and ready to use!

**Next Steps:**
1. Follow the 5-minute quick start above
2. Login and explore the features
3. Customize branding and settings
4. Add your real data
5. Deploy to production

**Happy coding! 🚀**

---

*For detailed information, see PROJECT_OVERVIEW.md and DEPLOYMENT_GUIDE.md*
