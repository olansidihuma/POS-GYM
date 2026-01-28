<?php
/**
 * Get Expense Types API
 * Endpoint: GET /api/expenses/types.php
 */

require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../config/auth.php';

// Authenticate user
$user = authenticate();

// Get database connection
$conn = getConnection();

// Fetch active expense types
$sql = "SELECT id, name, status, created_at
        FROM expense_types
        WHERE status = 'active'
        ORDER BY name ASC";

$types = fetchAll($conn, $sql);

echo json_encode([
    'success' => true,
    'data' => $types
]);

closeConnection($conn);
?>
