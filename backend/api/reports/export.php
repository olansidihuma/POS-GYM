<?php
/**
 * Report Export API
 * Endpoint: GET /api/reports/export.php
 * Export reports in various formats (JSON data for client-side PDF/Excel generation)
 * Query Params: report_type, date_from, date_to, format
 */

require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../config/auth.php';

// Authenticate user
$user = authenticate();

// Get database connection
$conn = getConnection();

// Get query parameters
$reportType = isset($_GET['report_type']) ? $_GET['report_type'] : 'daily_sales';
$dateFrom = isset($_GET['date_from']) ? $_GET['date_from'] : date('Y-m-01');
$dateTo = isset($_GET['date_to']) ? $_GET['date_to'] : date('Y-m-d');
$format = isset($_GET['format']) ? $_GET['format'] : 'json';

// Validate date format
if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $dateFrom) || !strtotime($dateFrom)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Invalid date_from format. Use YYYY-MM-DD'
    ], JSON_NUMERIC_CHECK);
    closeConnection($conn);
    exit();
}

if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $dateTo) || !strtotime($dateTo)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Invalid date_to format. Use YYYY-MM-DD'
    ], JSON_NUMERIC_CHECK);
    closeConnection($conn);
    exit();
}

$reportData = [];
$reportTitle = '';
$columns = [];
$rows = [];

