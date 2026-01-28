<?php
/**
 * Get Membership Types API
 * Endpoint: GET /api/membership/types.php
 */

require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../config/auth.php';

// Authenticate user
$user = authenticate();

// Get database connection
$conn = getConnection();

// Fetch active membership types
$sql = "SELECT id, name, price, duration_days, description, status, created_at
        FROM membership_types
        WHERE status = 'active'
        ORDER BY price ASC";

$types = fetchAll($conn, $sql);

echo json_encode([
    'success' => true,
    'data' => $types
]);

closeConnection($conn);
?>
