<?php
/**
 * Regions API (Kabupaten, Kecamatan, Kelurahan)
 * Endpoint: GET /api/master/regions.php
 * Query Params: type (kabupaten, kecamatan, kelurahan), kabupaten_id, kecamatan_id
 */

require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../config/auth.php';

// Authenticate user
$user = authenticate();

// Get database connection
$conn = getConnection();

// Get query parameters
$type = isset($_GET['type']) ? $_GET['type'] : 'kabupaten';

if (!in_array($type, ['kabupaten', 'kecamatan', 'kelurahan'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Invalid type. Use: kabupaten, kecamatan, or kelurahan'
    ]);
    closeConnection($conn);
    exit();
}

$data = [];

if ($type === 'kabupaten') {
    // Get all kabupaten
    $sql = "SELECT id, name FROM kabupaten WHERE status = 'active' ORDER BY name ASC";
    $data = fetchAll($conn, $sql);

} elseif ($type === 'kecamatan') {
    // Get kecamatan by kabupaten_id
    if (!isset($_GET['kabupaten_id']) || empty($_GET['kabupaten_id'])) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'kabupaten_id is required for kecamatan'
        ]);
        closeConnection($conn);
        exit();
    }

    $kabupatenId = intval($_GET['kabupaten_id']);
    $sql = "SELECT id, kabupaten_id, name 
            FROM kecamatan 
            WHERE kabupaten_id = ? AND status = 'active' 
            ORDER BY name ASC";
    $data = fetchAll($conn, $sql, [$kabupatenId]);

} elseif ($type === 'kelurahan') {
    // Get kelurahan by kecamatan_id
    if (!isset($_GET['kecamatan_id']) || empty($_GET['kecamatan_id'])) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'kecamatan_id is required for kelurahan'
        ]);
        closeConnection($conn);
        exit();
    }

    $kecamatanId = intval($_GET['kecamatan_id']);
    $sql = "SELECT id, kecamatan_id, name 
            FROM kelurahan 
            WHERE kecamatan_id = ? AND status = 'active' 
            ORDER BY name ASC";
    $data = fetchAll($conn, $sql, [$kecamatanId]);
}

echo json_encode([
    'success' => true,
    'data' => $data
]);

closeConnection($conn);
?>
