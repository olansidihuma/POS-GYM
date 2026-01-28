<?php
/**
 * Get Member Detail API
 * Endpoint: GET /api/members/detail.php?id=1
 */

require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../config/auth.php';

// Authenticate user
$user = authenticate();

// Get query parameters
if (!isset($_GET['id']) || empty($_GET['id'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Member ID is required'
    ]);
    exit();
}

$memberId = intval($_GET['id']);

// Get database connection
$conn = getConnection();

// Fetch member details
$sql = "SELECT m.*, k.name as kabupaten_name, kec.name as kecamatan_name, kel.name as kelurahan_name
        FROM members m
        LEFT JOIN kabupaten k ON m.kabupaten_id = k.id
        LEFT JOIN kecamatan kec ON m.kecamatan_id = kec.id
        LEFT JOIN kelurahan kel ON m.kelurahan_id = kel.id
        WHERE m.id = ?";

$member = fetchOne($conn, $sql, [$memberId]);

if (!$member) {
    http_response_code(404);
    echo json_encode([
        'success' => false,
        'message' => 'Member not found'
    ]);
    closeConnection($conn);
    exit();
}

// Get active subscription
$subSql = "SELECT ms.*, mt.name as membership_type_name
           FROM membership_subscriptions ms
           INNER JOIN membership_types mt ON ms.membership_type_id = mt.id
           WHERE ms.member_id = ? AND ms.status = 'active'
           ORDER BY ms.end_date DESC
           LIMIT 1";
$subscription = fetchOne($conn, $subSql, [$memberId]);

// Get total visits
$visitSql = "SELECT COUNT(*) as total_visits FROM attendances WHERE member_id = ?";
$visitCount = fetchOne($conn, $visitSql, [$memberId]);

$member['active_subscription'] = $subscription;
$member['total_visits'] = $visitCount ? intval($visitCount['total_visits']) : 0;

echo json_encode([
    'success' => true,
    'data' => $member
]);

closeConnection($conn);
?>
