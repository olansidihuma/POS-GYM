<?php
/**
 * Membership Types/Packages CRUD API
 * Endpoint: GET/POST/PUT/DELETE /api/membership/packages.php
 * GET - Get all membership packages
 * POST - Create new package (Admin only)
 * PUT - Update package (Admin only)
 * DELETE - Delete/deactivate package (Admin only)
 */

require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../config/auth.php';

// Authenticate user
$user = authenticate();

// Get database connection
$conn = getConnection();

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Get all membership packages
    $includeInactive = isset($_GET['include_inactive']) && $_GET['include_inactive'] === '1';
    
    $conditions = [];
    if (!$includeInactive) {
        $conditions[] = "status = 'active'";
    }
    
    $whereClause = !empty($conditions) ? 'WHERE ' . implode(' AND ', $conditions) : '';
    
    $sql = "SELECT id, name, price, duration_days, description, status, created_at, updated_at
            FROM membership_types
            {$whereClause}
            ORDER BY price ASC";
    
    $packages = fetchAll($conn, $sql);

    echo json_encode([
        'success' => true,
        'data' => $packages
    ], JSON_NUMERIC_CHECK);

} elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Create package (Admin only)
    requireAdmin($user);

    $input = json_decode(file_get_contents('php://input'), true);

    // Validate required fields
    if (!isset($input['name']) || empty(trim($input['name']))) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Package name is required'
        ], JSON_NUMERIC_CHECK);
        closeConnection($conn);
        exit();
    }

    if (!isset($input['price']) || !is_numeric($input['price'])) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Valid price is required'
        ], JSON_NUMERIC_CHECK);
        closeConnection($conn);
        exit();
    }

    $name = trim($input['name']);
    $price = floatval($input['price']);
    $durationDays = isset($input['duration_days']) ? intval($input['duration_days']) : 365;
    $description = isset($input['description']) ? trim($input['description']) : '';
    $status = isset($input['status']) ? $input['status'] : 'active';

    // Check for duplicate name
    $existing = fetchOne($conn, "SELECT id FROM membership_types WHERE name = ?", [$name]);
    if ($existing) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Package name already exists'
        ], JSON_NUMERIC_CHECK);
        closeConnection($conn);
        exit();
    }

    // Insert package
    $sql = "INSERT INTO membership_types (name, price, duration_days, description, status) 
            VALUES (?, ?, ?, ?, ?)";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param('sdiss', $name, $price, $durationDays, $description, $status);
    
    if ($stmt->execute()) {
        $newId = $conn->insert_id;
        $stmt->close();
        
        $package = fetchOne($conn, "SELECT * FROM membership_types WHERE id = ?", [$newId]);
        
        echo json_encode([
            'success' => true,
            'message' => 'Package created successfully',
            'data' => $package
        ], JSON_NUMERIC_CHECK);
    } else {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Failed to create package'
        ], JSON_NUMERIC_CHECK);
    }

} elseif ($_SERVER['REQUEST_METHOD'] === 'PUT') {
    // Update package (Admin only)
    requireAdmin($user);

    $input = json_decode(file_get_contents('php://input'), true);

    if (!isset($input['id']) || !is_numeric($input['id'])) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Package ID is required'
        ], JSON_NUMERIC_CHECK);
        closeConnection($conn);
        exit();
    }

    $id = intval($input['id']);
    
    // Check if package exists
    $existing = fetchOne($conn, "SELECT id FROM membership_types WHERE id = ?", [$id]);
    if (!$existing) {
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'message' => 'Package not found'
        ], JSON_NUMERIC_CHECK);
        closeConnection($conn);
        exit();
    }

    // Build update query
    $updates = [];
    $params = [];
    $types = '';
    
    if (isset($input['name']) && !empty(trim($input['name']))) {
        // Check for duplicate name
        $name = trim($input['name']);
        $duplicate = fetchOne($conn, "SELECT id FROM membership_types WHERE name = ? AND id != ?", [$name, $id]);
        if ($duplicate) {
            http_response_code(400);
            echo json_encode([
                'success' => false,
                'message' => 'Package name already exists'
            ], JSON_NUMERIC_CHECK);
            closeConnection($conn);
            exit();
        }
        $updates[] = "name = ?";
        $params[] = $name;
        $types .= 's';
    }
    
    if (isset($input['price'])) {
        $updates[] = "price = ?";
        $params[] = floatval($input['price']);
        $types .= 'd';
    }
    
    if (isset($input['duration_days'])) {
        $updates[] = "duration_days = ?";
        $params[] = intval($input['duration_days']);
        $types .= 'i';
    }
    
    if (isset($input['description'])) {
        $updates[] = "description = ?";
        $params[] = trim($input['description']);
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
    
    $sql = "UPDATE membership_types SET " . implode(', ', $updates) . " WHERE id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param($types, ...$params);
    
    if ($stmt->execute()) {
        $stmt->close();
        
        $package = fetchOne($conn, "SELECT * FROM membership_types WHERE id = ?", [$id]);
        
        echo json_encode([
            'success' => true,
            'message' => 'Package updated successfully',
            'data' => $package
        ], JSON_NUMERIC_CHECK);
    } else {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Failed to update package'
        ], JSON_NUMERIC_CHECK);
    }

} elseif ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
    // Delete/deactivate package (Admin only)
    requireAdmin($user);

    $id = isset($_GET['id']) ? intval($_GET['id']) : 0;
    
    if ($id <= 0) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Package ID is required'
        ], JSON_NUMERIC_CHECK);
        closeConnection($conn);
        exit();
    }

    // Check if package exists
    $existing = fetchOne($conn, "SELECT id FROM membership_types WHERE id = ?", [$id]);
    if (!$existing) {
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'message' => 'Package not found'
        ], JSON_NUMERIC_CHECK);
        closeConnection($conn);
        exit();
    }

    // Check if package is used in subscriptions
    $subscriptionCount = fetchOne($conn, "SELECT COUNT(*) as count FROM membership_subscriptions WHERE membership_type_id = ?", [$id]);
    if ($subscriptionCount && $subscriptionCount['count'] > 0) {
        // Soft delete
        $sql = "UPDATE membership_types SET status = 'inactive' WHERE id = ?";
    } else {
        // Hard delete
        $sql = "DELETE FROM membership_types WHERE id = ?";
    }
    
    $stmt = $conn->prepare($sql);
    $stmt->bind_param('i', $id);
    
    if ($stmt->execute()) {
        echo json_encode([
            'success' => true,
            'message' => 'Package deleted successfully'
        ], JSON_NUMERIC_CHECK);
    } else {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Failed to delete package'
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
