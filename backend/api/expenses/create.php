<?php
/**
 * Create Expense API
 * Endpoint: POST /api/expenses/create.php
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
    ]);
    exit();
}

// Get JSON input
$input = json_decode(file_get_contents('php://input'), true);

// Validate required fields
if (!isset($input['expense_type_id']) || empty($input['expense_type_id'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Expense type is required'
    ]);
    exit();
}

if (!isset($input['amount']) || $input['amount'] <= 0) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Valid amount is required'
    ]);
    exit();
}

if (!isset($input['expense_date']) || empty($input['expense_date'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Expense date is required'
    ]);
    exit();
}

// Get database connection
$conn = getConnection();

// Validate expense type exists
$typeId = intval($input['expense_type_id']);
$typeSql = "SELECT id, name FROM expense_types WHERE id = ? AND status = 'active'";
$type = fetchOne($conn, $typeSql, [$typeId]);

if (!$type) {
    http_response_code(404);
    echo json_encode([
        'success' => false,
        'message' => 'Expense type not found or inactive'
    ]);
    closeConnection($conn);
    exit();
}

// Prepare insert data
$amount = floatval($input['amount']);
$expenseDate = $input['expense_date'];
$notes = isset($input['notes']) ? trim($input['notes']) : null;
$createdBy = $user['user_id'];

// Insert expense
$sql = "INSERT INTO expenses (expense_type_id, amount, expense_date, notes, created_by)
        VALUES (?, ?, ?, ?, ?)";

$stmt = $conn->prepare($sql);
$stmt->bind_param('idssi', $typeId, $amount, $expenseDate, $notes, $createdBy);

if (!$stmt->execute()) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Failed to create expense: ' . $stmt->error
    ]);
    $stmt->close();
    closeConnection($conn);
    exit();
}

$expenseId = $conn->insert_id;
$stmt->close();

// Fetch created expense
$fetchSql = "SELECT e.*, et.name as expense_type_name, u.full_name as created_by_name
             FROM expenses e
             INNER JOIN expense_types et ON e.expense_type_id = et.id
             INNER JOIN users u ON e.created_by = u.id
             WHERE e.id = ?";
$expense = fetchOne($conn, $fetchSql, [$expenseId]);

echo json_encode([
    'success' => true,
    'message' => 'Expense created successfully',
    'data' => $expense
]);

closeConnection($conn);
?>
