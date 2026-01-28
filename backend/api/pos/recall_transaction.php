<?php
/**
 * Recall Held Transaction API
 * Endpoint: POST /api/pos/recall_transaction.php
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
    ]);
    exit();
}

// Get JSON input
$input = json_decode(file_get_contents('php://input'), true);

// Validate required fields
if (!isset($input['id']) || empty($input['id'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Held transaction ID is required'
    ]);
    exit();
}

$heldId = intval($input['id']);

// Get database connection
$conn = getConnection();

// Fetch held transaction
$sql = "SELECT id, hold_name, transaction_data FROM held_transactions WHERE id = ?";
$heldTransaction = fetchOne($conn, $sql, [$heldId]);

if (!$heldTransaction) {
    http_response_code(404);
    echo json_encode([
        'success' => false,
        'message' => 'Held transaction not found'
    ]);
    closeConnection($conn);
    exit();
}

// Delete held transaction
$deleteSql = "DELETE FROM held_transactions WHERE id = ?";
$stmt = $conn->prepare($deleteSql);
$stmt->bind_param('i', $heldId);

if (!$stmt->execute()) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Failed to recall transaction: ' . $stmt->error
    ]);
    $stmt->close();
    closeConnection($conn);
    exit();
}

$stmt->close();

// Return transaction data
$transactionData = json_decode($heldTransaction['transaction_data'], true);

echo json_encode([
    'success' => true,
    'message' => 'Transaction recalled successfully',
    'data' => [
        'hold_name' => $heldTransaction['hold_name'],
        'transaction_data' => $transactionData
    ]
]);

closeConnection($conn);
?>
