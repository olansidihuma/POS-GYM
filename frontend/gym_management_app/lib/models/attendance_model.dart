class Attendance {
  final int? id;
  final int memberId;
  final String? memberName;
  final String? memberCode;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String? notes;
  final String? checkInMethod; // qr_code, manual, fingerprint
  final int? recordedBy;
  final String? recordedByName;
  final DateTime? createdAt;

  Attendance({
    this.id,
    required this.memberId,
    this.memberName,
    this.memberCode,
    required this.checkInTime,
    this.checkOutTime,
    this.notes,
    this.checkInMethod = 'manual',
    this.recordedBy,
    this.recordedByName,
    this.createdAt,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      memberId: json['member_id'],
      memberName: json['member_name'],
      memberCode: json['member_code'],
      checkInTime: DateTime.parse(json['check_in_time']),
      checkOutTime: json['check_out_time'] != null 
          ? DateTime.parse(json['check_out_time']) 
          : null,
      notes: json['notes'],
      checkInMethod: json['check_in_method'] ?? 'manual',
      recordedBy: json['recorded_by'],
      recordedByName: json['recorded_by_name'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'member_id': memberId,
      'member_name': memberName,
      'member_code': memberCode,
      'check_in_time': checkInTime.toIso8601String(),
      'check_out_time': checkOutTime?.toIso8601String(),
      'notes': notes,
      'check_in_method': checkInMethod,
      'recorded_by': recordedBy,
    };
  }

  Duration? get duration {
    if (checkOutTime == null) return null;
    return checkOutTime!.difference(checkInTime);
  }

  String get durationString {
    if (duration == null) return 'In Progress';
    final hours = duration!.inHours;
    final minutes = duration!.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  bool get isCheckedOut => checkOutTime != null;
}

class AttendanceStats {
  final int totalCheckIns;
  final int todayCheckIns;
  final int monthlyCheckIns;
  final double averageDuration;
  final int activeMembersToday;

  AttendanceStats({
    required this.totalCheckIns,
    required this.todayCheckIns,
    required this.monthlyCheckIns,
    required this.averageDuration,
    required this.activeMembersToday,
  });

  factory AttendanceStats.fromJson(Map<String, dynamic> json) {
    return AttendanceStats(
      totalCheckIns: json['total_check_ins'] ?? 0,
      todayCheckIns: json['today_check_ins'] ?? 0,
      monthlyCheckIns: json['monthly_check_ins'] ?? 0,
      averageDuration: json['average_duration'] != null 
          ? double.parse(json['average_duration'].toString()) 
          : 0,
      activeMembersToday: json['active_members_today'] ?? 0,
    );
  }
}
