class Transaction {
  final int? id;
  final String transactionNumber;
  final String type; // sale, purchase, expense, income
  final DateTime transactionDate;
  final int? memberId;
  final String? memberName;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final String paymentMethod;
  final double paidAmount;
  final double changeAmount;
  final String? notes;
  final List<TransactionItem>? items;
  final int? createdBy;
  final String? createdByName;
  final DateTime? createdAt;

  Transaction({
    this.id,
    required this.transactionNumber,
    required this.type,
    required this.transactionDate,
    this.memberId,
    this.memberName,
    required this.subtotal,
    this.discount = 0,
    this.tax = 0,
    required this.total,
    required this.paymentMethod,
    required this.paidAmount,
    this.changeAmount = 0,
    this.notes,
    this.items,
    this.createdBy,
    this.createdByName,
    this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    try {
      if (json['transaction_date'] != null && json['transaction_date'].toString().isNotEmpty) {
        parsedDate = DateTime.parse(json['transaction_date'].toString());
      }
    } catch (_) {
      parsedDate = null;
    }
    
    return Transaction(
      id: json['id'] is int ? json['id'] : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      transactionNumber: json['transaction_number']?.toString() ?? json['transaction_code']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      transactionDate: parsedDate ?? DateTime.now(),
      memberId: json['member_id'] is int ? json['member_id'] : (json['member_id'] != null ? int.tryParse(json['member_id'].toString()) : null),
      memberName: json['member_name']?.toString(),
      subtotal: json['subtotal'] != null ? double.tryParse(json['subtotal'].toString()) ?? 0.0 : 0.0,
      discount: json['discount'] != null ? double.tryParse(json['discount'].toString()) ?? 0.0 : 0.0,
      tax: json['tax'] != null ? double.tryParse(json['tax'].toString()) ?? 0.0 : 0.0,
      total: json['total'] != null ? double.tryParse(json['total'].toString()) ?? 0.0 : (json['total_amount'] != null ? double.tryParse(json['total_amount'].toString()) ?? 0.0 : 0.0),
      paymentMethod: json['payment_method']?.toString() ?? '',
      paidAmount: json['paid_amount'] != null ? double.tryParse(json['paid_amount'].toString()) ?? 0.0 : (json['payment_amount'] != null ? double.tryParse(json['payment_amount'].toString()) ?? 0.0 : 0.0),
      changeAmount: json['change_amount'] != null ? double.tryParse(json['change_amount'].toString()) ?? 0.0 : 0.0,
      notes: json['notes']?.toString(),
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => TransactionItem.fromJson(item))
              .toList()
          : null,
      createdBy: json['created_by'] is int ? json['created_by'] : (json['created_by'] != null ? int.tryParse(json['created_by'].toString()) : null),
      createdByName: json['created_by_name']?.toString(),
      createdAt: json['created_at'] != null && json['created_at'].toString().isNotEmpty
          ? DateTime.tryParse(json['created_at'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_number': transactionNumber,
      'type': type,
      'transaction_date': transactionDate.toIso8601String().split('T')[0],
      'member_id': memberId,
      'member_name': memberName,
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'total': total,
      'payment_method': paymentMethod,
      'paid_amount': paidAmount,
      'change_amount': changeAmount,
      'notes': notes,
      'items': items?.map((item) => item.toJson()).toList(),
      'created_by': createdBy,
    };
  }
}

class TransactionItem {
  final int? id;
  final int? transactionId;
  final int productId;
  final String productName;
  final double price;
  final int quantity;
  final double subtotal;
  final double discount;
  final double total;

  TransactionItem({
    this.id,
    this.transactionId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.subtotal,
    this.discount = 0,
    required this.total,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id'] is int ? json['id'] : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      transactionId: json['transaction_id'] is int ? json['transaction_id'] : (json['transaction_id'] != null ? int.tryParse(json['transaction_id'].toString()) : null),
      productId: json['product_id'] is int ? json['product_id'] : (json['product_id'] != null ? int.tryParse(json['product_id'].toString()) ?? 0 : 0),
      productName: json['product_name']?.toString() ?? '',
      price: json['price'] != null ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0,
      quantity: json['quantity'] is int ? json['quantity'] : (json['quantity'] != null ? int.tryParse(json['quantity'].toString()) ?? 0 : 0),
      subtotal: json['subtotal'] != null ? double.tryParse(json['subtotal'].toString()) ?? 0.0 : 0.0,
      discount: json['discount'] != null ? double.tryParse(json['discount'].toString()) ?? 0.0 : 0.0,
      total: json['total'] != null ? double.tryParse(json['total'].toString()) ?? 0.0 : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
      'discount': discount,
      'total': total,
    };
  }
}

class Expense {
  final int? id;
  final String expenseNumber;
  final String category;
  final String description;
  final double amount;
  final DateTime expenseDate;
  final String? receipt;
  final String? notes;
  final int? createdBy;
  final String? createdByName;
  final DateTime? createdAt;

  Expense({
    this.id,
    required this.expenseNumber,
    required this.category,
    required this.description,
    required this.amount,
    required this.expenseDate,
    this.receipt,
    this.notes,
    this.createdBy,
    this.createdByName,
    this.createdAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    try {
      if (json['expense_date'] != null && json['expense_date'].toString().isNotEmpty) {
        parsedDate = DateTime.parse(json['expense_date'].toString());
      }
    } catch (_) {
      parsedDate = null;
    }
    
    return Expense(
      id: json['id'] is int ? json['id'] : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      expenseNumber: json['expense_number']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      amount: json['amount'] != null ? double.tryParse(json['amount'].toString()) ?? 0.0 : 0.0,
      expenseDate: parsedDate ?? DateTime.now(),
      receipt: json['receipt']?.toString(),
      notes: json['notes']?.toString(),
      createdBy: json['created_by'] is int ? json['created_by'] : (json['created_by'] != null ? int.tryParse(json['created_by'].toString()) : null),
      createdByName: json['created_by_name']?.toString(),
      createdAt: json['created_at'] != null && json['created_at'].toString().isNotEmpty
          ? DateTime.tryParse(json['created_at'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expense_number': expenseNumber,
      'category': category,
      'description': description,
      'amount': amount,
      'expense_date': expenseDate.toIso8601String().split('T')[0],
      'receipt': receipt,
      'notes': notes,
      'created_by': createdBy,
    };
  }
}
