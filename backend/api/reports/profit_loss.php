<?php
/**
 * Profit & Loss Report API
 * Endpoint: GET /api/reports/profit_loss.php
 * Admin only
 * Query Params: date_from, date_to
 */

require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../config/auth.php';

// Authenticate user
$user = authenticate();

// Check admin role
requireAdmin($user);

// Get database connection
$conn = getConnection();

// Get query parameters
$dateFrom = isset($_GET['date_from']) ? $_GET['date_from'] : date('Y-m-01'); // First day of current month
$dateTo = isset($_GET['date_to']) ? $_GET['date_to'] : date('Y-m-d'); // Today

// Validate date format
if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $dateFrom) || !strtotime($dateFrom)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Invalid date_from format. Use YYYY-MM-DD'
    ]);
    closeConnection($conn);
    exit();
}

if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $dateTo) || !strtotime($dateTo)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Invalid date_to format. Use YYYY-MM-DD'
    ]);
    closeConnection($conn);
    exit();
}

// Validate date range
if (strtotime($dateFrom) > strtotime($dateTo)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Invalid date range'
    ]);
    closeConnection($conn);
    exit();
}

// Get income from transactions (POS Sales)
$transSql = "SELECT COALESCE(SUM(total_amount), 0) as amount
             FROM transactions
             WHERE status = 'completed' 
             AND DATE(created_at) BETWEEN ? AND ?";
$transIncome = fetchOne($conn, $transSql, [$dateFrom, $dateTo]);
$posIncome = floatval($transIncome['amount']);

// Get income from membership subscriptions
$membershipSql = "SELECT COALESCE(SUM(amount), 0) as amount
                  FROM membership_subscriptions
                  WHERE DATE(created_at) BETWEEN ? AND ?";
$membershipIncome = fetchOne($conn, $membershipSql, [$dateFrom, $dateTo]);
$membershipAmount = floatval($membershipIncome['amount']);

// Get income from non-member attendance
$attendanceSql = "SELECT COALESCE(SUM(amount), 0) as amount
                  FROM attendances
                  WHERE attendance_type = 'non_member'
                  AND DATE(check_in_time) BETWEEN ? AND ?";
$attendanceIncome = fetchOne($conn, $attendanceSql, [$dateFrom, $dateTo]);
$attendanceAmount = floatval($attendanceIncome['amount']);

// Get other incomes from incomes table
$incomesSql = "SELECT COALESCE(SUM(amount), 0) as amount
               FROM incomes
               WHERE income_date BETWEEN ? AND ?";
$otherIncomes = fetchOne($conn, $incomesSql, [$dateFrom, $dateTo]);
$otherIncomesAmount = floatval($otherIncomes['amount']);

// Get income breakdown by type
$incomeTypeSql = "SELECT it.name, COALESCE(SUM(i.amount), 0) as amount
                  FROM income_types it
                  LEFT JOIN incomes i ON it.id = i.income_type_id 
                    AND i.income_date BETWEEN ? AND ?
                  WHERE it.status = 'active'
                  GROUP BY it.id, it.name
                  ORDER BY amount DESC";
$incomeByType = fetchAll($conn, $incomeTypeSql, [$dateFrom, $dateTo]);

// Calculate total income
$totalIncome = $posIncome + $membershipAmount + $attendanceAmount + $otherIncomesAmount;

// Get expenses
$expensesSql = "SELECT COALESCE(SUM(amount), 0) as amount
                FROM expenses
                WHERE expense_date BETWEEN ? AND ?";
$expensesResult = fetchOne($conn, $expensesSql, [$dateFrom, $dateTo]);
$totalExpenses = floatval($expensesResult['amount']);

// Get expense breakdown by type
$expenseTypeSql = "SELECT et.name, COALESCE(SUM(e.amount), 0) as amount
                   FROM expense_types et
                   LEFT JOIN expenses e ON et.id = e.expense_type_id 
                     AND e.expense_date BETWEEN ? AND ?
                   WHERE et.status = 'active'
                   GROUP BY et.id, et.name
                   ORDER BY amount DESC";
$expenseByType = fetchAll($conn, $expenseTypeSql, [$dateFrom, $dateTo]);

// Calculate profit/loss
$profitLoss = $totalIncome - $totalExpenses;
$profitMargin = $totalIncome > 0 ? ($profitLoss / $totalIncome) * 100 : 0;

// Get transaction statistics
$transStatsSql = "SELECT 
                    COUNT(*) as total_transactions,
                    AVG(total_amount) as average_transaction,
                    MIN(total_amount) as min_transaction,
                    MAX(total_amount) as max_transaction
                  FROM transactions
                  WHERE status = 'completed'
                  AND DATE(created_at) BETWEEN ? AND ?";
$transStats = fetchOne($conn, $transStatsSql, [$dateFrom, $dateTo]);

// Get membership statistics
$memberStatsSql = "SELECT 
                    COUNT(*) as total_subscriptions,
                    COUNT(DISTINCT member_id) as unique_members
                   FROM membership_subscriptions
                   WHERE DATE(created_at) BETWEEN ? AND ?";
$memberStats = fetchOne($conn, $memberStatsSql, [$dateFrom, $dateTo]);

// Get attendance statistics
$attendStatsSql = "SELECT 
                    COUNT(*) as total_visits,
                    SUM(CASE WHEN attendance_type = 'member' THEN 1 ELSE 0 END) as member_visits,
                    SUM(CASE WHEN attendance_type = 'non_member' THEN 1 ELSE 0 END) as non_member_visits
                   FROM attendances
                   WHERE DATE(check_in_time) BETWEEN ? AND ?";
$attendStats = fetchOne($conn, $attendStatsSql, [$dateFrom, $dateTo]);

// Top selling products
$topProductsSql = "SELECT 
                    ti.product_name,
                    SUM(ti.quantity) as total_quantity,
                    SUM(ti.subtotal) as total_revenue
                   FROM transaction_items ti
                   INNER JOIN transactions t ON ti.transaction_id = t.id
                   WHERE t.status = 'completed'
                   AND DATE(t.created_at) BETWEEN ? AND ?
                   GROUP BY ti.product_id, ti.product_name
                   ORDER BY total_revenue DESC
                   LIMIT 10";
$topProducts = fetchAll($conn, $topProductsSql, [$dateFrom, $dateTo]);

echo json_encode([
    'success' => true,
    'data' => [
        'period' => [
            'from' => $dateFrom,
            'to' => $dateTo
        ],
        'summary' => [
            'total_income' => $totalIncome,
            'total_expenses' => $totalExpenses,
            'profit_loss' => $profitLoss,
            'profit_margin_percent' => round($profitMargin, 2)
        ],
        'income_breakdown' => [
            'pos_sales' => $posIncome,
            'membership_fees' => $membershipAmount,
            'attendance_fees' => $attendanceAmount,
            'other_incomes' => $otherIncomesAmount,
            'by_type' => $incomeByType
        ],
        'expense_breakdown' => [
            'total' => $totalExpenses,
            'by_type' => $expenseByType
        ],
        'statistics' => [
            'transactions' => $transStats,
            'memberships' => $memberStats,
            'attendance' => $attendStats
        ],
        'top_products' => $topProducts
    ]
]);

closeConnection($conn);
?>
