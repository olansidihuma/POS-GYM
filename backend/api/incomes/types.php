<?php
/**
 * Get Income Types API
 * Endpoint: GET /api/incomes/types.php
 */

require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../config/auth.php';

// Authenticate user
$user = authenticate();

// Get database connection
$conn = getConnection();

// Fetch active income types
$sql = "SELECT id, name, status, created_at
        FROM income_types
        WHERE status = 'active'
        ORDER BY name ASC";

$types = fetchAll($conn, $sql);

echo json_encode([
    'success' => true,
    'data' => $types
], JSON_NUMERIC_CHECK);

closeConnection($conn);
?>
