-- Gym Management Application Database Schema
-- MySQL Database

-- Create Database
CREATE DATABASE IF NOT EXISTS gym_management CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE gym_management;

-- Table: roles
CREATE TABLE roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: users
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100),
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    role_id INT NOT NULL,
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(id)
);

-- Table: provinsi
CREATE TABLE provinsi (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    status ENUM('active', 'inactive') DEFAULT 'active'
);

-- Table: regions (kabupaten)
CREATE TABLE kabupaten (
    id INT AUTO_INCREMENT PRIMARY KEY,
    provinsi_id INT,
    name VARCHAR(100) NOT NULL,
    status ENUM('active', 'inactive') DEFAULT 'active',
    FOREIGN KEY (provinsi_id) REFERENCES provinsi(id)
);

-- Table: kecamatan
CREATE TABLE kecamatan (
    id INT AUTO_INCREMENT PRIMARY KEY,
    kabupaten_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    status ENUM('active', 'inactive') DEFAULT 'active',
    FOREIGN KEY (kabupaten_id) REFERENCES kabupaten(id)
);

-- Table: kelurahan
CREATE TABLE kelurahan (
    id INT AUTO_INCREMENT PRIMARY KEY,
    kecamatan_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    status ENUM('active', 'inactive') DEFAULT 'active',
    FOREIGN KEY (kecamatan_id) REFERENCES kecamatan(id)
);

-- Table: members
CREATE TABLE members (
    id INT AUTO_INCREMENT PRIMARY KEY,
    member_code VARCHAR(20) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    nickname VARCHAR(50),
    address VARCHAR(255),
    dukuh VARCHAR(100),
    rt VARCHAR(10),
    rw VARCHAR(10),
    kabupaten_id INT,
    kecamatan_id INT,
    kelurahan_id INT,
    birth_place VARCHAR(100),
    birth_date DATE,
    phone VARCHAR(20),
    identity_number VARCHAR(50),
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (kabupaten_id) REFERENCES kabupaten(id),
    FOREIGN KEY (kecamatan_id) REFERENCES kecamatan(id),
    FOREIGN KEY (kelurahan_id) REFERENCES kelurahan(id)
);

-- Table: membership_types
CREATE TABLE membership_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    duration_days INT NOT NULL DEFAULT 365,
    description TEXT,
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: membership_subscriptions
CREATE TABLE membership_subscriptions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    membership_type_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_method ENUM('cash', 'transfer', 'qris') DEFAULT 'cash',
    payment_proof VARCHAR(255),
    status ENUM('active', 'expired', 'cancelled') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (member_id) REFERENCES members(id),
    FOREIGN KEY (membership_type_id) REFERENCES membership_types(id)
);

-- Table: attendance_fees
CREATE TABLE attendance_fees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: attendances
CREATE TABLE attendances (
    id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT,
    attendance_type ENUM('member', 'non_member') NOT NULL,
    check_in_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10, 2) DEFAULT 0,
    payment_method ENUM('cash', 'transfer', 'qris'),
    notes TEXT,
    created_by INT,
    FOREIGN KEY (member_id) REFERENCES members(id),
    FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Table: product_categories
CREATE TABLE product_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: products
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    discount DECIMAL(5, 2) DEFAULT 0,
    stock INT DEFAULT 0,
    description TEXT,
    image VARCHAR(255),
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES product_categories(id)
);

