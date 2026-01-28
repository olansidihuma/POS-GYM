import 'package:get/get.dart';
import '../models/attendance_model.dart';
import '../services/attendance_service.dart';

class AttendanceController extends GetxController {
  final AttendanceService _attendanceService = AttendanceService();
  
  final RxList<Attendance> attendances = <Attendance>[].obs;
  final Rx<AttendanceStats?> stats = Rx<AttendanceStats?>(null);
  final RxBool isLoading = false.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    fetchAttendances();
    fetchStats();
  }

  Future<void> fetchAttendances({DateTime? date}) async {
    isLoading.value = true;
    try {
      final result = await _attendanceService.getAttendances(
        date: date ?? selectedDate.value,
        limit: 100,
      );

      if (result['success'] == true) {
        attendances.value = result['attendances'];
      } else {
        Get.snackbar('Error', result['message']);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchStats() async {
    try {
      final result = await _attendanceService.getAttendanceStats();

      if (result['success'] == true) {
        stats.value = result['stats'];
      }
    } catch (e) {
      // Silent fail for stats
    }
  }

  Future<bool> checkIn({
    required int memberId,
    String method = 'manual',
    String? notes,
  }) async {
    isLoading.value = true;
    try {
      final result = await _attendanceService.checkIn(
        memberId: memberId,
        method: method,
        notes: notes,
      );

      if (result['success'] == true) {
        Get.snackbar('Success', result['message']);
        await fetchAttendances();
        await fetchStats();
        return true;
      } else {
        Get.snackbar('Error', result['message']);
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> checkOut(int attendanceId) async {
    isLoading.value = true;
    try {
      final result = await _attendanceService.checkOut(attendanceId);

      if (result['success'] == true) {
        Get.snackbar('Success', result['message']);
        await fetchAttendances();
        return true;
      } else {
        Get.snackbar('Error', result['message']);
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> scanQrCode(String qrCode) async {
    isLoading.value = true;
    try {
      final result = await _attendanceService.scanQrCode(qrCode);

      if (result['success'] == true) {
        Get.snackbar('Success', result['message']);
        await fetchAttendances();
        await fetchStats();
        return result;
      } else {
        Get.snackbar('Error', result['message']);
        return null;
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  void changeDate(DateTime date) {
    selectedDate.value = date;
    fetchAttendances(date: date);
  }

  List<Attendance> get todayAttendances {
    final today = DateTime.now();
    return attendances.where((attendance) {
      final checkInDate = attendance.checkInTime;
      return checkInDate.year == today.year &&
          checkInDate.month == today.month &&
          checkInDate.day == today.day;
    }).toList();
  }

  List<Attendance> get activeAttendances {
    return attendances.where((attendance) => !attendance.isCheckedOut).toList();
  }
}
