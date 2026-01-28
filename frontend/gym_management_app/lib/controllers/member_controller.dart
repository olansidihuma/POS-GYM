import 'package:get/get.dart';
import '../models/member_model.dart';
import '../services/member_service.dart';

class MemberController extends GetxController {
  final MemberService _memberService = MemberService();
  
  final RxList<Member> members = <Member>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt total = 0.obs;
  final RxString searchQuery = ''.obs;
  final Rx<Member?> selectedMember = Rx<Member?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchMembers();
  }

  Future<void> fetchMembers({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      members.clear();
    }

    if (isLoading.value || isLoadingMore.value) return;

    if (currentPage.value == 1) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    try {
      final result = await _memberService.getMembers(
        page: currentPage.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
      );

      if (result['success'] == true) {
        final List<Member> fetchedMembers = result['members'];
        
        if (refresh) {
          members.value = fetchedMembers;
        } else {
          members.addAll(fetchedMembers);
        }
        
        total.value = result['total'] ?? 0;
        totalPages.value = result['totalPages'] ?? 1;
      } else {
        Get.snackbar('Error', result['message']);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMore() async {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      await fetchMembers();
    }
  }

  Future<void> searchMembers(String query) async {
    searchQuery.value = query;
    currentPage.value = 1;
    members.clear();
    await fetchMembers();
  }

  Future<void> getMemberById(int id) async {
    isLoading.value = true;
    try {
      final result = await _memberService.getMemberById(id);
      
      if (result['success'] == true) {
        selectedMember.value = result['member'];
      } else {
        Get.snackbar('Error', result['message']);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createMember(Member member) async {
    isLoading.value = true;
    try {
      final result = await _memberService.createMember(member);
      
      if (result['success'] == true) {
        Get.snackbar('Success', result['message']);
        await fetchMembers(refresh: true);
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

  Future<bool> updateMember(int id, Member member) async {
    isLoading.value = true;
    try {
      final result = await _memberService.updateMember(id, member);
      
      if (result['success'] == true) {
        Get.snackbar('Success', result['message']);
        await fetchMembers(refresh: true);
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

  Future<bool> deleteMember(int id) async {
    isLoading.value = true;
    try {
      final result = await _memberService.deleteMember(id);
      
      if (result['success'] == true) {
        Get.snackbar('Success', result['message']);
        await fetchMembers(refresh: true);
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

  Future<String?> uploadPhoto(int memberId, String filePath) async {
    isLoading.value = true;
    try {
      final result = await _memberService.uploadMemberPhoto(memberId, filePath);
      
      if (result['success'] == true) {
        Get.snackbar('Success', result['message']);
        return result['photo_url'];
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

  void clearSelection() {
    selectedMember.value = null;
  }
}
