<?php
/**
 * Settings API
 * Endpoint: GET/POST /api/master/settings.php
 * GET - Get all settings
 * POST - Update settings (Admin only)
 */

require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../config/auth.php';

// Authenticate user
$user = authenticate();

// Get database connection
$conn = getConnection();

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Get all settings
    $sql = "SELECT setting_key, setting_value, description FROM settings ORDER BY setting_key ASC";
    $settings = fetchAll($conn, $sql);

    // Convert to key-value object
    $settingsObj = [];
    foreach ($settings as $setting) {
        $settingsObj[$setting['setting_key']] = [
            'value' => $setting['setting_value'],
            'description' => $setting['description']
        ];
    }

    echo json_encode([
        'success' => true,
        'data' => $settingsObj
    ], JSON_NUMERIC_CHECK);

} elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Update settings (Admin only)
    requireAdmin($user);

    // Get JSON input
    $input = json_decode(file_get_contents('php://input'), true);

    if (!isset($input['settings']) || !is_array($input['settings'])) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Settings array is required'
        ], JSON_NUMERIC_CHECK);
        closeConnection($conn);
        exit();
    }

    // Start transaction
    $conn->begin_transaction();

    try {
        foreach ($input['settings'] as $key => $value) {
            // Update or insert setting
            $sql = "INSERT INTO settings (setting_key, setting_value) 
                    VALUES (?, ?)
                    ON DUPLICATE KEY UPDATE setting_value = ?";
            
            $stmt = $conn->prepare($sql);
            $stmt->bind_param('sss', $key, $value, $value);
            
            if (!$stmt->execute()) {
                throw new Exception('Failed to update setting: ' . $key);
            }
            
            $stmt->close();
        }

        // Commit transaction
        $conn->commit();

        // Get updated settings
        $sql = "SELECT setting_key, setting_value, description FROM settings ORDER BY setting_key ASC";
        $settings = fetchAll($conn, $sql);

        $settingsObj = [];
        foreach ($settings as $setting) {
            $settingsObj[$setting['setting_key']] = [
                'value' => $setting['setting_value'],
                'description' => $setting['description']
            ];
        }

        echo json_encode([
            'success' => true,
            'message' => 'Settings updated successfully',
            'data' => $settingsObj
        ], JSON_NUMERIC_CHECK);

    } catch (Exception $e) {
        $conn->rollback();
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => $e->getMessage()
        ], JSON_NUMERIC_CHECK);
    }

} else {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Method not allowed'
    ], JSON_NUMERIC_CHECK);
}

closeConnection($conn);
?>
