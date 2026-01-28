# Security Configuration Guide

## Critical Security Configurations

### 1. Environment Variables Setup

For production, create a `.env` file or configure these environment variables:

```bash
# Database Configuration
export DB_HOST="localhost"
export DB_USER="your_db_user"
export DB_PASS="your_secure_password"
export DB_NAME="gym_management"

# JWT Secret Key (generate a strong random key)
export JWT_SECRET="your-very-long-random-secret-key-at-least-64-characters"
```

#### Generate a Strong JWT Secret:
```bash
# Linux/Mac
openssl rand -base64 64

# Or use PHP
php -r "echo bin2hex(random_bytes(32));"
```

### 2. CORS Configuration

**For Development (testing):**
- The default `*` allows all origins - this is OK for development

**For Production:**
Edit `backend/config/cors.php`:

```php
$allowed_origins = [
    'https://yourdomain.com',
    'https://www.yourdomain.com',
    'https://app.yourdomain.com'
];
```

### 3. Database Credentials

**NEVER commit database credentials to version control!**

Two options:

#### Option A: Environment Variables (Recommended)
The code now supports environment variables. Set them in your hosting environment.

#### Option B: External Config File
1. Create `backend/config/database.local.php`:
```php
<?php
define('DB_HOST', 'localhost');
define('DB_USER', 'your_user');
define('DB_PASS', 'your_password');
define('DB_NAME', 'gym_management');
```

2. Add to `.gitignore`:
```
backend/config/database.local.php
```

3. Modify `database.php` to include it:
```php
if (file_exists(__DIR__ . '/database.local.php')) {
    require_once __DIR__ . '/database.local.php';
} else {
    // Use defaults or environment variables
}
```

### 4. Error Reporting

#### Development:
```php
// In php.ini or at the top of your scripts
error_reporting(E_ALL);
ini_set('display_errors', 1);
```

#### Production:
```php
// In php.ini
display_errors = Off
log_errors = On
error_log = /path/to/php-error.log
```

The code now logs errors server-side instead of exposing them to clients.

### 5. Database User Permissions

Create a separate database user with minimal permissions:

```sql
-- Create user
CREATE USER 'gym_app'@'localhost' IDENTIFIED BY 'strong_password_here';

-- Grant only necessary permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON gym_management.* TO 'gym_app'@'localhost';

-- DO NOT grant: DROP, CREATE, ALTER, INDEX, etc.
FLUSH PRIVILEGES;
```

### 6. File Permissions

```bash
# Set owner to web server user
sudo chown -R www-data:www-data /path/to/backend

# Directories: 755 (rwxr-xr-x)
sudo find /path/to/backend -type d -exec chmod 755 {} \;

# Files: 644 (rw-r--r--)
sudo find /path/to/backend -type f -exec chmod 644 {} \;

# Config files: 640 (rw-r-----)
sudo chmod 640 /path/to/backend/config/*.php

# Upload directories: 775 (rwxrwxr-x) if needed
sudo chmod 775 /path/to/backend/uploads
```

### 7. HTTPS Configuration

**ALWAYS use HTTPS in production!**

#### Apache:
```apache
<VirtualHost *:443>
    ServerName yourdomain.com
    DocumentRoot /var/www/html
    
    SSLEngine on
    SSLCertificateFile /path/to/cert.pem
    SSLCertificateKeyFile /path/to/key.pem
    
    # Redirect HTTP to HTTPS
    <VirtualHost *:80>
        ServerName yourdomain.com
        Redirect permanent / https://yourdomain.com/
    </VirtualHost>
</VirtualHost>
```

#### Nginx:
```nginx
server {
    listen 443 ssl;
    server_name yourdomain.com;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    # Redirect HTTP to HTTPS
    server {
        listen 80;
        server_name yourdomain.com;
        return 301 https://$server_name$request_uri;
    }
}
```

### 8. Rate Limiting

Implement rate limiting to prevent abuse:

#### Apache (mod_ratelimit):
```apache
<Location "/api/">
    SetOutputFilter RATE_LIMIT
    SetEnv rate-limit 400
</Location>
```