-- Table: transactions
CREATE TABLE transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_code VARCHAR(50) NOT NULL UNIQUE,
    subtotal DECIMAL(10, 2) NOT NULL,
    discount_amount DECIMAL(10, 2) DEFAULT 0,
    service_charge_percent DECIMAL(5, 2) DEFAULT 0,
    service_charge_amount DECIMAL(10, 2) DEFAULT 0,
    tax_percent DECIMAL(5, 2) DEFAULT 0,
    tax_amount DECIMAL(10, 2) DEFAULT 0,
    total_amount DECIMAL(10, 2) NOT NULL,
    payment_method ENUM('cash', 'transfer', 'qris') NOT NULL,
    payment_proof VARCHAR(255),
    payment_amount DECIMAL(10, 2) NOT NULL,
    change_amount DECIMAL(10, 2) DEFAULT 0,
    notes TEXT,
    status ENUM('pending', 'completed', 'cancelled') DEFAULT 'completed',
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Table: transaction_items
CREATE TABLE transaction_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id INT NOT NULL,
    product_id INT NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    discount DECIMAL(5, 2) DEFAULT 0,
    subtotal DECIMAL(10, 2) NOT NULL,
    notes TEXT,
    FOREIGN KEY (transaction_id) REFERENCES transactions(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Table: held_transactions
CREATE TABLE held_transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    hold_name VARCHAR(100) NOT NULL,
    transaction_data TEXT NOT NULL,
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Table: expense_types
CREATE TABLE expense_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: expenses
CREATE TABLE expenses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    expense_type_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    expense_date DATE NOT NULL,
    notes TEXT,
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (expense_type_id) REFERENCES expense_types(id),
    FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Table: income_types
CREATE TABLE income_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: incomes
CREATE TABLE incomes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    income_type_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    income_date DATE NOT NULL,
    notes TEXT,
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (income_type_id) REFERENCES income_types(id),
    FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Table: settings
CREATE TABLE settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT,
    description TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: member_cards
CREATE TABLE member_cards (
    id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL UNIQUE,
    card_background VARCHAR(255),
    qr_position_x INT DEFAULT 0,
    qr_position_y INT DEFAULT 0,
    qr_size INT DEFAULT 100,
    text_position_x INT DEFAULT 0,
    text_position_y INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (member_id) REFERENCES members(id)
);

-- Insert default roles
INSERT INTO roles (name) VALUES ('Admin'), ('Pegawai');

-- Insert default admin user (password: admin123)
INSERT INTO users (username, password, full_name, role_id) 
VALUES ('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Administrator', 1);

-- Insert default membership types
INSERT INTO membership_types (name, price, duration_days, description) VALUES
('New Member', 45000.00, 365, 'Membership for new members - 1 year'),
('Renewal', 35000.00, 365, 'Membership renewal - 1 year');

-- Insert default attendance fee
INSERT INTO attendance_fees (name, amount) VALUES
('Non-Member Visit', 15000.00);

-- Insert default expense types
INSERT INTO expense_types (name) VALUES
('Utilities'),
('Maintenance'),
('Supplies'),
('Salaries'),
('Other');

-- Insert default income types
INSERT INTO income_types (name) VALUES
('Membership Fee'),
('Attendance Fee'),
('F&B Sales'),
('Other');

-- Insert default settings
INSERT INTO settings (setting_key, setting_value, description) VALUES
('shop_name', 'Gym Management', 'Shop name for receipts'),
('shop_address', '', 'Shop address for receipts'),
('shop_phone', '', 'Shop phone for receipts'),
('receipt_footer', 'Thank you for your visit!', 'Receipt footer text'),
('receipt_logo', '', 'Receipt logo path'),
('service_charge_percent', '5', 'Default service charge percentage'),
('tax_percent', '10', 'Default tax percentage');

-- Sample regional data (you can add more based on your region)
INSERT INTO provinsi (name) VALUES
('DKI Jakarta'),
('Jawa Barat'),
('Jawa Tengah'),
('Jawa Timur'),
('Banten');

INSERT INTO kabupaten (provinsi_id, name) VALUES
(1, 'Jakarta Pusat'),
(1, 'Jakarta Utara'),
(1, 'Jakarta Selatan'),
(1, 'Jakarta Timur'),
(1, 'Jakarta Barat'),
(2, 'Bandung'),
(2, 'Bekasi'),
(2, 'Bogor');

INSERT INTO kecamatan (kabupaten_id, name) VALUES
(1, 'Tanah Abang'),
(1, 'Menteng'),
(2, 'Kelapa Gading'),
(3, 'Kebayoran Baru'),
(6, 'Coblong'),
(6, 'Bandung Wetan');

INSERT INTO kelurahan (kecamatan_id, name) VALUES
(1, 'Kebon Kacang'),
(1, 'Petamburan'),
(2, 'Menteng'),
(3, 'Kelapa Gading Barat'),
(5, 'Dago'),
(5, 'Sekeloa');
