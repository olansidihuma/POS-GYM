<?php
/**
 * Users CRUD API
 * Endpoint: GET/POST/PUT/DELETE /api/master/users.php
 * GET - Get all users or single user (Admin only)
 * POST - Create new user (Admin only)
 * PUT - Update user (Admin only)
 * DELETE - Delete/deactivate user (Admin only)
 */

require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../config/auth.php';

// Authenticate user
$user = authenticate();

// Get database connection
$conn = getConnection();

// All operations require admin access
requireAdmin($user);

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Get users
    $id = isset($_GET['id']) ? intval($_GET['id']) : 0;
    $includeInactive = isset($_GET['include_inactive']) && $_GET['include_inactive'] === '1';
    $search = isset($_GET['search']) ? trim($_GET['search']) : '';
    
    if ($id > 0) {
        // Get single user
        $sql = "SELECT u.id, u.username, u.email, u.full_name, u.phone, u.role_id, u.status, 
                       u.created_at, u.updated_at, r.name as role_name
                FROM users u
                INNER JOIN roles r ON u.role_id = r.id
                WHERE u.id = ?";
        $userData = fetchOne($conn, $sql, [$id]);
        
        if (!$userData) {
            http_response_code(404);
            echo json_encode([
                'success' => false,
                'message' => 'User not found'
            ], JSON_NUMERIC_CHECK);
        } else {
            echo json_encode([
                'success' => true,
                'data' => $userData
            ], JSON_NUMERIC_CHECK);
        }
    } else {
        // Get all users
        $conditions = [];
        $params = [];
        
        if (!$includeInactive) {
            $conditions[] = "u.status = 'active'";
        }
        
        if (!empty($search)) {
            $conditions[] = "(u.username LIKE ? OR u.full_name LIKE ? OR u.email LIKE ?)";
            $params[] = "%{$search}%";
            $params[] = "%{$search}%";
            $params[] = "%{$search}%";
        }
        
        $whereClause = !empty($conditions) ? 'WHERE ' . implode(' AND ', $conditions) : '';
        
        $sql = "SELECT u.id, u.username, u.email, u.full_name, u.phone, u.role_id, u.status, 
                       u.created_at, u.updated_at, r.name as role_name
                FROM users u
                INNER JOIN roles r ON u.role_id = r.id
                {$whereClause}
                ORDER BY u.full_name ASC";
        
        $users = fetchAll($conn, $sql, $params);

        echo json_encode([
            'success' => true,
            'data' => $users
        ], JSON_NUMERIC_CHECK);
    }

} elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Create user
    $input = json_decode(file_get_contents('php://input'), true);

    // Validate required fields
    $required = ['username', 'password', 'full_name', 'role_id'];
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

    $username = trim($input['username']);
    $password = $input['password'];
    $fullName = trim($input['full_name']);
    $email = isset($input['email']) ? trim($input['email']) : null;
    $phone = isset($input['phone']) ? trim($input['phone']) : null;
    $roleId = intval($input['role_id']);
    $status = isset($input['status']) ? $input['status'] : 'active';

    // Validate password length
    if (strlen($password) < 6) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Password must be at least 6 characters'
        ], JSON_NUMERIC_CHECK);
        closeConnection($conn);
        exit();
    }

    // Validate email format if provided
    if ($email !== null && $email !== '' && !filter_var($email, FILTER_VALIDATE_EMAIL)) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Invalid email format'
        ], JSON_NUMERIC_CHECK);
        closeConnection($conn);
        exit();
    }

    // Hash password after validation
    $hashedPassword = password_hash($password, PASSWORD_DEFAULT);

    // Validate username uniqueness
    $existing = fetchOne($conn, "SELECT id FROM users WHERE username = ?", [$username]);
    if ($existing) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Username already exists'
        ], JSON_NUMERIC_CHECK);
        closeConnection($conn);
        exit();
    }

    // Validate role exists
    $role = fetchOne($conn, "SELECT id FROM roles WHERE id = ?", [$roleId]);
    if (!$role) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Invalid role'
        ], JSON_NUMERIC_CHECK);
        closeConnection($conn);
        exit();
    }

    // Insert user
    $sql = "INSERT INTO users (username, password, full_name, email, phone, role_id, status) 
            VALUES (?, ?, ?, ?, ?, ?, ?)";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param('sssssis', $username, $hashedPassword, $fullName, $email, $phone, $roleId, $status);
    
    if ($stmt->execute()) {
        $newId = $conn->insert_id;
        $stmt->close();
        
        // Get the created user
        $newUser = fetchOne($conn, 
            "SELECT u.id, u.username, u.email, u.full_name, u.phone, u.role_id, u.status, 
                    u.created_at, u.updated_at, r.name as role_name
             FROM users u
             INNER JOIN roles r ON u.role_id = r.id
             WHERE u.id = ?", 
            [$newId]
        );
        
        echo json_encode([
            'success' => true,
            'message' => 'User created successfully',
            'data' => $newUser
        ], JSON_NUMERIC_CHECK);
    } else {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Failed to create user'
        ], JSON_NUMERIC_CHECK);
    }

} elseif ($_SERVER['REQUEST_METHOD'] === 'PUT') {
    // Update user
    $input = json_decode(file_get_contents('php://input'), true);

    if (!isset($input['id']) || !is_numeric($input['id'])) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'User ID is required'
        ], JSON_NUMERIC_CHECK);
        closeConnection($conn);
        exit();
    }

    $id = intval($input['id']);
    
    // Check if user exists
    $existing = fetchOne($conn, "SELECT id FROM users WHERE id = ?", [$id]);
    if (!$existing) {
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'message' => 'User not found'
        ], JSON_NUMERIC_CHECK);
        closeConnection($conn);
        exit();
    }

    // Build update query dynamically
    $updates = [];
    $params = [];
    $types = '';
    
    if (isset($input['full_name']) && !empty(trim($input['full_name']))) {
        $updates[] = "full_name = ?";
        $params[] = trim($input['full_name']);
        $types .= 's';
    }
    
    if (isset($input['email'])) {
        $updates[] = "email = ?";
        $params[] = trim($input['email']);
        $types .= 's';
    }
    
    if (isset($input['phone'])) {
        $updates[] = "phone = ?";
        $params[] = trim($input['phone']);
        $types .= 's';
    }
    
    if (isset($input['role_id'])) {
        // Validate role
        $role = fetchOne($conn, "SELECT id FROM roles WHERE id = ?", [intval($input['role_id'])]);
        if (!$role) {
            http_response_code(400);
            echo json_encode([
                'success' => false,
                'message' => 'Invalid role'
            ], JSON_NUMERIC_CHECK);
            closeConnection($conn);
            exit();
        }
        $updates[] = "role_id = ?";
        $params[] = intval($input['role_id']);
        $types .= 'i';
    }
    
    if (isset($input['password']) && !empty($input['password'])) {
        $updates[] = "password = ?";
        $params[] = password_hash($input['password'], PASSWORD_DEFAULT);
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
    
    $sql = "UPDATE users SET " . implode(', ', $updates) . " WHERE id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param($types, ...$params);
    
    if ($stmt->execute()) {
        $stmt->close();
        
        // Get the updated user
        $updatedUser = fetchOne($conn, 
            "SELECT u.id, u.username, u.email, u.full_name, u.phone, u.role_id, u.status, 
                    u.created_at, u.updated_at, r.name as role_name
             FROM users u
             INNER JOIN roles r ON u.role_id = r.id
             WHERE u.id = ?", 
            [$id]
        );
        
        echo json_encode([
            'success' => true,
            'message' => 'User updated successfully',
            'data' => $updatedUser
        ], JSON_NUMERIC_CHECK);
    } else {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Failed to update user'
        ], JSON_NUMERIC_CHECK);
    }

} elseif ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
    // Delete/deactivate user
    $id = isset($_GET['id']) ? intval($_GET['id']) : 0;
    
    if ($id <= 0) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'User ID is required'
        ], JSON_NUMERIC_CHECK);
        closeConnection($conn);
        exit();
    }

    // Prevent self-deletion
    if ($id === $user['id']) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Cannot delete your own account'
        ], JSON_NUMERIC_CHECK);
        closeConnection($conn);
        exit();
    }

    // Check if user exists
    $existing = fetchOne($conn, "SELECT id, username FROM users WHERE id = ?", [$id]);
    if (!$existing) {
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'message' => 'User not found'
        ], JSON_NUMERIC_CHECK);
        closeConnection($conn);
        exit();
    }

    // Always soft delete for users (set status to inactive)
    $sql = "UPDATE users SET status = 'inactive' WHERE id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param('i', $id);
    
    if ($stmt->execute()) {
        echo json_encode([
            'success' => true,
            'message' => 'User deactivated successfully'
        ], JSON_NUMERIC_CHECK);
    } else {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Failed to delete user'
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
