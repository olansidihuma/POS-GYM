<?php
/**
 * Get Subscription History API
 * Endpoint: GET /api/membership/history.php?member_id=1
 */

require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../config/auth.php';

// Authenticate user
$user = authenticate();

// Get query parameters
if (!isset($_GET['member_id']) || empty($_GET['member_id'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Member ID is required'
    ]);
    exit();
}

$memberId = intval($_GET['member_id']);

// Get database connection
$conn = getConnection();

// Validate member exists
$memberSql = "SELECT id, full_name FROM members WHERE id = ?";
$member = fetchOne($conn, $memberSql, [$memberId]);

if (!$member) {
    http_response_code(404);
    echo json_encode([
        'success' => false,
        'message' => 'Member not found'
    ]);
    closeConnection($conn);
    exit();
}

// Fetch subscription history
$sql = "SELECT ms.*, mt.name as membership_type_name
        FROM membership_subscriptions ms
        INNER JOIN membership_types mt ON ms.membership_type_id = mt.id
        WHERE ms.member_id = ?
        ORDER BY ms.created_at DESC";

$subscriptions = fetchAll($conn, $sql, [$memberId]);

echo json_encode([
    'success' => true,
    'data' => [
        'member' => $member,
        'subscriptions' => $subscriptions
    ]
]);

closeConnection($conn);
?>
