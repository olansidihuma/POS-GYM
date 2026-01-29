import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Note: checkAuthStatus() is called explicitly from main.dart before runApp()
    // to ensure auth state is fully loaded before the app renders
  }

  Future<void> checkAuthStatus() async {
    isLoading.value = true;
    try {
      final authData = await _authService.getAuthData();
      if (authData != null && authData['user'] != null) {
        currentUser.value = authData['user'];
        isLoggedIn.value = true;
      } else {
        currentUser.value = null;
        isLoggedIn.value = false;
      }
    } catch (e) {
      debugPrint('AuthController.checkAuthStatus error: $e');
      currentUser.value = null;
      isLoggedIn.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    isLoading.value = true;
    try {
      final result = await _authService.login(username, password);
      
      if (result['success'] == true) {
        currentUser.value = result['user'];
        isLoggedIn.value = true;
        Get.offAllNamed(AppRoutes.home);
      }
      
      return result;
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    isLoading.value = true;
    try {
      await _authService.logout();
      currentUser.value = null;
      isLoggedIn.value = false;
      Get.offAllNamed(AppRoutes.login);
    } finally {
      isLoading.value = false;
    }
  }

  bool hasPermission(String permission) {
    return currentUser.value?.hasPermission(permission) ?? false;
  }

  bool get isAdmin => currentUser.value?.isAdmin() ?? false;
  bool get isOwner => currentUser.value?.isOwner() ?? false;
  bool get isStaff => currentUser.value?.isStaff() ?? false;
}
