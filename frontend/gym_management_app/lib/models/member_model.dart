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
    return Member(
      id: json['id'],
      memberCode: json['member_code'] ?? '',
      fullName: json['full_name'] ?? '',
      gender: json['gender'] ?? '',
      dateOfBirth: DateTime.parse(json['date_of_birth']),
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      provinsi: json['provinsi'] ?? '',
      kabupaten: json['kabupaten'] ?? '',
      kecamatan: json['kecamatan'] ?? '',
      kelurahan: json['kelurahan'] ?? '',
      emergencyContact: json['emergency_contact'],
      emergencyPhone: json['emergency_phone'],
      photo: json['photo'],
      qrCode: json['qr_code'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      joinDate: json['join_date'] != null 
          ? DateTime.parse(json['join_date']) 
          : null,
      membershipExpiry: json['membership_expiry'] != null 
          ? DateTime.parse(json['membership_expiry']) 
          : null,
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
