<?php
/**
 * Create Income API
 * Endpoint: POST /api/incomes/create.php
 * Admin only
 */

require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../config/auth.php';

// Authenticate user
$user = authenticate();

// Check admin role
requireAdmin($user);

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
if (!isset($input['income_type_id']) || empty($input['income_type_id'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Income type is required'
    ], JSON_NUMERIC_CHECK);
    exit();
}

if (!isset($input['amount']) || $input['amount'] <= 0) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Valid amount is required'
    ], JSON_NUMERIC_CHECK);
    exit();
}

if (!isset($input['income_date']) || empty($input['income_date'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Income date is required'
    ], JSON_NUMERIC_CHECK);
    exit();
}

// Get database connection
$conn = getConnection();

// Validate income type exists
$typeId = intval($input['income_type_id']);
$typeSql = "SELECT id, name FROM income_types WHERE id = ? AND status = 'active'";
$type = fetchOne($conn, $typeSql, [$typeId]);

if (!$type) {
    http_response_code(404);
    echo json_encode([
        'success' => false,
        'message' => 'Income type not found or inactive'
    ], JSON_NUMERIC_CHECK);
    closeConnection($conn);
    exit();
}

// Prepare insert data
$amount = floatval($input['amount']);
$incomeDate = $input['income_date'];
$notes = isset($input['notes']) ? trim($input['notes']) : null;
$createdBy = $user['user_id'];

// Insert income
$sql = "INSERT INTO incomes (income_type_id, amount, income_date, notes, created_by)
        VALUES (?, ?, ?, ?, ?)";

$stmt = $conn->prepare($sql);
$stmt->bind_param('idssi', $typeId, $amount, $incomeDate, $notes, $createdBy);

if (!$stmt->execute()) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Failed to create income: ' . $stmt->error
    ], JSON_NUMERIC_CHECK);
    $stmt->close();
    closeConnection($conn);
    exit();
}

$incomeId = $conn->insert_id;
$stmt->close();

// Fetch created income
$fetchSql = "SELECT i.*, it.name as income_type_name, u.full_name as created_by_name
             FROM incomes i
             INNER JOIN income_types it ON i.income_type_id = it.id
             INNER JOIN users u ON i.created_by = u.id
             WHERE i.id = ?";
$income = fetchOne($conn, $fetchSql, [$incomeId]);

echo json_encode([
    'success' => true,
    'message' => 'Income created successfully',
    'data' => $income
], JSON_NUMERIC_CHECK);

closeConnection($conn);
?>
