<?php
/**
 * Product Categories CRUD API
 * Endpoint: GET/POST/PUT/DELETE /api/master/categories.php
 * GET - Get all categories (with optional search)
 * POST - Create new category (Admin only)
 * PUT - Update category (Admin only)
 * DELETE - Delete/deactivate category (Admin only)
 */

require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../config/auth.php';

// Authenticate user
$user = authenticate();

// Get database connection
$conn = getConnection();

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Get all categories
    $includeInactive = isset($_GET['include_inactive']) && $_GET['include_inactive'] === '1';
    $search = isset($_GET['search']) ? trim($_GET['search']) : '';
    
    $conditions = [];
    $params = [];
    
    if (!$includeInactive) {
        $conditions[] = "status = 'active'";
    }
    
    if (!empty($search)) {
        $conditions[] = "name LIKE ?";
        $params[] = "%{$search}%";
    }
    
    $whereClause = !empty($conditions) ? 'WHERE ' . implode(' AND ', $conditions) : '';
    
    $sql = "SELECT id, name, description, status, created_at, updated_at
            FROM product_categories
            {$whereClause}
            ORDER BY name ASC";
    
    $categories = fetchAll($conn, $sql, $params);

    echo json_encode([
        'success' => true,
        'data' => $categories
    ], JSON_NUMERIC_CHECK);

} elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Create category (Admin only)
    requireAdmin($user);

    // Get JSON input
    $input = json_decode(file_get_contents('php://input'), true);

    // Validate input
    if (!isset($input['name']) || empty(trim($input['name']))) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Category name is required'
        ], JSON_NUMERIC_CHECK);
        closeConnection($conn);
        exit();
    }

    $name = trim($input['name']);
    $description = isset($input['description']) ? trim($input['description']) : '';
    $status = isset($input['status']) ? $input['status'] : 'active';

    // Check if category name already exists
    $checkSql = "SELECT id FROM product_categories WHERE name = ?";
    $existing = fetchOne($conn, $checkSql, [$name]);
    
    if ($existing) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Category name already exists'
        ], JSON_NUMERIC_CHECK);
        closeConnection($conn);
        exit();
    }

    // Insert category
    $sql = "INSERT INTO product_categories (name, description, status) VALUES (?, ?, ?)";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param('sss', $name, $description, $status);
    
    if ($stmt->execute()) {
        $newId = $conn->insert_id;
        $stmt->close();
        
        // Get the created category
        $category = fetchOne($conn, "SELECT * FROM product_categories WHERE id = ?", [$newId]);
        
        echo json_encode([
            'success' => true,
            'message' => 'Category created successfully',
            'data' => $category
        ], JSON_NUMERIC_CHECK);
    } else {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Failed to create category'
        ], JSON_NUMERIC_CHECK);
    }

} elseif ($_SERVER['REQUEST_METHOD'] === 'PUT') {
    // Update category (Admin only)
    requireAdmin($user);

    // Get JSON input
    $input = json_decode(file_get_contents('php://input'), true);

    // Validate input
    if (!isset($input['id']) || !is_numeric($input['id'])) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Category ID is required'
        ], JSON_NUMERIC_CHECK);
        closeConnection($conn);
        exit();
    }

    $id = intval($input['id']);
    
    // Check if category exists
    $existing = fetchOne($conn, "SELECT id FROM product_categories WHERE id = ?", [$id]);
    if (!$existing) {
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'message' => 'Category not found'
        ], JSON_NUMERIC_CHECK);
        closeConnection($conn);
        exit();
    }

    // Build update query dynamically
    $updates = [];
    $params = [];
    
    if (isset($input['name']) && !empty(trim($input['name']))) {
        // Check if new name already exists for another category
        $name = trim($input['name']);
        $checkSql = "SELECT id FROM product_categories WHERE name = ? AND id != ?";
        $duplicate = fetchOne($conn, $checkSql, [$name, $id]);
        if ($duplicate) {
            http_response_code(400);
            echo json_encode([
                'success' => false,
                'message' => 'Category name already exists'
            ], JSON_NUMERIC_CHECK);
            closeConnection($conn);
            exit();
        }
        $updates[] = "name = ?";
        $params[] = $name;
    }
    
    if (isset($input['description'])) {
        $updates[] = "description = ?";
        $params[] = trim($input['description']);
    }
    
    if (isset($input['status'])) {
        $updates[] = "status = ?";
        $params[] = $input['status'];
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
    $sql = "UPDATE product_categories SET " . implode(', ', $updates) . " WHERE id = ?";
    $stmt = $conn->prepare($sql);
    
    // Build type string
    $types = str_repeat('s', count($params) - 1) . 'i';
    $stmt->bind_param($types, ...$params);
    
    if ($stmt->execute()) {
        $stmt->close();
        
        // Get the updated category
        $category = fetchOne($conn, "SELECT * FROM product_categories WHERE id = ?", [$id]);
        
        echo json_encode([
            'success' => true,
            'message' => 'Category updated successfully',
            'data' => $category
        ], JSON_NUMERIC_CHECK);
    } else {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Failed to update category'
        ], JSON_NUMERIC_CHECK);
    }

} elseif ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
    // Delete/deactivate category (Admin only)
    requireAdmin($user);

    $id = isset($_GET['id']) ? intval($_GET['id']) : 0;
    
    if ($id <= 0) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Category ID is required'
        ], JSON_NUMERIC_CHECK);
        closeConnection($conn);
        exit();
    }

    // Check if category exists
    $existing = fetchOne($conn, "SELECT id FROM product_categories WHERE id = ?", [$id]);
    if (!$existing) {
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'message' => 'Category not found'
        ], JSON_NUMERIC_CHECK);
        closeConnection($conn);
        exit();
    }

    // Check if category has products
    $productCount = fetchOne($conn, "SELECT COUNT(*) as count FROM products WHERE category_id = ?", [$id]);
    if ($productCount && $productCount['count'] > 0) {
        // Soft delete - set status to inactive
        $sql = "UPDATE product_categories SET status = 'inactive' WHERE id = ?";
    } else {
        // Hard delete if no products
        $sql = "DELETE FROM product_categories WHERE id = ?";
    }
    
    $stmt = $conn->prepare($sql);
    $stmt->bind_param('i', $id);
    
    if ($stmt->execute()) {
        echo json_encode([
            'success' => true,
            'message' => 'Category deleted successfully'
        ], JSON_NUMERIC_CHECK);
    } else {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Failed to delete category'
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
