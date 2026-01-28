<?php
/**
 * List Members API
 * Endpoint: GET /api/members/list.php
 * Query Params: page, limit, search, status
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
$search = isset($_GET['search']) ? trim($_GET['search']) : '';
$status = isset($_GET['status']) ? $_GET['status'] : '';

$offset = ($page - 1) * $limit;

// Build query
$conditions = [];
$params = [];

if (!empty($search)) {
    $conditions[] = "(m.member_code LIKE ? OR m.full_name LIKE ? OR m.phone LIKE ? OR m.identity_number LIKE ?)";
    $searchTerm = "%{$search}%";
    $params[] = $searchTerm;
    $params[] = $searchTerm;
    $params[] = $searchTerm;
    $params[] = $searchTerm;
}

if (!empty($status) && in_array($status, ['active', 'inactive'])) {
    $conditions[] = "m.status = ?";
    $params[] = $status;
}

$whereClause = !empty($conditions) ? 'WHERE ' . implode(' AND ', $conditions) : '';

// Get total count
$countSql = "SELECT COUNT(*) as total FROM members m {$whereClause}";
$countResult = fetchOne($conn, $countSql, $params);
$totalRecords = $countResult ? $countResult['total'] : 0;

// Get members
$sql = "SELECT m.id, m.member_code, m.full_name, m.nickname, m.phone, 
               m.birth_date, m.status, m.created_at,
               k.name as kabupaten_name, kec.name as kecamatan_name, kel.name as kelurahan_name
        FROM members m
        LEFT JOIN kabupaten k ON m.kabupaten_id = k.id
        LEFT JOIN kecamatan kec ON m.kecamatan_id = kec.id
        LEFT JOIN kelurahan kel ON m.kelurahan_id = kel.id
        {$whereClause}
        ORDER BY m.created_at DESC
        LIMIT ? OFFSET ?";

$params[] = $limit;
$params[] = $offset;

$result = executeQuery($conn, $sql, $params);

if (!$result['success']) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Failed to fetch members'
    ]);
    closeConnection($conn);
    exit();
}

$members = [];
while ($row = $result['result']->fetch_assoc()) {
    $members[] = $row;
}

// Calculate pagination
$totalPages = ceil($totalRecords / $limit);

echo json_encode([
    'success' => true,
    'data' => [
        'members' => $members,
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
