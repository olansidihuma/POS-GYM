<?php
/**
 * List Attendance API
 * Endpoint: GET /api/attendance/list.php
 * Query Params: page, limit, date_from, date_to, attendance_type, member_id
 */

require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../config/auth.php';

// Authenticate user
$user = authenticate();

// Get database connection
$conn = getConnection();

// Get query parameters
$page = isset($_GET['page']) ? max(1, intval($_GET['page'])) : 1;
$limit = isset($_GET['limit']) ? max(1, min(100, intval($_GET['limit']))) : 20;
$dateFrom = isset($_GET['date_from']) ? $_GET['date_from'] : date('Y-m-d');
$dateTo = isset($_GET['date_to']) ? $_GET['date_to'] : date('Y-m-d');
$attendanceType = isset($_GET['attendance_type']) ? $_GET['attendance_type'] : '';
$memberId = isset($_GET['member_id']) ? intval($_GET['member_id']) : 0;

$offset = ($page - 1) * $limit;

// Build query
$conditions = ["DATE(a.check_in_time) BETWEEN ? AND ?"];
$params = [$dateFrom, $dateTo];

if (!empty($attendanceType) && in_array($attendanceType, ['member', 'non_member'])) {
    $conditions[] = "a.attendance_type = ?";
    $params[] = $attendanceType;
}

if ($memberId > 0) {
    $conditions[] = "a.member_id = ?";
    $params[] = $memberId;
}

$whereClause = 'WHERE ' . implode(' AND ', $conditions);

// Get total count
$countSql = "SELECT COUNT(*) as total FROM attendances a {$whereClause}";
$countResult = fetchOne($conn, $countSql, $params);
$totalRecords = $countResult ? $countResult['total'] : 0;

// Get attendances
$sql = "SELECT a.*, m.member_code, m.full_name as member_name, u.full_name as created_by_name
        FROM attendances a
        LEFT JOIN members m ON a.member_id = m.id
        LEFT JOIN users u ON a.created_by = u.id
        {$whereClause}
        ORDER BY a.check_in_time DESC
        LIMIT ? OFFSET ?";

$params[] = $limit;
$params[] = $offset;

$result = executeQuery($conn, $sql, $params);

if (!$result['success']) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Failed to fetch attendances'
    ]);
    closeConnection($conn);
    exit();
}

$attendances = [];
while ($row = $result['result']->fetch_assoc()) {
    $attendances[] = $row;
}

// Calculate pagination
$totalPages = ceil($totalRecords / $limit);

echo json_encode([
    'success' => true,
    'data' => [
        'attendances' => $attendances,
        'pagination' => [
            'current_page' => $page,
            'total_pages' => $totalPages,
            'total_records' => $totalRecords,
            'limit' => $limit
        ]
    ]
]);

closeConnection($conn);
?>
