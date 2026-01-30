<?php
/**
 * Products CRUD API
 * Endpoint: GET/POST/PUT/DELETE /api/master/products.php
 * GET - Get all products (with optional filters)
 * POST - Create new product (Admin only)
 * PUT - Update product (Admin only)
 * DELETE - Delete/deactivate product (Admin only)
 */

require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../config/auth.php';

// Authenticate user
$user = authenticate();

// Get database connection
$conn = getConnection();

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Get all products with optional filters
    $includeInactive = isset($_GET['include_inactive']) && $_GET['include_inactive'] === '1';
    $search = isset($_GET['search']) ? trim($_GET['search']) : '';
    $categoryId = isset($_GET['category_id']) ? intval($_GET['category_id']) : 0;
    
    $conditions = [];
    $params = [];
    
    if (!$includeInactive) {
        $conditions[] = "p.status = 'active'";
    }
    
    if (!empty($search)) {
        $conditions[] = "(p.name LIKE ? OR p.description LIKE ?)";
        $params[] = "%{$search}%";
        $params[] = "%{$search}%";
    }
    
    if ($categoryId > 0) {
        $conditions[] = "p.category_id = ?";
        $params[] = $categoryId;
    }
    
    $whereClause = !empty($conditions) ? 'WHERE ' . implode(' AND ', $conditions) : '';
    
    $sql = "SELECT p.id, p.category_id, p.name, p.price, p.discount, p.stock, 
                   p.description, p.image, p.status, p.created_at, p.updated_at,
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

} elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Create product (Admin only)
    requireAdmin($user);

    // Get JSON input
    $input = json_decode(file_get_contents('php://input'), true);

    // Validate required fields
    $required = ['name', 'category_id', 'price'];
    foreach ($required as $field) {
        if (!isset($input[$field]) || (is_string($input[$field]) && empty(trim($input[$field])))) {
            http_response_code(400);
            echo json_encode([
                'success' => false,
                'message' => ucfirst(str_replace('_', ' ', $field)) . ' is required'
            ], JSON_NUMERIC_CHECK);
            closeConnection($conn);
            exit();
        }
    }

    $name = trim($input['name']);
    $categoryId = intval($input['category_id']);
    $price = floatval($input['price']);
    $discount = isset($input['discount']) ? floatval($input['discount']) : 0;
    $stock = isset($input['stock']) ? intval($input['stock']) : 0;
    $description = isset($input['description']) ? trim($input['description']) : '';
    $image = isset($input['image']) ? trim($input['image']) : '';
    $status = isset($input['status']) ? $input['status'] : 'active';
    $code = isset($input['code']) ? trim($input['code']) : '';

    // Check if category exists
    $category = fetchOne($conn, "SELECT id FROM product_categories WHERE id = ?", [$categoryId]);
    if (!$category) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Invalid category'
        ], JSON_NUMERIC_CHECK);
        closeConnection($conn);
        exit();
    }

    // Insert product
    $sql = "INSERT INTO products (category_id, name, price, discount, stock, description, image, status) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param('isddiiss', $categoryId, $name, $price, $discount, $stock, $description, $image, $status);
    
    if ($stmt->execute()) {
        $newId = $conn->insert_id;
        $stmt->close();
        
        // Get the created product with category name
        $product = fetchOne($conn, 
            "SELECT p.*, pc.name as category_name 
             FROM products p 
             INNER JOIN product_categories pc ON p.category_id = pc.id 
             WHERE p.id = ?", 
            [$newId]
        );
        
        echo json_encode([
            'success' => true,
            'message' => 'Product created successfully',
            'data' => $product
        ], JSON_NUMERIC_CHECK);
    } else {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Failed to create product'
        ], JSON_NUMERIC_CHECK);
    }

} elseif ($_SERVER['REQUEST_METHOD'] === 'PUT') {
    // Update product (Admin only)
    requireAdmin($user);

    // Get JSON input
    $input = json_decode(file_get_contents('php://input'), true);

    // Validate input
    if (!isset($input['id']) || !is_numeric($input['id'])) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Product ID is required'
        ], JSON_NUMERIC_CHECK);
        closeConnection($conn);
        exit();
    }

    $id = intval($input['id']);
    
    // Check if product exists
    $existing = fetchOne($conn, "SELECT id FROM products WHERE id = ?", [$id]);
    if (!$existing) {
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'message' => 'Product not found'
        ], JSON_NUMERIC_CHECK);
        closeConnection($conn);
        exit();
    }

    // Build update query dynamically
    $updates = [];
    $params = [];
    $types = '';
    
    if (isset($input['name']) && !empty(trim($input['name']))) {
        $updates[] = "name = ?";
        $params[] = trim($input['name']);
        $types .= 's';
    }
    
    if (isset($input['category_id'])) {
        // Validate category
        $category = fetchOne($conn, "SELECT id FROM product_categories WHERE id = ?", [intval($input['category_id'])]);
        if (!$category) {
            http_response_code(400);
            echo json_encode([
                'success' => false,
                'message' => 'Invalid category'
            ], JSON_NUMERIC_CHECK);
            closeConnection($conn);
            exit();
        }
        $updates[] = "category_id = ?";
        $params[] = intval($input['category_id']);
        $types .= 'i';
    }
    
    if (isset($input['price'])) {
        $updates[] = "price = ?";
        $params[] = floatval($input['price']);
        $types .= 'd';
    }
    
    if (isset($input['discount'])) {
        $updates[] = "discount = ?";
        $params[] = floatval($input['discount']);
        $types .= 'd';
    }
    
    if (isset($input['stock'])) {
        $updates[] = "stock = ?";
        $params[] = intval($input['stock']);
        $types .= 'i';
    }
    
    if (isset($input['description'])) {
        $updates[] = "description = ?";
        $params[] = trim($input['description']);
        $types .= 's';
    }
    
    if (isset($input['image'])) {
        $updates[] = "image = ?";
        $params[] = trim($input['image']);
        $types .= 's';
    }
    
    if (isset($input['status'])) {
        $updates[] = "status = ?";
        $params[] = $input['status'];
        $types .= 's';
    }

    if (empty($updates)) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'No fields to update'
        ], JSON_NUMERIC_CHECK);
        closeConnection($conn);
        exit();
    }

    $params[] = $id;
    $types .= 'i';
    
    $sql = "UPDATE products SET " . implode(', ', $updates) . " WHERE id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param($types, ...$params);
    
    if ($stmt->execute()) {
        $stmt->close();
        
        // Get the updated product
        $product = fetchOne($conn, 
            "SELECT p.*, pc.name as category_name 
             FROM products p 
             INNER JOIN product_categories pc ON p.category_id = pc.id 
             WHERE p.id = ?", 
            [$id]
        );
        
        echo json_encode([
            'success' => true,
            'message' => 'Product updated successfully',
            'data' => $product
        ], JSON_NUMERIC_CHECK);
    } else {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Failed to update product'
        ], JSON_NUMERIC_CHECK);
    }

} elseif ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
    // Delete/deactivate product (Admin only)
    requireAdmin($user);

    $id = isset($_GET['id']) ? intval($_GET['id']) : 0;
    
    if ($id <= 0) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Product ID is required'
        ], JSON_NUMERIC_CHECK);
        closeConnection($conn);
        exit();
    }

    // Check if product exists
    $existing = fetchOne($conn, "SELECT id FROM products WHERE id = ?", [$id]);
    if (!$existing) {
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'message' => 'Product not found'
        ], JSON_NUMERIC_CHECK);
        closeConnection($conn);
        exit();
    }

    // Check if product has been used in transactions
    $transactionCount = fetchOne($conn, "SELECT COUNT(*) as count FROM transaction_items WHERE product_id = ?", [$id]);
    if ($transactionCount && $transactionCount['count'] > 0) {
        // Soft delete - set status to inactive
        $sql = "UPDATE products SET status = 'inactive' WHERE id = ?";
    } else {
        // Hard delete if never used in transactions
        $sql = "DELETE FROM products WHERE id = ?";
    }
    
    $stmt = $conn->prepare($sql);
    $stmt->bind_param('i', $id);
    
    if ($stmt->execute()) {
        echo json_encode([
            'success' => true,
            'message' => 'Product deleted successfully'
        ], JSON_NUMERIC_CHECK);
    } else {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Failed to delete product'
        ], JSON_NUMERIC_CHECK);
    }

} else {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Method not allowed'
    ], JSON_NUMERIC_CHECK);
}

closeConnection($conn);
?>
