<?php
/**
 * Create Member API
 * Endpoint: POST /api/members/create.php
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

// Generate unique member code
$year = date('Y');
$sql = "SELECT member_code FROM members WHERE member_code LIKE ? ORDER BY member_code DESC LIMIT 1";
$lastMember = fetchOne($conn, $sql, ["{$year}%"]);

if ($lastMember) {
    $lastNumber = intval(substr($lastMember['member_code'], 4));
    $newNumber = $lastNumber + 1;
} else {
    $newNumber = 1;
}

$memberCode = $year . str_pad($newNumber, 4, '0', STR_PAD_LEFT);

// Prepare insert data
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
$phone = isset($input['phone']) ? trim($input['phone']) : null;
$identity_number = isset($input['identity_number']) ? trim($input['identity_number']) : null;
$emergency_contact_name = isset($input['emergency_contact_name']) ? trim($input['emergency_contact_name']) : null;
$emergency_contact_phone = isset($input['emergency_contact_phone']) ? trim($input['emergency_contact_phone']) : null;

// Insert member
$sql = "INSERT INTO members (member_code, full_name, nickname, address, dukuh, rt, rw, 
                             kabupaten_id, kecamatan_id, kelurahan_id, birth_place, birth_date,
                             phone, identity_number, emergency_contact_name, emergency_contact_phone)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

$stmt = $conn->prepare($sql);
$stmt->bind_param('sssssssiisssssss', $memberCode, $full_name, $nickname, $address, $dukuh, $rt, $rw,
                  $kabupaten_id, $kecamatan_id, $kelurahan_id, $birth_place, $birth_date,
                  $phone, $identity_number, $emergency_contact_name, $emergency_contact_phone);

if (!$stmt->execute()) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Failed to create member: ' . $stmt->error
    ]);
    $stmt->close();
    closeConnection($conn);
    exit();
}

$memberId = $conn->insert_id;
$stmt->close();

// Fetch created member
$sql = "SELECT m.*, k.name as kabupaten_name, kec.name as kecamatan_name, kel.name as kelurahan_name
        FROM members m
        LEFT JOIN kabupaten k ON m.kabupaten_id = k.id
        LEFT JOIN kecamatan kec ON m.kecamatan_id = kec.id
        LEFT JOIN kelurahan kel ON m.kelurahan_id = kel.id
        WHERE m.id = ?";
$member = fetchOne($conn, $sql, [$memberId]);

echo json_encode([
    'success' => true,
    'message' => 'Member created successfully',
    'data' => $member
]);

closeConnection($conn);
?>
