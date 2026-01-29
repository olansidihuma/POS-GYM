<?php
/**
 * Regions API (Provinsi, Kabupaten, Kecamatan, Kelurahan)
 * Endpoint: GET /api/master/regions.php
 * Query Params: type (provinsi, kabupaten, kecamatan, kelurahan), provinsi_id, kabupaten_id, kecamatan_id
 */

require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../config/auth.php';

// Authenticate user
$user = authenticate();

// Get database connection
$conn = getConnection();

// Get query parameters
$type = isset($_GET['type']) ? $_GET['type'] : 'provinsi';

if (!in_array($type, ['provinsi', 'kabupaten', 'kecamatan', 'kelurahan'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Invalid type. Use: provinsi, kabupaten, kecamatan, or kelurahan'
    ], JSON_NUMERIC_CHECK);
    closeConnection($conn);
    exit();
}

$data = [];

if ($type === 'provinsi') {
    // Get all provinsi
    $sql = "SELECT id, name FROM provinsi WHERE status = 'active' ORDER BY name ASC";
    $data = fetchAll($conn, $sql);

} elseif ($type === 'kabupaten') {
    // Get kabupaten by provinsi_id (optional - if not provided, get all)
    if (isset($_GET['provinsi_id']) && !empty($_GET['provinsi_id'])) {
        $provinsiId = intval($_GET['provinsi_id']);
        $sql = "SELECT id, provinsi_id, name 
                FROM kabupaten 
                WHERE provinsi_id = ? AND status = 'active' 
                ORDER BY name ASC";
        $data = fetchAll($conn, $sql, [$provinsiId]);
    } else {
        // Get all kabupaten
        $sql = "SELECT id, provinsi_id, name FROM kabupaten WHERE status = 'active' ORDER BY name ASC";
        $data = fetchAll($conn, $sql);
    }

} elseif ($type === 'kecamatan') {
    // Get kecamatan by kabupaten_id
    if (!isset($_GET['kabupaten_id']) || empty($_GET['kabupaten_id'])) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'kabupaten_id is required for kecamatan'
        ], JSON_NUMERIC_CHECK);
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
        ], JSON_NUMERIC_CHECK);
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
], JSON_NUMERIC_CHECK);

closeConnection($conn);
?>
