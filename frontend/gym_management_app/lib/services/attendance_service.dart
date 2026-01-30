import '../models/attendance_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class AttendanceService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> checkIn({
    required int memberId,
    String method = 'manual',
    String? notes,
  }) async {
    try {
      final response = await _apiService.post(
        '${AppConstants.attendanceEndpoint}/checkin.php',
        data: {
          'attendance_type': 'member',
          'member_id': memberId,
          'check_in_method': method,
          'notes': notes,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'attendance': Attendance.fromJson(response.data['data']),
          'message': response.data['message'] ?? 'Check-in successful',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Check-in failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> checkOut(int attendanceId) async {
    try {
      final response = await _apiService.post(
        '${AppConstants.attendanceEndpoint}/checkout.php',
        data: {'attendance_id': attendanceId},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'attendance': Attendance.fromJson(response.data['data']),
          'message': response.data['message'] ?? 'Check-out successful',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Check-out failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> getAttendances({
    int page = 1,
    int limit = 20,
    DateTime? date,
    int? memberId,
    bool? checkedOut,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        if (date != null) 'date': date.toIso8601String().split('T')[0],
        if (memberId != null) 'member_id': memberId,
        if (checkedOut != null) 'checked_out': checkedOut ? 1 : 0,
      };

      final response = await _apiService.get(
        '${AppConstants.attendanceEndpoint}/list.php',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final List<Attendance> attendances;
        
        // Handle both array and single object responses
        if (data is List) {
          attendances = data.map((json) => Attendance.fromJson(json as Map<String, dynamic>)).toList();
        } else if (data is Map<String, dynamic>) {
          attendances = [Attendance.fromJson(data)];
        } else {
          attendances = [];
        }

        return {
          'success': true,
          'attendances': attendances,
          'total': response.data['total'] ?? attendances.length,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to load attendances',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> getAttendanceStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = {
        if (startDate != null) 'start_date': startDate.toIso8601String().split('T')[0],
        if (endDate != null) 'end_date': endDate.toIso8601String().split('T')[0],
      };

      final response = await _apiService.get(
        '${AppConstants.attendanceEndpoint}/summary.php',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'stats': AttendanceStats.fromJson(response.data['data']),
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to load stats',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> scanQrCode(String qrCode) async {
    try {
      final response = await _apiService.post(
        '${AppConstants.attendanceEndpoint}/scan-qr.php',
        data: {'qr_code': qrCode},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'member': response.data['data']['member'],
          'attendance': response.data['data']['attendance'] != null
              ? Attendance.fromJson(response.data['data']['attendance'])
              : null,
          'message': response.data['message'] ?? 'QR Code scanned successfully',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Invalid QR Code',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
