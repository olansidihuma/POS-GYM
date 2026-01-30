class Membership {
  final int? id;
  final int memberId;
  final String? memberName;
  final int packageId;
  final String? packageName;
  final double amount;
  final int durationMonths;
  final DateTime startDate;
  final DateTime endDate;
  final String paymentMethod;
  final String? paymentReference;
  final String status; // active, expired, cancelled
  final DateTime? createdAt;
  final int? createdBy;
  final String? createdByName;

  Membership({
    this.id,
    required this.memberId,
    this.memberName,
    required this.packageId,
    this.packageName,
    required this.amount,
    required this.durationMonths,
    required this.startDate,
    required this.endDate,
    required this.paymentMethod,
    this.paymentReference,
    this.status = 'active',
    this.createdAt,
    this.createdBy,
    this.createdByName,
  });

  factory Membership.fromJson(Map<String, dynamic> json) {
    return Membership(
      id: json['id'],
      memberId: json['member_id'],
      memberName: json['member_name'],
      packageId: json['package_id'],
      packageName: json['package_name'],
      amount: double.parse(json['amount'].toString()),
      durationMonths: json['duration_months'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      paymentMethod: json['payment_method'] ?? '',
      paymentReference: json['payment_reference'],
      status: json['status'] ?? 'active',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      createdBy: json['created_by'],
      createdByName: json['created_by_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'member_id': memberId,
      'member_name': memberName,
      'package_id': packageId,
      'package_name': packageName,
      'amount': amount,
      'duration_months': durationMonths,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'payment_method': paymentMethod,
      'payment_reference': paymentReference,
      'status': status,
      'created_by': createdBy,
    };
  }

  bool get isActive => status == 'active' && endDate.isAfter(DateTime.now());
  bool get isExpired => endDate.isBefore(DateTime.now());
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;
}

class MembershipPackage {
  final int? id;
  final String name;
  final String description;
  final double price;
  final int? durationMonths;
  final int? durationDays;
  final String? benefits;
  final bool isActive;
  final DateTime? createdAt;

  MembershipPackage({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    this.durationMonths,
    this.durationDays,
    this.benefits,
    this.isActive = true,
    this.createdAt,
  });

  factory MembershipPackage.fromJson(Map<String, dynamic> json) {
    // Support both duration_days and duration_months from API
    int? durationDays = json['duration_days'] != null 
        ? int.tryParse(json['duration_days'].toString()) 
        : null;
    int? durationMonths = json['duration_months'] != null 
        ? int.tryParse(json['duration_months'].toString()) 
        : null;
    
    return MembershipPackage(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.parse(json['price'].toString()),
      durationMonths: durationMonths,
      durationDays: durationDays,
      benefits: json['benefits'],
      isActive: json['is_active'] == 1 || json['is_active'] == true || json['status'] == 'active',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'duration_months': durationMonths,
      'duration_days': durationDays,
      'benefits': benefits,
      'is_active': isActive ? 1 : 0,
    };
  }
  
  /// Get duration in days, preferring durationDays if set
  int get effectiveDurationDays {
    if (durationDays != null && durationDays! > 0) return durationDays!;
    if (durationMonths != null) return durationMonths! * 30;
    return 365; // Default to 1 year
  }
}
