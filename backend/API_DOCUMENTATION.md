# Gym Management API Documentation

## Overview
This is a comprehensive REST API for a Gym Management application built with PHP and MySQL. All endpoints return JSON responses and require authentication except for login.

## Base URL
```
http://your-domain.com/backend/api/
```

## Authentication
All endpoints (except login) require a Bearer token in the Authorization header:
```
Authorization: Bearer {token}
```

## Standard Response Format
### Success Response
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { ... }
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error description"
}
```

---

## API Endpoints

### 1. Authentication

#### Login
- **Endpoint:** `POST /auth/login.php`
- **Auth Required:** No
- **Body:**
  ```json
  {
    "username": "admin",
    "password": "admin123"
  }
  ```
- **Success Response:**
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

---

### 2. Members API

#### List Members
- **Endpoint:** `GET /members/list.php`
- **Query Params:** 
  - `page` (default: 1)
  - `limit` (default: 20, max: 100)
  - `search` (search by code, name, phone, ID number)
  - `status` (active/inactive)

#### Create Member
- **Endpoint:** `POST /members/create.php`
- **Body:**
  ```json
  {
    "full_name": "John Doe",
    "nickname": "John",
    "phone": "081234567890",
    "address": "Jl. Example Street",
    "dukuh": "Dukuh Name",
    "rt": "01",
    "rw": "02",
    "kabupaten_id": 1,
    "kecamatan_id": 1,
    "kelurahan_id": 1,
    "birth_place": "Jakarta",
    "birth_date": "1990-01-01",
    "identity_number": "1234567890123456",
    "emergency_contact_name": "Jane Doe",
    "emergency_contact_phone": "081234567891"
  }
  ```

#### Update Member
- **Endpoint:** `PUT /members/update.php`
- **Body:** Same as create with additional `id` field

#### Delete Member (Soft Delete)
- **Endpoint:** `DELETE /members/delete.php`
- **Body:**
  ```json
  {
    "id": 1
  }
  ```

#### Get Member Detail
- **Endpoint:** `GET /members/detail.php?id=1`
- **Returns:** Member info with active subscription and total visits

---

### 3. Membership API

#### Get Membership Types
- **Endpoint:** `GET /membership/types.php`
- **Returns:** List of active membership types with prices and duration

#### Create Subscription
- **Endpoint:** `POST /membership/subscribe.php`
- **Body:**
  ```json
  {
    "member_id": 1,
    "membership_type_id": 1,
    "payment_method": "cash",
    "payment_proof": "proof.jpg",
    "start_date": "2024-01-01"
  }
  ```
- **Note:** Auto-expires previous active subscription

#### Get Subscription History
- **Endpoint:** `GET /membership/history.php?member_id=1`
- **Returns:** All subscriptions for a member

#### Check Membership Status
- **Endpoint:** `GET /membership/check_status.php?member_id=1`
- **Returns:** Current membership status (active/expired) with details

---

### 4. Attendance API

#### Check-in
- **Endpoint:** `POST /attendance/checkin.php`
- **Member Check-in:**
  ```json
  {
    "attendance_type": "member",
    "member_id": 1,
    "notes": "Optional notes"
  }
  ```
- **Non-Member Check-in:**
  ```json
  {
    "attendance_type": "non_member",
    "payment_method": "cash",
    "notes": "Optional notes"
  }
  ```

#### List Attendance
- **Endpoint:** `GET /attendance/list.php`
- **Query Params:**
  - `page`, `limit`
  - `date_from`, `date_to`
  - `attendance_type` (member/non_member)
  - `member_id`

#### Attendance Summary
- **Endpoint:** `GET /attendance/summary.php`
- **Query Params:**
  - `date` (YYYY-MM-DD or YYYY-MM)
  - `period` (daily/monthly)
- **Returns:** 
  - Daily: Summary with hourly breakdown
  - Monthly: Summary with daily breakdown

---

### 5. POS API

#### Get Categories
- **Endpoint:** `GET /pos/categories.php`
- **Returns:** List of active product categories

#### Get Products
- **Endpoint:** `GET /pos/products.php`
- **Query Params:**
  - `category_id`
  - `search`
- **Returns:** Products with calculated final price after discount

#### Create Transaction
- **Endpoint:** `POST /pos/create_transaction.php`
- **Body:**
  ```json
  {
    "items": [
      {
        "product_id": 1,
        "quantity": 2,
        "notes": "Optional"
      }
    ],
    "discount_amount": 0,
    "payment_method": "cash",
    "payment_amount": 100000,
    "payment_proof": "proof.jpg",
    "notes": "Optional"
  }
  ```
- **Features:**
  - Auto-calculates service charge & tax from settings
  - Updates product stock
  - Transaction-safe (uses database transactions)

#### Hold Transaction
- **Endpoint:** `POST /pos/hold_transaction.php`
- **Body:**
  ```json
  {
    "hold_name": "Table 5",
    "transaction_data": { ... }
  }
  ```

#### Get Held Transactions
- **Endpoint:** `GET /pos/get_held.php`

#### Recall Held Transaction
- **Endpoint:** `POST /pos/recall_transaction.php`
- **Body:**
  ```json
  {
    "id": 1
  }
  ```

---

### 6. Expenses API (Admin Only)

#### Create Expense
- **Endpoint:** `POST /expenses/create.php`
- **Body:**
  ```json
  {
    "expense_type_id": 1,
    "amount": 50000,
    "expense_date": "2024-01-01",
    "notes": "Optional"
  }
  ```

#### List Expenses
- **Endpoint:** `GET /expenses/list.php`
- **Query Params:**
  - `page`, `limit`
  - `date_from`, `date_to`
  - `expense_type_id`
- **Returns:** Expenses with total amount

#### Get Expense Types
- **Endpoint:** `GET /expenses/types.php`

---

### 7. Incomes API (Admin Only)

#### Create Income
- **Endpoint:** `POST /incomes/create.php`
- **Body:**
  ```json
  {
    "income_type_id": 1,
    "amount": 100000,
    "income_date": "2024-01-01",
    "notes": "Optional"
  }
  ```

#### List Incomes
- **Endpoint:** `GET /incomes/list.php`
- **Query Params:**
  - `page`, `limit`
  - `date_from`, `date_to`
  - `income_type_id`
- **Returns:** Incomes with total amount

#### Get Income Types
- **Endpoint:** `GET /incomes/types.php`

---

### 8. Reports API (Admin Only)

#### Profit & Loss Report
- **Endpoint:** `GET /reports/profit_loss.php`
- **Query Params:**
  - `date_from` (default: first day of current month)
  - `date_to` (default: today)
- **Returns:**
  - Income/expense summary
  - Profit/loss calculation
  - Income breakdown (POS, membership, attendance, other)
  - Expense breakdown by type
  - Transaction statistics
  - Membership statistics
  - Attendance statistics
  - Top 10 selling products

---

### 9. Master Data API

#### Get Regions
- **Endpoint:** `GET /master/regions.php`
- **Query Params:**
  - `type` (kabupaten/kecamatan/kelurahan)
  - `kabupaten_id` (required for kecamatan)
  - `kecamatan_id` (required for kelurahan)
- **Examples:**
  - Get all kabupaten: `?type=kabupaten`
  - Get kecamatan: `?type=kecamatan&kabupaten_id=1`
  - Get kelurahan: `?type=kelurahan&kecamatan_id=1`

#### Settings
- **Get Settings:** `GET /master/settings.php`
- **Update Settings (Admin only):** `POST /master/settings.php`
  ```json
  {
    "settings": {
      "shop_name": "My Gym",
      "shop_address": "Jl. Example",
      "service_charge_percent": "5",
      "tax_percent": "10"
    }
  }
  ```

---

## Error Codes

- `400` - Bad Request (validation error)
- `401` - Unauthorized (invalid/missing token)
- `403` - Forbidden (insufficient permissions)
- `404` - Not Found
- `405` - Method Not Allowed
- `500` - Internal Server Error

---

## Security Features

1. **JWT Authentication** - Token-based authentication with 30-day expiration
2. **Role-Based Access Control** - Admin/Pegawai roles
3. **Prepared Statements** - All SQL queries use prepared statements to prevent SQL injection
4. **Input Validation** - All inputs are validated before processing
5. **CORS Headers** - Configured for Flutter app integration
6. **Database Transactions** - Critical operations use transactions for data integrity

---

## Database Schema Reference

### Main Tables
- `users` - System users with roles
- `members` - Gym members
- `membership_types` - Membership packages
- `membership_subscriptions` - Member subscriptions
- `attendances` - Check-in records
- `products` & `product_categories` - POS products
- `transactions` & `transaction_items` - POS transactions
- `expenses` & `expense_types` - Expense tracking
- `incomes` & `income_types` - Income tracking
- `kabupaten`, `kecamatan`, `kelurahan` - Region data
- `settings` - System settings
- `held_transactions` - Temporarily held POS transactions

---

## Default Credentials

**Admin Account:**
- Username: `admin`
- Password: `admin123`

**Note:** Change the default password after first login in production.

---

## Installation & Setup

1. Import the database schema from `backend/database/schema.sql`
2. Configure database connection in `backend/config/database.php`
3. Ensure PHP 7.4+ with mysqli extension
4. Set up proper file permissions
5. Configure CORS for your frontend domain (optional)

---

## Payment Methods

Supported payment methods across all APIs:
- `cash` - Cash payment
- `transfer` - Bank transfer
- `qris` - QRIS payment

---

## Member Code Generation

Format: `YYYY####` (e.g., 20240001, 20240002)
- YYYY: Current year
- ####: Sequential number (auto-generated)

---

## Transaction Code Generation

Format: `TRXYYYYMM####` (e.g., TRX202401001)
- YYYY: Year
- MM: Month
- ####: Sequential number (auto-generated)

---

## Notes

1. All datetime fields are in MySQL TIMESTAMP format
2. All monetary values are in DECIMAL(10, 2)
3. Pagination is available on list endpoints
4. Soft delete is used for members (status: inactive)
5. Auto-expiry for subscriptions when creating new one
6. Stock management is automatic on POS transactions
7. Service charge and tax are configurable via settings

---

## Support

For issues or questions, please contact the development team.
