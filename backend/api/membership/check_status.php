<?php
/**
 * Check Membership Status API
 * Endpoint: GET /api/membership/check_status.php?member_id=1
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
$memberSql = "SELECT id, member_code, full_name, status FROM members WHERE id = ?";
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

// Check active subscription
$sql = "SELECT ms.*, mt.name as membership_type_name,
               DATEDIFF(ms.end_date, CURDATE()) as days_remaining
        FROM membership_subscriptions ms
        INNER JOIN membership_types mt ON ms.membership_type_id = mt.id
        WHERE ms.member_id = ? AND ms.status = 'active' AND ms.end_date >= CURDATE()
        ORDER BY ms.end_date DESC
        LIMIT 1";

$subscription = fetchOne($conn, $sql, [$memberId]);

// Auto-expire subscriptions that have passed end_date
if ($subscription && strtotime($subscription['end_date']) < strtotime(date('Y-m-d'))) {
    $expireSql = "UPDATE membership_subscriptions SET status = 'expired' WHERE id = ?";
    $stmt = $conn->prepare($expireSql);
    $stmt->bind_param('i', $subscription['id']);
    $stmt->execute();
    $stmt->close();
    $subscription = null;
}

$isActive = ($subscription !== null);
$status = $isActive ? 'active' : 'expired';

echo json_encode([
    'success' => true,
    'data' => [
        'member' => $member,
        'is_active' => $isActive,
        'status' => $status,
        'subscription' => $subscription
    ]
]);

closeConnection($conn);
?>
