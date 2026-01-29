<?php
/**
 * List Incomes API
 * Endpoint: GET /api/incomes/list.php
 * Admin only
 * Query Params: page, limit, date_from, date_to, income_type_id
 */

require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../config/auth.php';

// Authenticate user
$user = authenticate();

// Check admin role
requireAdmin($user);

// Get database connection
$conn = getConnection();

// Get query parameters
$page = isset($_GET['page']) ? max(1, intval($_GET['page'])) : 1;
$limit = isset($_GET['limit']) ? max(1, min(100, intval($_GET['limit']))) : 20;
$dateFrom = isset($_GET['date_from']) ? $_GET['date_from'] : '';
$dateTo = isset($_GET['date_to']) ? $_GET['date_to'] : '';
$incomeTypeId = isset($_GET['income_type_id']) ? intval($_GET['income_type_id']) : 0;

$offset = ($page - 1) * $limit;

// Build query
$conditions = [];
$params = [];

if (!empty($dateFrom) && !empty($dateTo)) {
    $conditions[] = "i.income_date BETWEEN ? AND ?";
    $params[] = $dateFrom;
    $params[] = $dateTo;
}

if ($incomeTypeId > 0) {
    $conditions[] = "i.income_type_id = ?";
    $params[] = $incomeTypeId;
}

$whereClause = !empty($conditions) ? 'WHERE ' . implode(' AND ', $conditions) : '';

// Get total count
$countSql = "SELECT COUNT(*) as total FROM incomes i {$whereClause}";
$countResult = fetchOne($conn, $countSql, $params);
$totalRecords = $countResult ? $countResult['total'] : 0;

// Get total amount
$sumSql = "SELECT COALESCE(SUM(i.amount), 0) as total_amount FROM incomes i {$whereClause}";
$sumResult = fetchOne($conn, $sumSql, $params);
$totalAmount = $sumResult ? floatval($sumResult['total_amount']) : 0;

// Get incomes
$sql = "SELECT i.*, it.name as income_type_name, u.full_name as created_by_name
        FROM incomes i
        INNER JOIN income_types it ON i.income_type_id = it.id
        INNER JOIN users u ON i.created_by = u.id
        {$whereClause}
        ORDER BY i.income_date DESC, i.created_at DESC
        LIMIT ? OFFSET ?";

$params[] = $limit;
$params[] = $offset;

$result = executeQuery($conn, $sql, $params);

if (!$result['success']) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Failed to fetch incomes'
    ], JSON_NUMERIC_CHECK);
    closeConnection($conn);
    exit();
}

$incomes = [];
while ($row = $result['result']->fetch_assoc()) {
    $incomes[] = $row;
}

// Calculate pagination
$totalPages = ceil($totalRecords / $limit);

echo json_encode([
    'success' => true,
    'data' => [
        'incomes' => $incomes,
        'total_amount' => $totalAmount,
        'pagination' => [
            'current_page' => $page,
            'total_pages' => $totalPages,
            'total_records' => $totalRecords,
            'limit' => $limit
        ]
    ]
], JSON_NUMERIC_CHECK);

closeConnection($conn);
?>
