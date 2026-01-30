<?php
/**
 * Roles API
 * Endpoint: GET /api/master/roles.php
 * Get all roles for dropdown
 */

require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../config/auth.php';

// Authenticate user
$user = authenticate();

// Get database connection
$conn = getConnection();

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $sql = "SELECT id, name, status FROM roles WHERE status = 'active' ORDER BY name ASC";
    $roles = fetchAll($conn, $sql);

    echo json_encode([
        'success' => true,
        'data' => $roles
    ], JSON_NUMERIC_CHECK);
} else {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Method not allowed'
    ], JSON_NUMERIC_CHECK);
}

closeConnection($conn);
?>
