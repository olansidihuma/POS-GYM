<?php
/**
 * Create Transaction API
 * Endpoint: POST /api/pos/create_transaction.php
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
if (!isset($input['items']) || !is_array($input['items']) || empty($input['items'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Transaction items are required'
    ]);
    exit();
}

if (!isset($input['payment_method']) || empty($input['payment_method'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Payment method is required'
    ]);
    exit();
}

if (!isset($input['payment_amount']) || $input['payment_amount'] <= 0) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Payment amount is required'
    ]);
    exit();
}

// Get database connection
$conn = getConnection();

// Start transaction
$conn->begin_transaction();

try {
    // Generate transaction code
    $year = date('Y');
    $month = date('m');
    $sql = "SELECT transaction_code FROM transactions 
            WHERE transaction_code LIKE ? 
            ORDER BY transaction_code DESC LIMIT 1";
    $lastTransaction = fetchOne($conn, $sql, ["TRX{$year}{$month}%"]);

    if ($lastTransaction) {
        $lastNumber = intval(substr($lastTransaction['transaction_code'], 10));
        $newNumber = $lastNumber + 1;
    } else {
        $newNumber = 1;
    }

    $transactionCode = "TRX{$year}{$month}" . str_pad($newNumber, 4, '0', STR_PAD_LEFT);

    // Calculate amounts
    $subtotal = 0;
    $items = $input['items'];

    // Validate and calculate subtotal
    foreach ($items as $item) {
        if (!isset($item['product_id']) || !isset($item['quantity']) || $item['quantity'] <= 0) {
            throw new Exception('Invalid item data');
        }

        // Get product details
        $productSql = "SELECT id, name, price, discount, stock FROM products WHERE id = ? AND status = 'active'";
        $product = fetchOne($conn, $productSql, [intval($item['product_id'])]);

        if (!$product) {
            throw new Exception("Product not found: " . $item['product_id']);
        }

        // Check stock
        if ($product['stock'] < $item['quantity']) {
            throw new Exception("Insufficient stock for product: " . $product['name']);
        }

        $itemPrice = $product['price'];
        $itemDiscount = $product['discount'];
        $itemQuantity = intval($item['quantity']);
        $itemSubtotal = ($itemPrice - ($itemPrice * $itemDiscount / 100)) * $itemQuantity;
        
        $subtotal += $itemSubtotal;
    }

    // Get settings for service charge and tax
    $serviceSql = "SELECT setting_value FROM settings WHERE setting_key = 'service_charge_percent'";
    $serviceCharge = fetchOne($conn, $serviceSql);
    $serviceChargePercent = $serviceCharge ? floatval($serviceCharge['setting_value']) : 0;

    $taxSql = "SELECT setting_value FROM settings WHERE setting_key = 'tax_percent'";
    $taxSetting = fetchOne($conn, $taxSql);
    $taxPercent = $taxSetting ? floatval($taxSetting['setting_value']) : 0;

    // Calculate charges
    $discountAmount = isset($input['discount_amount']) ? floatval($input['discount_amount']) : 0;
    $serviceChargeAmount = ($subtotal - $discountAmount) * ($serviceChargePercent / 100);
    $taxAmount = ($subtotal - $discountAmount + $serviceChargeAmount) * ($taxPercent / 100);
    $totalAmount = $subtotal - $discountAmount + $serviceChargeAmount + $taxAmount;
    $paymentAmount = floatval($input['payment_amount']);
    $changeAmount = $paymentAmount - $totalAmount;

    if ($changeAmount < 0) {
        throw new Exception('Payment amount is less than total amount');
    }

    // Insert transaction
    $paymentMethod = $input['payment_method'];
    $paymentProof = isset($input['payment_proof']) ? trim($input['payment_proof']) : null;
    $notes = isset($input['notes']) ? trim($input['notes']) : null;
    $createdBy = $user['user_id'];

    $sql = "INSERT INTO transactions (transaction_code, subtotal, discount_amount, 
                                     service_charge_percent, service_charge_amount,
                                     tax_percent, tax_amount, total_amount,
                                     payment_method, payment_proof, payment_amount, 
                                     change_amount, notes, created_by, status)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'completed')";

    $stmt = $conn->prepare($sql);
    $stmt->bind_param('sdddddddssddsi', $transactionCode, $subtotal, $discountAmount,
                     $serviceChargePercent, $serviceChargeAmount, $taxPercent, $taxAmount,
                     $totalAmount, $paymentMethod, $paymentProof, $paymentAmount,
                     $changeAmount, $notes, $createdBy);

    if (!$stmt->execute()) {
        throw new Exception('Failed to create transaction: ' . $stmt->error);
    }

    $transactionId = $conn->insert_id;
    $stmt->close();

    // Insert transaction items and update stock
    foreach ($items as $item) {
        $productId = intval($item['product_id']);
        $quantity = intval($item['quantity']);
        $itemNotes = isset($item['notes']) ? trim($item['notes']) : null;

        // Get product details again
        $productSql = "SELECT name, price, discount FROM products WHERE id = ?";
        $product = fetchOne($conn, $productSql, [$productId]);

        $price = $product['price'];
        $discount = $product['discount'];
        $itemSubtotal = ($price - ($price * $discount / 100)) * $quantity;

        // Insert transaction item
        $itemSql = "INSERT INTO transaction_items (transaction_id, product_id, product_name, 
                                                   quantity, price, discount, subtotal, notes)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        
        $stmt = $conn->prepare($itemSql);
        $stmt->bind_param('iisiddds', $transactionId, $productId, $product['name'],
                         $quantity, $price, $discount, $itemSubtotal, $itemNotes);

        if (!$stmt->execute()) {
            throw new Exception('Failed to insert transaction item: ' . $stmt->error);
        }
        $stmt->close();

        // Update product stock
        $updateStockSql = "UPDATE products SET stock = stock - ? WHERE id = ?";
        $stmt = $conn->prepare($updateStockSql);
        $stmt->bind_param('ii', $quantity, $productId);
        
        if (!$stmt->execute()) {
            throw new Exception('Failed to update product stock: ' . $stmt->error);
        }
        $stmt->close();
    }

    // Commit transaction
    $conn->commit();

    // Fetch created transaction with items
    $fetchSql = "SELECT t.*, u.full_name as created_by_name
                 FROM transactions t
                 INNER JOIN users u ON t.created_by = u.id
                 WHERE t.id = ?";
    $transaction = fetchOne($conn, $fetchSql, [$transactionId]);

    $itemsSql = "SELECT ti.*, p.image as product_image
                 FROM transaction_items ti
                 LEFT JOIN products p ON ti.product_id = p.id
                 WHERE ti.transaction_id = ?";
    $transactionItems = fetchAll($conn, $itemsSql, [$transactionId]);

    $transaction['items'] = $transactionItems;

    echo json_encode([
        'success' => true,
        'message' => 'Transaction created successfully',
        'data' => $transaction
    ]);

} catch (Exception $e) {
    $conn->rollback();
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}

closeConnection($conn);
?>
