<?php
/**
 * Update Member API
 * Endpoint: PUT /api/members/update.php
 */

require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../config/auth.php';

// Authenticate user
$user = authenticate();

// Only accept PUT requests
if ($_SERVER['REQUEST_METHOD'] !== 'PUT') {
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

if (!isset($input['full_name']) || empty(trim($input['full_name']))) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Full name is required'
    ]);
    exit();
}

// Get database connection
$conn = getConnection();

// Check if member exists
$memberId = intval($input['id']);
$checkSql = "SELECT id FROM members WHERE id = ?";
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

// Prepare update data
$full_name = trim($input['full_name']);
$nickname = isset($input['nickname']) ? trim($input['nickname']) : null;
$address = isset($input['address']) ? trim($input['address']) : null;
$dukuh = isset($input['dukuh']) ? trim($input['dukuh']) : null;
$rt = isset($input['rt']) ? trim($input['rt']) : null;
$rw = isset($input['rw']) ? trim($input['rw']) : null;
$kabupaten_id = isset($input['kabupaten_id']) && !empty($input['kabupaten_id']) ? intval($input['kabupaten_id']) : null;
$kecamatan_id = isset($input['kecamatan_id']) && !empty($input['kecamatan_id']) ? intval($input['kecamatan_id']) : null;
$kelurahan_id = isset($input['kelurahan_id']) && !empty($input['kelurahan_id']) ? intval($input['kelurahan_id']) : null;
$birth_place = isset($input['birth_place']) ? trim($input['birth_place']) : null;
$birth_date = isset($input['birth_date']) && !empty($input['birth_date']) ? $input['birth_date'] : null;

// Validate birth_date format if provided
if ($birth_date !== null && (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $birth_date) || !strtotime($birth_date))) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Invalid birth_date format. Use YYYY-MM-DD'
    ]);
    closeConnection($conn);
    exit();
}
$phone = isset($input['phone']) ? trim($input['phone']) : null;
$identity_number = isset($input['identity_number']) ? trim($input['identity_number']) : null;
$emergency_contact_name = isset($input['emergency_contact_name']) ? trim($input['emergency_contact_name']) : null;
$emergency_contact_phone = isset($input['emergency_contact_phone']) ? trim($input['emergency_contact_phone']) : null;

// Update member
$sql = "UPDATE members SET full_name = ?, nickname = ?, address = ?, dukuh = ?, rt = ?, rw = ?,
                          kabupaten_id = ?, kecamatan_id = ?, kelurahan_id = ?, birth_place = ?, 
                          birth_date = ?, phone = ?, identity_number = ?, 
                          emergency_contact_name = ?, emergency_contact_phone = ?
        WHERE id = ?";

$stmt = $conn->prepare($sql);
$stmt->bind_param('ssssssiissssssi', $full_name, $nickname, $address, $dukuh, $rt, $rw,
                  $kabupaten_id, $kecamatan_id, $kelurahan_id, $birth_place, $birth_date,
                  $phone, $identity_number, $emergency_contact_name, $emergency_contact_phone, $memberId);

if (!$stmt->execute()) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Failed to update member: ' . $stmt->error
    ]);
    $stmt->close();
    closeConnection($conn);
    exit();
}

$stmt->close();

// Fetch updated member
$sql = "SELECT m.*, k.name as kabupaten_name, kec.name as kecamatan_name, kel.name as kelurahan_name
        FROM members m
        LEFT JOIN kabupaten k ON m.kabupaten_id = k.id
        LEFT JOIN kecamatan kec ON m.kecamatan_id = kec.id
        LEFT JOIN kelurahan kel ON m.kelurahan_id = kel.id
        WHERE m.id = ?";
$member = fetchOne($conn, $sql, [$memberId]);

echo json_encode([
    'success' => true,
    'message' => 'Member updated successfully',
    'data' => $member
]);

closeConnection($conn);
?>
