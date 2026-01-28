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
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      fullName: json['full_name'],
      phone: json['phone'],
      avatar: json['avatar'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
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
      return ['view_members', 'add_member', 'record_attendance', 'pos_operations']
          .contains(permission);
    }
    
    return false;
  }
}
