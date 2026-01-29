<?php
/**
 * Check-in Attendance API
 * Endpoint: POST /api/attendance/checkin.php
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

// Validate required fields
if (!isset($input['attendance_type']) || empty($input['attendance_type'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Attendance type is required'
    ], JSON_NUMERIC_CHECK);
    exit();
}

$attendanceType = $input['attendance_type'];

if (!in_array($attendanceType, ['member', 'non_member'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Invalid attendance type'
    ], JSON_NUMERIC_CHECK);
    exit();
}

// Get database connection
$conn = getConnection();

$memberId = null;
$amount = 0;
$paymentMethod = null;

// Validate member attendance
if ($attendanceType === 'member') {
    if (!isset($input['member_id']) || empty($input['member_id'])) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Member ID is required for member attendance'
        ], JSON_NUMERIC_CHECK);
        closeConnection($conn);
        exit();
    }

    $memberId = intval($input['member_id']);
    
    // Validate member exists and is active
    $memberSql = "SELECT id, full_name, status FROM members WHERE id = ?";
    $member = fetchOne($conn, $memberSql, [$memberId]);

    if (!$member) {
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'message' => 'Member not found'
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

    // Check if member has active subscription
    $subSql = "SELECT id FROM membership_subscriptions 
               WHERE member_id = ? AND status = 'active' AND end_date >= CURDATE()";
    $subscription = fetchOne($conn, $subSql, [$memberId]);

    if (!$subscription) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Member does not have an active subscription'
        ], JSON_NUMERIC_CHECK);
        closeConnection($conn);
        exit();
    }
} else {
    // Non-member attendance requires payment
    if (!isset($input['payment_method']) || empty($input['payment_method'])) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Payment method is required for non-member attendance'
        ], JSON_NUMERIC_CHECK);
        closeConnection($conn);
        exit();
    }

    // Get non-member fee
    $feeSql = "SELECT amount FROM attendance_fees WHERE status = 'active' LIMIT 1";
    $fee = fetchOne($conn, $feeSql);

    if (!$fee) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Attendance fee not configured'
        ], JSON_NUMERIC_CHECK);
        closeConnection($conn);
        exit();
    }

    $amount = $fee['amount'];
    $paymentMethod = $input['payment_method'];
}

// Prepare insert data
$notes = isset($input['notes']) ? trim($input['notes']) : null;
$createdBy = $user['user_id'];

// Insert attendance
$sql = "INSERT INTO attendances (member_id, attendance_type, amount, payment_method, notes, created_by)
        VALUES (?, ?, ?, ?, ?, ?)";

$stmt = $conn->prepare($sql);
$stmt->bind_param('isdssi', $memberId, $attendanceType, $amount, $paymentMethod, $notes, $createdBy);

if (!$stmt->execute()) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Failed to record attendance: ' . $stmt->error
    ], JSON_NUMERIC_CHECK);
    $stmt->close();
    closeConnection($conn);
    exit();
}

$attendanceId = $conn->insert_id;
$stmt->close();

// Fetch created attendance
$fetchSql = "SELECT a.*, m.member_code, m.full_name as member_name, u.full_name as created_by_name
             FROM attendances a
             LEFT JOIN members m ON a.member_id = m.id
             LEFT JOIN users u ON a.created_by = u.id
             WHERE a.id = ?";
$attendance = fetchOne($conn, $fetchSql, [$attendanceId]);

echo json_encode([
    'success' => true,
    'message' => 'Attendance recorded successfully',
    'data' => $attendance
], JSON_NUMERIC_CHECK);

closeConnection($conn);
?>