switch ($reportType) {
    case 'daily_sales':
        $reportTitle = 'Daily Sales Report';
        $columns = ['Date', 'Transaction Count', 'Total Sales', 'Cash', 'Transfer', 'QRIS'];
        
        $sql = "SELECT 
                    DATE(created_at) as sale_date,
                    COUNT(*) as transaction_count,
                    SUM(total_amount) as total_sales,
                    SUM(CASE WHEN payment_method = 'cash' THEN total_amount ELSE 0 END) as cash_sales,
                    SUM(CASE WHEN payment_method = 'transfer' THEN total_amount ELSE 0 END) as transfer_sales,
                    SUM(CASE WHEN payment_method = 'qris' THEN total_amount ELSE 0 END) as qris_sales
                FROM transactions
                WHERE status = 'completed'
                AND DATE(created_at) BETWEEN ? AND ?
                GROUP BY DATE(created_at)
                ORDER BY sale_date DESC";
        
        $rows = fetchAll($conn, $sql, [$dateFrom, $dateTo]);
        break;

    case 'monthly_sales':
        $reportTitle = 'Monthly Sales Report';
        $columns = ['Month', 'Transaction Count', 'Total Sales', 'Avg Transaction'];
        
        $sql = "SELECT 
                    DATE_FORMAT(created_at, '%Y-%m') as sale_month,
                    COUNT(*) as transaction_count,
                    SUM(total_amount) as total_sales,
                    AVG(total_amount) as avg_transaction
                FROM transactions
                WHERE status = 'completed'
                AND DATE(created_at) BETWEEN ? AND ?
                GROUP BY DATE_FORMAT(created_at, '%Y-%m')
                ORDER BY sale_month DESC";
        
        $rows = fetchAll($conn, $sql, [$dateFrom, $dateTo]);
        break;

    case 'attendance':
        $reportTitle = 'Attendance Report';
        $columns = ['Date', 'Member Check-ins', 'Non-Member Check-ins', 'Total', 'Non-Member Revenue'];
        
        $sql = "SELECT 
                    DATE(check_in_time) as attendance_date,
                    SUM(CASE WHEN attendance_type = 'member' THEN 1 ELSE 0 END) as member_checkins,
                    SUM(CASE WHEN attendance_type = 'non_member' THEN 1 ELSE 0 END) as non_member_checkins,
                    COUNT(*) as total_checkins,
                    SUM(CASE WHEN attendance_type = 'non_member' THEN amount ELSE 0 END) as non_member_revenue
                FROM attendances
                WHERE DATE(check_in_time) BETWEEN ? AND ?
                GROUP BY DATE(check_in_time)
                ORDER BY attendance_date DESC";
        
        $rows = fetchAll($conn, $sql, [$dateFrom, $dateTo]);
        break;

    case 'members':
        $reportTitle = 'Member Report';
        $columns = ['Member Code', 'Full Name', 'Phone', 'Membership Status', 'Expiry Date'];
        
        $sql = "SELECT 
                    m.member_code,
                    m.full_name,
                    m.phone,
                    CASE 
                        WHEN ms.end_date >= CURDATE() THEN 'Active'
                        ELSE 'Expired'
                    END as membership_status,
                    ms.end_date as expiry_date
                FROM members m
                LEFT JOIN (
                    SELECT member_id, MAX(end_date) as end_date
                    FROM membership_subscriptions
                    GROUP BY member_id
                ) ms ON m.id = ms.member_id
                WHERE m.status = 'active'
                ORDER BY m.full_name ASC";
        
        $rows = fetchAll($conn, $sql);
        break;

    case 'financial':
        requireAdmin($user);
        $reportTitle = 'Financial Report';
        $columns = ['Category', 'Type', 'Amount'];
        
        // Get income from transactions
        $posSales = fetchOne($conn, 
            "SELECT COALESCE(SUM(total_amount), 0) as amount FROM transactions 
             WHERE status = 'completed' AND DATE(created_at) BETWEEN ? AND ?",
            [$dateFrom, $dateTo]
        );
        
        // Get membership income
        $membershipIncome = fetchOne($conn,
            "SELECT COALESCE(SUM(amount), 0) as amount FROM membership_subscriptions 
             WHERE DATE(created_at) BETWEEN ? AND ?",
            [$dateFrom, $dateTo]
        );
        
        // Get attendance income
        $attendanceIncome = fetchOne($conn,
            "SELECT COALESCE(SUM(amount), 0) as amount FROM attendances 
             WHERE attendance_type = 'non_member' AND DATE(check_in_time) BETWEEN ? AND ?",
            [$dateFrom, $dateTo]
        );
        
        // Get expenses
        $expenses = fetchOne($conn,
            "SELECT COALESCE(SUM(amount), 0) as amount FROM expenses 
             WHERE expense_date BETWEEN ? AND ?",
            [$dateFrom, $dateTo]
        );
        
        $totalIncome = floatval($posSales['amount']) + floatval($membershipIncome['amount']) + floatval($attendanceIncome['amount']);
        $totalExpenses = floatval($expenses['amount']);
        $netProfit = $totalIncome - $totalExpenses;
        
        $rows = [
            ['category' => 'Income', 'type' => 'POS Sales', 'amount' => $posSales['amount']],
            ['category' => 'Income', 'type' => 'Membership Fees', 'amount' => $membershipIncome['amount']],
            ['category' => 'Income', 'type' => 'Attendance Fees', 'amount' => $attendanceIncome['amount']],
            ['category' => 'Income', 'type' => 'Total Income', 'amount' => $totalIncome],
            ['category' => 'Expenses', 'type' => 'Total Expenses', 'amount' => $totalExpenses],
            ['category' => 'Summary', 'type' => 'Net Profit/Loss', 'amount' => $netProfit],
        ];
        break;

    case 'expenses':
        requireAdmin($user);
        $reportTitle = 'Expense Report';
        $columns = ['Date', 'Type', 'Amount', 'Notes'];
        
        $sql = "SELECT 
                    e.expense_date as date,
                    et.name as expense_type,
                    e.amount,
                    e.notes
                FROM expenses e
                INNER JOIN expense_types et ON e.expense_type_id = et.id
                WHERE e.expense_date BETWEEN ? AND ?
                ORDER BY e.expense_date DESC";
        
        $rows = fetchAll($conn, $sql, [$dateFrom, $dateTo]);
        break;

    case 'revenue':
        requireAdmin($user);
        $reportTitle = 'Revenue Report';
        $columns = ['Date', 'Source', 'Amount'];
        
        // Combine all revenue sources
        $posSql = "SELECT DATE(created_at) as date, 'POS Sales' as source, total_amount as amount
                   FROM transactions
                   WHERE status = 'completed' AND DATE(created_at) BETWEEN ? AND ?";
        $pos = fetchAll($conn, $posSql, [$dateFrom, $dateTo]);
        
        $membershipSql = "SELECT DATE(created_at) as date, 'Membership' as source, amount
                          FROM membership_subscriptions
                          WHERE DATE(created_at) BETWEEN ? AND ?";
        $membership = fetchAll($conn, $membershipSql, [$dateFrom, $dateTo]);
        
        $attendanceSql = "SELECT DATE(check_in_time) as date, 'Attendance' as source, amount
                          FROM attendances
                          WHERE attendance_type = 'non_member' AND DATE(check_in_time) BETWEEN ? AND ?";
        $attendance = fetchAll($conn, $attendanceSql, [$dateFrom, $dateTo]);
        
        $rows = array_merge($pos, $membership, $attendance);
        
        // Sort by date
        usort($rows, function($a, $b) {
            return strcmp($b['date'], $a['date']);
        });
        break;

    case 'inventory':
        requireAdmin($user);
        $reportTitle = 'Inventory Report';
        $columns = ['Product Code', 'Product Name', 'Category', 'Price', 'Stock', 'Status'];
        
        $sql = "SELECT 
                    p.id as product_code,
                    p.name as product_name,
                    pc.name as category,
                    p.price,
                    p.stock,
                    p.status
                FROM products p
                INNER JOIN product_categories pc ON p.category_id = pc.id
                ORDER BY pc.name, p.name ASC";
        
        $rows = fetchAll($conn, $sql);
        break;

    default:
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Invalid report type'
        ], JSON_NUMERIC_CHECK);
        closeConnection($conn);
        exit();
}

// Calculate summary totals
$summary = [];
if (in_array($reportType, ['daily_sales', 'monthly_sales'])) {
    $summary['total_transactions'] = array_sum(array_column($rows, 'transaction_count'));
    $summary['total_sales'] = array_sum(array_column($rows, 'total_sales'));
}
if ($reportType === 'attendance') {
    $summary['total_member_checkins'] = array_sum(array_column($rows, 'member_checkins'));
    $summary['total_non_member_checkins'] = array_sum(array_column($rows, 'non_member_checkins'));
    $summary['total_checkins'] = array_sum(array_column($rows, 'total_checkins'));
    $summary['total_revenue'] = array_sum(array_column($rows, 'non_member_revenue'));
}

echo json_encode([
    'success' => true,
    'data' => [
        'report_title' => $reportTitle,
        'period' => [
            'from' => $dateFrom,
            'to' => $dateTo
        ],
        'columns' => $columns,
        'rows' => $rows,
        'summary' => $summary,
        'generated_at' => date('Y-m-d H:i:s'),
        'generated_by' => $user['full_name']
    ]
], JSON_NUMERIC_CHECK);

closeConnection($conn);
?>
