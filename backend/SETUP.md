# Backend Setup Guide

## Prerequisites
- PHP 7.4 or higher
- MySQL 5.7 or higher
- Apache/Nginx web server
- PHP mysqli extension enabled

## Installation Steps

### 1. Database Setup

1. Create a MySQL database:
```sql
CREATE DATABASE gym_management CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

2. Import the schema:
```bash
mysql -u root -p gym_management < backend/database/schema.sql
```

Or use phpMyAdmin to import the `schema.sql` file.

### 2. Configure Database Connection

Edit `backend/config/database.php` and update the database credentials:

```php
define('DB_HOST', 'localhost');
define('DB_USER', 'your_username');
define('DB_PASS', 'your_password');
define('DB_NAME', 'gym_management');
```

### 3. Web Server Configuration

#### Apache (.htaccess)

Create a `.htaccess` file in the `backend/api` directory:

```apache
# Enable CORS
Header set Access-Control-Allow-Origin "*"
Header set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
Header set Access-Control-Allow-Headers "Content-Type, Authorization"

# Handle OPTIONS requests
RewriteEngine On
RewriteCond %{REQUEST_METHOD} OPTIONS
RewriteRule ^(.*)$ $1 [R=200,L]

# Enable JSON response
AddType application/json .json
```

#### Nginx

Add to your nginx configuration:

```nginx
location /backend/api/ {
    add_header Access-Control-Allow-Origin *;
    add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS";
    add_header Access-Control-Allow-Headers "Content-Type, Authorization";
    
    if ($request_method = 'OPTIONS') {
        return 200;
    }
    
    try_files $uri $uri/ /index.php?$query_string;
}
```

### 4. File Permissions

Set proper permissions for the backend directory:

```bash
# For Apache/Nginx user (usually www-data)
sudo chown -R www-data:www-data backend/
sudo chmod -R 755 backend/

# If you need upload directories (for images)
mkdir -p backend/uploads/products
mkdir -p backend/uploads/payments
mkdir -p backend/uploads/members
sudo chmod -R 777 backend/uploads/
```

### 5. Test the API

Test the login endpoint:

```bash
curl -X POST http://your-domain.com/backend/api/auth/login.php \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

Expected response:
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "user": {
      "id": 1,
      "username": "admin",
      "full_name": "Administrator",
      "role": "Admin"
    }
  }
}
```

### 6. Security Recommendations

1. **Change Default Password**
   ```sql
   UPDATE users SET password = '$2y$10$newHashedPassword' WHERE username = 'admin';
   ```

2. **Update JWT Secret Key**
   Edit `backend/config/auth.php` and change:
   ```php
   'gym_secret_key_2024'
   ```
   to a strong random string.

3. **Configure CORS for Production**
   Edit `backend/config/cors.php` and restrict origins:
   ```php
   header('Access-Control-Allow-Origin: https://your-frontend-domain.com');
   ```

4. **Enable HTTPS**
   - Always use HTTPS in production
   - Redirect HTTP to HTTPS

5. **Disable Error Display in Production**
   In `php.ini`:
   ```ini
   display_errors = Off
   log_errors = On
   error_log = /path/to/php-error.log
   ```

## Testing

### Using Postman/Insomnia

1. Import the API documentation
2. Create an environment with:
   - `base_url`: Your API base URL
   - `token`: Login token
3. Test each endpoint

### Sample API Calls

**1. Login:**
```
POST /auth/login.php
Body: {"username":"admin","password":"admin123"}
```

**2. List Members:**
```
GET /members/list.php?page=1&limit=20
Headers: Authorization: Bearer {token}
```

**3. Create Member:**
```
POST /members/create.php
Headers: Authorization: Bearer {token}
Body: {
  "full_name": "Test Member",
  "phone": "081234567890"
}
```

## Troubleshooting

### 1. "Database connection failed"
- Check MySQL service is running
- Verify database credentials in `config/database.php`
- Ensure database exists

### 2. "Token not provided" or "Invalid token"
- Ensure Authorization header is set correctly
- Check token hasn't expired (30 days)
- Verify token format: `Bearer {token}`

### 3. CORS errors
- Check CORS headers in `config/cors.php`
- Verify web server CORS configuration
- Use OPTIONS request to test

### 4. "Method not allowed"
- Verify HTTP method (GET/POST/PUT/DELETE)
- Check endpoint URL is correct

### 5. PHP errors
- Check PHP error log
- Verify PHP version (7.4+)
- Ensure mysqli extension is enabled:
  ```bash
  php -m | grep mysqli
  ```

## Default Data

The schema includes default data:

**Roles:**
- Admin
- Pegawai

**User:**
- Username: `admin`
- Password: `admin123`

**Membership Types:**
- New Member: Rp 45,000 (1 year)
- Renewal: Rp 35,000 (1 year)

**Attendance Fee:**
- Non-Member Visit: Rp 15,000

**Expense Types:**
- Utilities, Maintenance, Supplies, Salaries, Other

**Income Types:**
- Membership Fee, Attendance Fee, F&B Sales, Other

**Regions:**
- Sample Jakarta regions (Kabupaten, Kecamatan, Kelurahan)

## Directory Structure

```
backend/
├── api/
│   ├── attendance/      # Attendance endpoints
│   ├── auth/           # Authentication
│   ├── expenses/       # Expense management
│   ├── incomes/        # Income management
│   ├── master/         # Master data (regions, settings)
│   ├── members/        # Member management
│   ├── membership/     # Membership subscriptions
│   ├── pos/           # Point of Sale
│   └── reports/       # Reports
├── config/
│   ├── auth.php       # Authentication helper
│   ├── cors.php       # CORS configuration
│   └── database.php   # Database connection
├── database/
│   └── schema.sql     # Database schema
├── API_DOCUMENTATION.md
└── SETUP.md
```

## Production Checklist

- [ ] Change default admin password
- [ ] Update JWT secret key
- [ ] Configure proper CORS origins
- [ ] Enable HTTPS
- [ ] Set up proper file permissions
- [ ] Disable PHP error display
- [ ] Set up error logging
- [ ] Configure backup strategy
- [ ] Test all endpoints
- [ ] Monitor API performance
- [ ] Set up rate limiting (optional)

## Support

For issues or questions, refer to `API_DOCUMENTATION.md` or contact the development team.
