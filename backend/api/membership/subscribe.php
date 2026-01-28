<?php
/**
 * Create Subscription API
 * Endpoint: POST /api/membership/subscribe.php
 */

require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../config/auth.php';

// Authenticate user
$user = authenticate();

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

// Validate required fields
if (!isset($input['member_id']) || empty($input['member_id'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Member ID is required'
    ]);
    exit();
}

if (!isset($input['membership_type_id']) || empty($input['membership_type_id'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Membership type is required'
    ]);
    exit();
}

if (!isset($input['payment_method']) || empty($input['payment_method'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Payment method is required'
    ]);
    exit();
}

// Get database connection
$conn = getConnection();

// Validate member exists
$memberId = intval($input['member_id']);
$memberSql = "SELECT id, full_name FROM members WHERE id = ? AND status = 'active'";
$member = fetchOne($conn, $memberSql, [$memberId]);

if (!$member) {
    http_response_code(404);
    echo json_encode([
        'success' => false,
        'message' => 'Member not found or inactive'
    ]);
    closeConnection($conn);
    exit();
}

// Validate membership type exists
$typeId = intval($input['membership_type_id']);
$typeSql = "SELECT id, name, price, duration_days FROM membership_types WHERE id = ? AND status = 'active'";
$type = fetchOne($conn, $typeSql, [$typeId]);

if (!$type) {
    http_response_code(404);
    echo json_encode([
        'success' => false,
        'message' => 'Membership type not found or inactive'
    ]);
    closeConnection($conn);
    exit();
}

// Check for active subscription
$activeSql = "SELECT id FROM membership_subscriptions WHERE member_id = ? AND status = 'active'";
$activeSubscription = fetchOne($conn, $activeSql, [$memberId]);

// Validate and calculate dates
$start_date = isset($input['start_date']) ? $input['start_date'] : date('Y-m-d');

// Validate date format
if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $start_date) || !strtotime($start_date)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Invalid start_date format. Use YYYY-MM-DD'
    ]);
    closeConnection($conn);
    exit();
}

$end_date = date('Y-m-d', strtotime($start_date . ' + ' . $type['duration_days'] . ' days'));

// If there's an active subscription, expire it first
if ($activeSubscription) {
    $expireSql = "UPDATE membership_subscriptions SET status = 'expired' WHERE id = ?";
    $stmt = $conn->prepare($expireSql);
    $stmt->bind_param('i', $activeSubscription['id']);
    $stmt->execute();
    $stmt->close();
}

// Prepare insert data
$amount = $type['price'];
$payment_method = $input['payment_method'];
$payment_proof = isset($input['payment_proof']) ? trim($input['payment_proof']) : null;

// Insert subscription
$sql = "INSERT INTO membership_subscriptions (member_id, membership_type_id, start_date, end_date, 
                                              amount, payment_method, payment_proof, status)
        VALUES (?, ?, ?, ?, ?, ?, ?, 'active')";

$stmt = $conn->prepare($sql);
$stmt->bind_param('iissdss', $memberId, $typeId, $start_date, $end_date, $amount, $payment_method, $payment_proof);

if (!$stmt->execute()) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Failed to create subscription: ' . $stmt->error
    ]);
    $stmt->close();
    closeConnection($conn);
    exit();
}

$subscriptionId = $conn->insert_id;
$stmt->close();

// Fetch created subscription
$fetchSql = "SELECT ms.*, mt.name as membership_type_name, m.full_name as member_name
             FROM membership_subscriptions ms
             INNER JOIN membership_types mt ON ms.membership_type_id = mt.id
             INNER JOIN members m ON ms.member_id = m.id
             WHERE ms.id = ?";
$subscription = fetchOne($conn, $fetchSql, [$subscriptionId]);

echo json_encode([
    'success' => true,
    'message' => 'Subscription created successfully',
    'data' => $subscription
]);

closeConnection($conn);
?>
