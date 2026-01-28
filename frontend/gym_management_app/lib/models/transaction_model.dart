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
    return Transaction(
      id: json['id'],
      transactionNumber: json['transaction_number'] ?? '',
      type: json['type'] ?? '',
      transactionDate: DateTime.parse(json['transaction_date']),
      memberId: json['member_id'],
      memberName: json['member_name'],
      subtotal: double.parse(json['subtotal'].toString()),
      discount: json['discount'] != null 
          ? double.parse(json['discount'].toString()) 
          : 0,
      tax: json['tax'] != null ? double.parse(json['tax'].toString()) : 0,
      total: double.parse(json['total'].toString()),
      paymentMethod: json['payment_method'] ?? '',
      paidAmount: double.parse(json['paid_amount'].toString()),
      changeAmount: json['change_amount'] != null 
          ? double.parse(json['change_amount'].toString()) 
          : 0,
      notes: json['notes'],
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => TransactionItem.fromJson(item))
              .toList()
          : null,
      createdBy: json['created_by'],
      createdByName: json['created_by_name'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
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
      id: json['id'],
      transactionId: json['transaction_id'],
      productId: json['product_id'],
      productName: json['product_name'] ?? '',
      price: double.parse(json['price'].toString()),
      quantity: json['quantity'],
      subtotal: double.parse(json['subtotal'].toString()),
      discount: json['discount'] != null 
          ? double.parse(json['discount'].toString()) 
          : 0,
      total: double.parse(json['total'].toString()),
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
    return Expense(
      id: json['id'],
      expenseNumber: json['expense_number'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      amount: double.parse(json['amount'].toString()),
      expenseDate: DateTime.parse(json['expense_date']),
      receipt: json['receipt'],
      notes: json['notes'],
      createdBy: json['created_by'],
      createdByName: json['created_by_name'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
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
