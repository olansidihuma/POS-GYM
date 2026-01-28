import 'package:get/get.dart';
import '../models/membership_model.dart';
import '../services/membership_service.dart';

class MembershipController extends GetxController {
  final MembershipService _membershipService = MembershipService();
  
  final RxList<MembershipPackage> packages = <MembershipPackage>[].obs;
  final RxList<Membership> expiringMemberships = <Membership>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<MembershipPackage?> selectedPackage = Rx<MembershipPackage?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchPackages();
    fetchExpiringMemberships();
  }

  Future<void> fetchPackages() async {
    isLoading.value = true;
    try {
      final result = await _membershipService.getMembershipPackages();

      if (result['success'] == true) {
        packages.value = result['packages'];
      } else {
        Get.snackbar('Error', result['message']);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchExpiringMemberships({int days = 7}) async {
    try {
      final result = await _membershipService.getExpiringMemberships(days: days);

      if (result['success'] == true) {
        expiringMemberships.value = result['memberships'];
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<bool> subscribe({
    required int memberId,
    required int packageId,
    required String paymentMethod,
    String? paymentReference,
  }) async {
    isLoading.value = true;
    try {
      final result = await _membershipService.subscribe(
        memberId: memberId,
        packageId: packageId,
        paymentMethod: paymentMethod,
        paymentReference: paymentReference,
      );

      if (result['success'] == true) {
        Get.snackbar('Success', result['message']);
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

  Future<bool> renewMembership({
    required int memberId,
    required int packageId,
    required String paymentMethod,
    String? paymentReference,
  }) async {
    isLoading.value = true;
    try {
      final result = await _membershipService.renewMembership(
        memberId: memberId,
        packageId: packageId,
        paymentMethod: paymentMethod,
        paymentReference: paymentReference,
      );

      if (result['success'] == true) {
        Get.snackbar('Success', result['message']);
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

  Future<List<Membership>> getMemberHistory(int memberId) async {
    isLoading.value = true;
    try {
      final result = await _membershipService.getMemberMemberships(memberId);

      if (result['success'] == true) {
        return result['memberships'];
      } else {
        Get.snackbar('Error', result['message']);
        return [];
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  void selectPackage(MembershipPackage package) {
    selectedPackage.value = package;
  }

  void clearSelection() {
    selectedPackage.value = null;
  }

  DateTime calculateEndDate(DateTime startDate, int durationMonths) {
    return DateTime(
      startDate.year,
      startDate.month + durationMonths,
      startDate.day,
    );
  }
}
