class User {
  final int id;
  final String username;
  final String email;
  final String role;
  final String? fullName;
  final String? phone;
  final String? avatar;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.fullName,
    this.phone,
    this.avatar,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : (json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0),
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      fullName: json['full_name']?.toString(),
      phone: json['phone']?.toString(),
      avatar: json['avatar']?.toString(),
      isActive: json['is_active'] == 1 || json['is_active'] == true || json['status'] == 'active',
      createdAt: json['created_at'] != null && json['created_at'].toString().isNotEmpty
          ? DateTime.tryParse(json['created_at'].toString()) 
          : null,
      updatedAt: json['updated_at'] != null && json['updated_at'].toString().isNotEmpty
          ? DateTime.tryParse(json['updated_at'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'full_name': fullName,
      'phone': phone,
      'avatar': avatar,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool isAdmin() => role == 'admin';
  bool isOwner() => role == 'owner';
  bool isStaff() => role == 'staff';
  
  bool hasPermission(String permission) {
    // Admin has all permissions
    if (isAdmin()) return true;
    
    // Owner has most permissions except system settings
    if (isOwner()) {
      return !['manage_users', 'system_settings'].contains(permission);
    }
    
    // Staff has limited permissions
    if (isStaff()) {
      return [
        'view_members', 
        'add_member', 
        'record_attendance', 
        'pos_operations',
        'manage_membership',
        'view_reports',
        'view_settings',
      ].contains(permission);
    }
    
    return false;
  }
}
