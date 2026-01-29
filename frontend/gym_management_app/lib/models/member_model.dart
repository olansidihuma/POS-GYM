class Member {
  final int? id;
  final String memberCode;
  final String fullName;
  final String gender;
  final DateTime dateOfBirth;
  final String email;
  final String phone;
  final String address;
  final String provinsi;
  final String kabupaten;
  final String kecamatan;
  final String kelurahan;
  final String? emergencyContact;
  final String? emergencyPhone;
  final String? photo;
  final String? qrCode;
  final bool isActive;
  final DateTime? joinDate;
  final DateTime? membershipExpiry;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Member({
    this.id,
    required this.memberCode,
    required this.fullName,
    required this.gender,
    required this.dateOfBirth,
    required this.email,
    required this.phone,
    required this.address,
    required this.provinsi,
    required this.kabupaten,
    required this.kecamatan,
    required this.kelurahan,
    this.emergencyContact,
    this.emergencyPhone,
    this.photo,
    this.qrCode,
    this.isActive = true,
    this.joinDate,
    this.membershipExpiry,
    this.createdAt,
    this.updatedAt,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDateOfBirth;
    try {
      if (json['date_of_birth'] != null && json['date_of_birth'].toString().isNotEmpty) {
        parsedDateOfBirth = DateTime.parse(json['date_of_birth'].toString());
      }
    } catch (_) {
      parsedDateOfBirth = null;
    }
    
    return Member(
      id: json['id'] is int ? json['id'] : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      memberCode: json['member_code']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      gender: json['gender']?.toString() ?? 'Male',
      dateOfBirth: parsedDateOfBirth ?? DateTime.now().subtract(const Duration(days: 6570)),
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      provinsi: json['provinsi']?.toString() ?? '',
      kabupaten: json['kabupaten']?.toString() ?? '',
      kecamatan: json['kecamatan']?.toString() ?? '',
      kelurahan: json['kelurahan']?.toString() ?? '',
      emergencyContact: json['emergency_contact']?.toString(),
      emergencyPhone: json['emergency_phone']?.toString(),
      photo: json['photo']?.toString(),
      qrCode: json['qr_code']?.toString(),
      isActive: json['is_active'] == 1 || json['is_active'] == true || json['is_active'] == 'active',
      joinDate: json['join_date'] != null && json['join_date'].toString().isNotEmpty
          ? DateTime.tryParse(json['join_date'].toString()) 
          : null,
      membershipExpiry: json['membership_expiry'] != null && json['membership_expiry'].toString().isNotEmpty
          ? DateTime.tryParse(json['membership_expiry'].toString()) 
          : null,
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
      'member_code': memberCode,
      'full_name': fullName,
      'gender': gender,
      'date_of_birth': dateOfBirth.toIso8601String().split('T')[0],
      'email': email,
      'phone': phone,
      'address': address,
      'provinsi': provinsi,
      'kabupaten': kabupaten,
      'kecamatan': kecamatan,
      'kelurahan': kelurahan,
      'emergency_contact': emergencyContact,
      'emergency_phone': emergencyPhone,
      'photo': photo,
      'qr_code': qrCode,
      'is_active': isActive ? 1 : 0,
      'join_date': joinDate?.toIso8601String().split('T')[0],
      'membership_expiry': membershipExpiry?.toIso8601String().split('T')[0],
    };
  }

  bool get isMembershipActive {
    if (membershipExpiry == null) return false;
    return membershipExpiry!.isAfter(DateTime.now());
  }

  int get daysUntilExpiry {
    if (membershipExpiry == null) return 0;
    return membershipExpiry!.difference(DateTime.now()).inDays;
  }

  bool get isExpiringSoon {
    return isMembershipActive && daysUntilExpiry <= 7;
  }
}
