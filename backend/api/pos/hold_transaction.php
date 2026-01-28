<?php
/**
 * Hold Transaction API
 * Endpoint: POST /api/pos/hold_transaction.php
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
if (!isset($input['hold_name']) || empty(trim($input['hold_name']))) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Hold name is required'
    ]);
    exit();
}

if (!isset($input['transaction_data']) || !is_array($input['transaction_data'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Transaction data is required'
    ]);
    exit();
}

// Get database connection
$conn = getConnection();

// Prepare insert data
$holdName = trim($input['hold_name']);
$transactionData = json_encode($input['transaction_data']);
$createdBy = $user['user_id'];

// Insert held transaction
$sql = "INSERT INTO held_transactions (hold_name, transaction_data, created_by)
        VALUES (?, ?, ?)";

$stmt = $conn->prepare($sql);
$stmt->bind_param('ssi', $holdName, $transactionData, $createdBy);

if (!$stmt->execute()) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Failed to hold transaction: ' . $stmt->error
    ]);
    $stmt->close();
    closeConnection($conn);
    exit();
}

$heldId = $conn->insert_id;
$stmt->close();

echo json_encode([
    'success' => true,
    'message' => 'Transaction held successfully',
    'data' => [
        'id' => $heldId,
        'hold_name' => $holdName
    ]
]);

closeConnection($conn);
?>