#### Nginx:
```nginx
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;

location /api/ {
    limit_req zone=api burst=20;
}
```

### 9. SQL Injection Prevention

✅ **Already Implemented:** All queries use prepared statements.

**Do NOT change to string concatenation!**

❌ Bad:
```php
$sql = "SELECT * FROM users WHERE username = '$username'";
```

✅ Good (current implementation):
```php
$sql = "SELECT * FROM users WHERE username = ?";
$stmt->bind_param('s', $username);
```

### 10. Change Default Credentials

**Immediately after setup:**

```sql
-- Generate new password hash
-- In PHP: password_hash('your_new_password', PASSWORD_BCRYPT);

UPDATE users 
SET password = '$2y$10$your_new_hashed_password' 
WHERE username = 'admin';
```

Or use a PHP script:
```php
<?php
$new_password = 'your_secure_password';
$hash = password_hash($new_password, PASSWORD_BCRYPT);
echo "New hash: " . $hash;
```

### 11. Input Validation

✅ **Already Implemented:** Date validation, type checking, etc.

**Always validate user input:**
- Date formats
- Numeric values
- Email formats
- Phone numbers
- Required fields

### 12. Session Security

If implementing web sessions (not needed for API):

```php
// In php.ini
session.cookie_httponly = 1
session.cookie_secure = 1
session.use_strict_mode = 1
session.cookie_samesite = "Strict"
```

### 13. Security Headers

Add these headers for web security:

```php
header('X-Content-Type-Options: nosniff');
header('X-Frame-Options: DENY');
header('X-XSS-Protection: 1; mode=block');
header('Strict-Transport-Security: max-age=31536000');
header('Content-Security-Policy: default-src \'self\'');
```

### 14. Backup Strategy

**Regular backups are critical!**

```bash
# Daily database backup
mysqldump -u root -p gym_management > backup_$(date +%Y%m%d).sql

# Keep last 30 days
find /path/to/backups -name "backup_*.sql" -mtime +30 -delete
```

### 15. Monitoring

**Set up monitoring for:**
- Failed login attempts
- Unusual API usage patterns
- Database errors
- Server errors (500s)
- Slow queries

### 16. API Key Alternative (Optional)

For machine-to-machine communication, consider adding API keys:

```sql
CREATE TABLE api_keys (
    id INT AUTO_INCREMENT PRIMARY KEY,
    key_hash VARCHAR(255) NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL,
    status ENUM('active', 'inactive') DEFAULT 'active'
);
```

## Security Checklist for Production

- [ ] Change default admin password
- [ ] Set JWT_SECRET environment variable
- [ ] Configure CORS for specific domains
- [ ] Use separate database user with minimal permissions
- [ ] Enable HTTPS
- [ ] Set proper file permissions
- [ ] Disable error display, enable error logging
- [ ] Implement rate limiting
- [ ] Set up automated backups
- [ ] Configure security headers
- [ ] Set up monitoring and logging
- [ ] Test all endpoints with security tools
- [ ] Regular security audits
- [ ] Keep PHP and MySQL updated

## Security Testing Tools

1. **OWASP ZAP** - Automated security testing
2. **Burp Suite** - Manual security testing
3. **SQLMap** - SQL injection testing (should find none!)
4. **Postman** - API testing with various inputs

## Common Vulnerabilities Prevented

✅ **SQL Injection** - Using prepared statements
✅ **XSS** - JSON API doesn't render HTML
✅ **Authentication** - JWT token with expiration
✅ **Authorization** - Role-based access control
✅ **Information Disclosure** - Generic error messages
✅ **CSRF** - Stateless API design

## Need Help?

Refer to:
- OWASP Top 10: https://owasp.org/www-project-top-ten/
- PHP Security Best Practices
- Database Security Guidelines

## Regular Maintenance

- Update PHP regularly
- Update MySQL regularly
- Review logs weekly
- Rotate JWT secrets quarterly
- Update dependencies
- Security audit annually

---

**Remember: Security is an ongoing process, not a one-time setup!**
