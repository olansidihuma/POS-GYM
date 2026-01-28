<?php
/**
 * Login API
 * Endpoint: POST /api/auth/login.php
 */

require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../config/auth.php';

// Only accept POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Method not allowed'
    ]);
    exit();
}

// Get JSON input
$input = json_decode(file_get_contents('php://input'), true);

// Validate input
if (!isset($input['username']) || !isset($input['password'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Username and password are required'
    ]);
    exit();
}

$username = $input['username'];
$password = $input['password'];

// Get database connection
$conn = getConnection();

// Check user credentials
$sql = "SELECT u.id, u.username, u.password, u.full_name, u.status, r.name as role
        FROM users u
        INNER JOIN roles r ON u.role_id = r.id
        WHERE u.username = ?";

$user = fetchOne($conn, $sql, [$username]);

if (!$user) {
    http_response_code(401);
    echo json_encode([
        'success' => false,
        'message' => 'Invalid username or password'
    ]);
    closeConnection($conn);
    exit();
}

// Check if user is active
if ($user['status'] !== 'active') {
    http_response_code(401);
    echo json_encode([
        'success' => false,
        'message' => 'Account is inactive'
    ]);
    closeConnection($conn);
    exit();
}

// Verify password
if (!password_verify($password, $user['password'])) {
    http_response_code(401);
    echo json_encode([
        'success' => false,
        'message' => 'Invalid username or password'
    ]);
    closeConnection($conn);
    exit();
}

// Generate token
$token = generateToken($user['id'], $user['username'], $user['role']);

// Return success response
echo json_encode([
    'success' => true,
    'message' => 'Login successful',
    'data' => [
        'token' => $token,
        'user' => [
            'id' => $user['id'],
            'username' => $user['username'],
            'full_name' => $user['full_name'],
            'role' => $user['role']
        ]
    ]
]);

closeConnection($conn);
?>
