<?php
/**
 * QR Code Scan for Attendance API
 * Endpoint: POST /api/attendance/scan-qr.php
 * This endpoint processes QR code scans and automatically checks in members
 */

require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../config/auth.php';

// Authenticate user
$user = authenticate();

// Only accept POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Method not allowed'
    ], JSON_NUMERIC_CHECK);
    exit();
}

// Get JSON input
$input = json_decode(file_get_contents('php://input'), true);

// Validate QR code
if (!isset($input['qr_code']) || empty($input['qr_code'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'QR code is required'
    ], JSON_NUMERIC_CHECK);
    exit();
}

$qrCode = trim($input['qr_code']);

// Get database connection
$conn = getConnection();

// Find member by QR code (member_code)
$memberSql = "SELECT id, member_code, full_name, phone, status FROM members WHERE member_code = ?";
$member = fetchOne($conn, $memberSql, [$qrCode]);

if (!$member) {
    http_response_code(404);
    echo json_encode([
        'success' => false,
        'message' => 'Member not found with this QR code'
    ], JSON_NUMERIC_CHECK);
    closeConnection($conn);
    exit();
}

if ($member['status'] !== 'active') {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Member is inactive'
    ], JSON_NUMERIC_CHECK);
    closeConnection($conn);
    exit();
}

$memberId = $member['id'];

// Check if member has active subscription
$subSql = "SELECT id, end_date FROM membership_subscriptions 
           WHERE member_id = ? AND status = 'active' AND end_date >= CURDATE()
           ORDER BY end_date DESC LIMIT 1";
$subscription = fetchOne($conn, $subSql, [$memberId]);

if (!$subscription) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Member does not have an active subscription',
        'data' => [
            'member' => $member,
            'subscription_status' => 'expired'
        ]
    ], JSON_NUMERIC_CHECK);
    closeConnection($conn);
    exit();
}

// Check if already checked in today (and not checked out)
$todayCheckSql = "SELECT id FROM attendances 
                  WHERE member_id = ? 
                  AND DATE(check_in_time) = CURDATE()
                  AND attendance_type = 'member'";
$existingCheckin = fetchOne($conn, $todayCheckSql, [$memberId]);

if ($existingCheckin) {
    // Already checked in today
    echo json_encode([
        'success' => true,
        'message' => 'Member already checked in today. Welcome back!',
        'data' => [
            'member' => $member,
            'already_checked_in' => true,
            'subscription_end_date' => $subscription['end_date']
        ]
    ], JSON_NUMERIC_CHECK);
    closeConnection($conn);
    exit();
}

// Record new check-in
$createdBy = $user['user_id'];
$insertSql = "INSERT INTO attendances (member_id, attendance_type, amount, created_by)
              VALUES (?, 'member', 0, ?)";

$stmt = $conn->prepare($insertSql);
$stmt->bind_param('ii', $memberId, $createdBy);

if (!$stmt->execute()) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Failed to record attendance'
    ], JSON_NUMERIC_CHECK);
    $stmt->close();
    closeConnection($conn);
    exit();
}

$attendanceId = $conn->insert_id;
$stmt->close();

// Fetch created attendance
$fetchSql = "SELECT a.*, m.member_code, m.full_name as member_name
             FROM attendances a
             LEFT JOIN members m ON a.member_id = m.id
             WHERE a.id = ?";
$attendance = fetchOne($conn, $fetchSql, [$attendanceId]);

echo json_encode([
    'success' => true,
    'message' => 'Check-in successful! Welcome, ' . $member['full_name'],
    'data' => [
        'member' => $member,
        'attendance' => $attendance,
        'subscription_end_date' => $subscription['end_date']
    ]
], JSON_NUMERIC_CHECK);

closeConnection($conn);
?>
