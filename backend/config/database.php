<?php
/**
 * Database Configuration and Connection
 */

// Database configuration
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_NAME', 'gym_management');

// Create database connection
function getConnection() {
    $conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);
    
    if ($conn->connect_error) {
        die(json_encode([
            'success' => false,
            'message' => 'Database connection failed: ' . $conn->connect_error
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
        return [
            'success' => false,
            'message' => 'Query preparation failed: ' . $conn->error
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
        return [
            'success' => false,
            'message' => 'Query execution failed: ' . $stmt->error
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
