<?php
/**
 * Get Held Transactions API
 * Endpoint: GET /api/pos/get_held.php
 */

require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../config/auth.php';

// Authenticate user
$user = authenticate();

// Get database connection
$conn = getConnection();

// Fetch held transactions
$sql = "SELECT ht.id, ht.hold_name, ht.created_at, u.full_name as created_by_name
        FROM held_transactions ht
        INNER JOIN users u ON ht.created_by = u.id
        ORDER BY ht.created_at DESC";

$heldTransactions = fetchAll($conn, $sql);

echo json_encode([
    'success' => true,
    'data' => $heldTransactions
]);

closeConnection($conn);
?>
