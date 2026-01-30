<?php
/**
 * Check-out Attendance API
 * Endpoint: POST /api/attendance/checkout.php
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
if (!isset($input['attendance_id']) || empty($input['attendance_id'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Attendance ID is required'
    ], JSON_NUMERIC_CHECK);
    exit();
}

$attendanceId = intval($input['attendance_id']);

// Get database connection
$conn = getConnection();

// Check if attendance exists
$checkSql = "SELECT id, member_id, check_in_time FROM attendances WHERE id = ?";
$attendance = fetchOne($conn, $checkSql, [$attendanceId]);

if (!$attendance) {
    http_response_code(404);
    echo json_encode([
        'success' => false,
        'message' => 'Attendance record not found'
    ], JSON_NUMERIC_CHECK);
    closeConnection($conn);
    exit();
}

// Add check_out_time column if it doesn't exist (for legacy databases)
// Note: In production, this should be done via migration
// The column check is only performed once per database connection
static $columnChecked = false;
if (!$columnChecked) {
    $alterResult = $conn->query("SHOW COLUMNS FROM attendances LIKE 'check_out_time'");
    if ($alterResult->num_rows == 0) {
        $conn->query("ALTER TABLE attendances ADD COLUMN check_out_time TIMESTAMP NULL");
    }
    $columnChecked = true;
}

// Update checkout time
$updateSql = "UPDATE attendances SET check_out_time = NOW() WHERE id = ?";
$stmt = $conn->prepare($updateSql);
$stmt->bind_param('i', $attendanceId);

if (!$stmt->execute()) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Failed to update checkout time'
    ], JSON_NUMERIC_CHECK);
    $stmt->close();
    closeConnection($conn);
    exit();
}
$stmt->close();

// Fetch updated attendance
$fetchSql = "SELECT a.*, m.member_code, m.full_name as member_name,
             TIMESTAMPDIFF(MINUTE, a.check_in_time, a.check_out_time) as duration_minutes
             FROM attendances a
             LEFT JOIN members m ON a.member_id = m.id
             WHERE a.id = ?";
$updatedAttendance = fetchOne($conn, $fetchSql, [$attendanceId]);

echo json_encode([
    'success' => true,
    'message' => 'Check-out successful',
    'data' => $updatedAttendance
], JSON_NUMERIC_CHECK);

closeConnection($conn);
?>
