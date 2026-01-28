<?php
/**
 * Delete Member API (Soft Delete)
 * Endpoint: DELETE /api/members/delete.php
 */

require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../config/auth.php';

// Authenticate user
$user = authenticate();

// Only accept DELETE requests
if ($_SERVER['REQUEST_METHOD'] !== 'DELETE') {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Method not allowed'
    ]);
    exit();
}

// Get JSON input
$input = json_decode(file_get_contents('php://input'), true);

// Validate required fields
if (!isset($input['id']) || empty($input['id'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Member ID is required'
    ]);
    exit();
}

// Get database connection
$conn = getConnection();

// Check if member exists
$memberId = intval($input['id']);
$checkSql = "SELECT id, status FROM members WHERE id = ?";
$existingMember = fetchOne($conn, $checkSql, [$memberId]);

if (!$existingMember) {
    http_response_code(404);
    echo json_encode([
        'success' => false,
        'message' => 'Member not found'
    ]);
    closeConnection($conn);
    exit();
}

// Soft delete (set status to inactive)
$sql = "UPDATE members SET status = 'inactive' WHERE id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param('i', $memberId);

if (!$stmt->execute()) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Failed to delete member: ' . $stmt->error
    ]);
    $stmt->close();
    closeConnection($conn);
    exit();
}

$stmt->close();

echo json_encode([
    'success' => true,
    'message' => 'Member deleted successfully'
]);

closeConnection($conn);
?>
