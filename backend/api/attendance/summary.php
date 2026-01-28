<?php
/**
 * Attendance Summary API
 * Endpoint: GET /api/attendance/summary.php
 * Query Params: date, period (daily, monthly)
 */

require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../config/auth.php';

// Authenticate user
$user = authenticate();

// Get database connection
$conn = getConnection();

// Get query parameters
$date = isset($_GET['date']) ? $_GET['date'] : date('Y-m-d');
$period = isset($_GET['period']) ? $_GET['period'] : 'daily';

if (!in_array($period, ['daily', 'monthly'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Invalid period. Use daily or monthly'
    ]);
    closeConnection($conn);
    exit();
}

// Build date condition
if ($period === 'daily') {
    $dateCondition = "DATE(a.check_in_time) = ?";
    $dateParam = $date;
} else {
    // Monthly
    $yearMonth = substr($date, 0, 7); // YYYY-MM
    $dateCondition = "DATE_FORMAT(a.check_in_time, '%Y-%m') = ?";
    $dateParam = $yearMonth;
}

// Get total attendances by type
$sql = "SELECT 
            COUNT(*) as total_attendances,
            SUM(CASE WHEN a.attendance_type = 'member' THEN 1 ELSE 0 END) as member_count,
            SUM(CASE WHEN a.attendance_type = 'non_member' THEN 1 ELSE 0 END) as non_member_count,
            SUM(a.amount) as total_revenue
        FROM attendances a
        WHERE {$dateCondition}";

$summary = fetchOne($conn, $sql, [$dateParam]);

// Get hourly breakdown for daily
$hourlyBreakdown = [];
if ($period === 'daily') {
    $hourlySql = "SELECT 
                    HOUR(a.check_in_time) as hour,
                    COUNT(*) as count,
                    SUM(CASE WHEN a.attendance_type = 'member' THEN 1 ELSE 0 END) as member_count,
                    SUM(CASE WHEN a.attendance_type = 'non_member' THEN 1 ELSE 0 END) as non_member_count
                  FROM attendances a
                  WHERE DATE(a.check_in_time) = ?
                  GROUP BY HOUR(a.check_in_time)
                  ORDER BY hour";
    $hourlyBreakdown = fetchAll($conn, $hourlySql, [$dateParam]);
}

// Get daily breakdown for monthly
$dailyBreakdown = [];
if ($period === 'monthly') {
    $dailySql = "SELECT 
                    DATE(a.check_in_time) as date,
                    COUNT(*) as count,
                    SUM(CASE WHEN a.attendance_type = 'member' THEN 1 ELSE 0 END) as member_count,
                    SUM(CASE WHEN a.attendance_type = 'non_member' THEN 1 ELSE 0 END) as non_member_count,
                    SUM(a.amount) as revenue
                 FROM attendances a
                 WHERE DATE_FORMAT(a.check_in_time, '%Y-%m') = ?
                 GROUP BY DATE(a.check_in_time)
                 ORDER BY date";
    $dailyBreakdown = fetchAll($conn, $dailySql, [$dateParam]);
}

$response = [
    'success' => true,
    'data' => [
        'period' => $period,
        'date' => $dateParam,
        'summary' => $summary
    ]
];

if ($period === 'daily') {
    $response['data']['hourly_breakdown'] = $hourlyBreakdown;
} else {
    $response['data']['daily_breakdown'] = $dailyBreakdown;
}

echo json_encode($response);

closeConnection($conn);
?>
