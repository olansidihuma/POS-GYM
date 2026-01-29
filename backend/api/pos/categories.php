<?php
/**
 * Get Product Categories API
 * Endpoint: GET /api/pos/categories.php
 */

require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../config/auth.php';

// Authenticate user
$user = authenticate();

// Get database connection
$conn = getConnection();

// Fetch active categories
$sql = "SELECT id, name, description, status, created_at
        FROM product_categories
        WHERE status = 'active'
        ORDER BY name ASC";

$categories = fetchAll($conn, $sql);

echo json_encode([
    'success' => true,
    'data' => $categories
], JSON_NUMERIC_CHECK);

closeConnection($conn);
?>
