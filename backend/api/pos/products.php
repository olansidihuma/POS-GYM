<?php
/**
 * Get Products API
 * Endpoint: GET /api/pos/products.php
 * Query Params: category_id, search
 */

require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../config/auth.php';

// Authenticate user
$user = authenticate();

// Get database connection
$conn = getConnection();

// Get query parameters
$categoryId = isset($_GET['category_id']) ? intval($_GET['category_id']) : 0;
$search = isset($_GET['search']) ? trim($_GET['search']) : '';

// Build query
$conditions = ["p.status = 'active'"];
$params = [];

if ($categoryId > 0) {
    $conditions[] = "p.category_id = ?";
    $params[] = $categoryId;
}

if (!empty($search)) {
    $conditions[] = "p.name LIKE ?";
    $params[] = "%{$search}%";
}

$whereClause = 'WHERE ' . implode(' AND ', $conditions);

// Fetch products
$sql = "SELECT p.id, p.category_id, p.name, p.price, p.discount, p.stock, 
               p.description, p.image, p.status,
               pc.name as category_name,
               (p.price - (p.price * p.discount / 100)) as final_price
        FROM products p
        INNER JOIN product_categories pc ON p.category_id = pc.id
        {$whereClause}
        ORDER BY p.name ASC";

$products = fetchAll($conn, $sql, $params);

echo json_encode([
    'success' => true,
    'data' => $products
], JSON_NUMERIC_CHECK);

closeConnection($conn);
?>
