<?php
/**
 * Database Configuration and Connection
 */

// Database configuration
// TODO: Move these to environment variables for production
define('DB_HOST', getenv('DB_HOST') ?: 'localhost');
define('DB_USER', getenv('DB_USER') ?: 'root');
define('DB_PASS', getenv('DB_PASS') ?: '');
define('DB_NAME', getenv('DB_NAME') ?: 'gym_management');

// Create database connection
function getConnection() {
    $conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);
    
    if ($conn->connect_error) {
        // Log error details server-side
        error_log('Database connection failed: ' . $conn->connect_error);
        // Return generic error to client
        die(json_encode([
            'success' => false,
            'message' => 'Database connection failed. Please try again later.'
        ]));
    }
    
    $conn->set_charset('utf8mb4');
    return $conn;
}

// Close database connection
function closeConnection($conn) {
    if ($conn) {
        $conn->close();
    }
}

// Execute query and return result
function executeQuery($conn, $sql, $params = []) {
    $stmt = $conn->prepare($sql);
    
    if (!$stmt) {
        error_log('Query preparation failed: ' . $conn->error);
        return [
            'success' => false,
            'message' => 'Query preparation failed. Please try again.'
        ];
    }
    
    if (!empty($params)) {
        $types = '';
        $values = [];
        
        foreach ($params as $param) {
            if (is_int($param)) {
                $types .= 'i';
            } elseif (is_double($param)) {
                $types .= 'd';
            } else {
                $types .= 's';
            }
            $values[] = $param;
        }
        
        $stmt->bind_param($types, ...$values);
    }
    
    if (!$stmt->execute()) {
        error_log('Query execution failed: ' . $stmt->error);
        return [
            'success' => false,
            'message' => 'Query execution failed. Please try again.'
        ];
    }
    
    $result = $stmt->get_result();
    $stmt->close();
    
    return [
        'success' => true,
        'result' => $result
    ];
}

// Get single row from query
function fetchOne($conn, $sql, $params = []) {
    $query = executeQuery($conn, $sql, $params);
    
    if (!$query['success']) {
        return null;
    }
    
    return $query['result']->fetch_assoc();
}

// Get all rows from query
function fetchAll($conn, $sql, $params = []) {
    $query = executeQuery($conn, $sql, $params);
    
    if (!$query['success']) {
        return [];
    }
    
    $rows = [];
    while ($row = $query['result']->fetch_assoc()) {
        $rows[] = $row;
    }
    
    return $rows;
}
?>
