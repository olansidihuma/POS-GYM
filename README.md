📌 GitHub Copilot Prompt – Flutter Gym Management App
Project Goal

Create a production-ready Flutter Android application using GetX for state management and routing, Dio for API communication, SharedPreferences for authentication persistence, and MySQL database with PHP Native (procedural) backend API.

The application must be fully dynamic, consume real data from API/database (no dummy or hardcoded data), and be responsive:

Phone → Portrait

Tablet → Landscape

🧱 Tech Stack

Flutter (latest stable)

GetX (state management, dependency injection, routing)

Dio (REST API client)

SharedPreferences (auth/session storage)

PHP Native (Procedural) REST API

MySQL Database

Bluetooth Thermal Printer 58mm

QR Code Scanner & Generator

Camera Access (QRIS / Transfer Proof)

🔐 Authentication & Role

Role-based login

Admin → Full access

Pegawai → Limited access

Secure token-based authentication

Auto-login using SharedPreferences

Middleware/route guard based on role

👤 Member Management (Gym)

Member registration form with fields:

Nama lengkap

Nama panggilan

Alamat / Dukuh

RT / RW

Kabupaten (dynamic from API)

Kecamatan (dynamic, depends on kabupaten)

Kelurahan (dynamic, depends on kecamatan)

Tempat lahir

Tanggal lahir

No telepon

No identitas

Nama kontak darurat

No telepon kontak darurat

💳 Membership Subscription

New Member

Rp45.000 / 1 year (dynamic from database)

Renewal

Rp35.000 / 1 year (dynamic from database)

Automatic expiry date calculation

History of membership payments

🪪 Member Card & QR Code

Generate member card (card size)

Card background uploadable by admin

Card content:

Member Name

Member ID

QR Code

Card Settings Menu

Adjust QR position & size

Adjust text position

Export card as image

Share card image directly to WhatsApp using member phone number

🧾 Attendance System

Member Attendance

Scan QR Code from member card

Non-member Attendance

Rp15.000 per visit (dynamic from database)

Attendance history

Daily attendance summary

🍔 F&B Sales (POS System)

Features:

Product categories (dynamic)

Products (dynamic)

Price per product

Discount per product

Service charge (%)

Tax (%)

Product notes

Transaction notes

Hold transaction

List & recall held transactions

Split bill

Transaction-level discount

Payment methods:

Cash

Bank Transfer / QRIS (with camera capture)

Print receipt to Bluetooth Thermal Printer 58mm

🖨️ Printer & Receipt Settings

Bluetooth printer connection settings

Receipt configuration:

Logo upload

Shop name

Address

Footer note

Preview receipt

Persistent printer configuration

💸 Expense Management (Admin Only)

Nominal

Date

Expense type

Additional notes

💰 Income Management (Admin Only)

Nominal

Date

Income type

Additional notes

📊 Financial Report

Simple Profit & Loss Report

Filter by date range

Export:

PDF

Excel

Admin access only

⚙️ Master Data Management

CRUD & status control for:

Products

Product categories

Users

Roles / Jabatan

Enable / Disable data (soft delete)

🧠 Development Rules

Build file-by-file with clean architecture

Separate:

UI

Controller

Service/API

Model

Use reusable widgets

Error handling & loading states

Clean, scalable, and maintainable code

No prototype-level code – must be production-ready

All numeric values (prices, fees, durations) must come from API/database

Fully dynamic dropdowns & lists from API

🎯 Output Expectation

A complete, scalable, real-world Gym Management Application, ready for deployment and future feature expansion.
