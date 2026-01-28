<?php
/**
 * CORS Configuration
 * Enable Cross-Origin Resource Sharing for Flutter app
 */

// Configure allowed origins - UPDATE THIS FOR PRODUCTION
$allowed_origins = ['*']; // In production, change to: ['https://your-frontend-domain.com']
$origin = isset($_SERVER['HTTP_ORIGIN']) ? $_SERVER['HTTP_ORIGIN'] : '';

if (in_array('*', $allowed_origins) || in_array($origin, $allowed_origins)) {
    header('Access-Control-Allow-Origin: ' . ($origin ?: '*'));
}

header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Content-Type: application/json; charset=UTF-8');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}
?>
