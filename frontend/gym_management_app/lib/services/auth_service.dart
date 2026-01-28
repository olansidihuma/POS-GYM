import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _apiService.post(
        AppConstants.loginEndpoint,
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final token = data['token'];
        final user = User.fromJson(data['user']);

        // Save token and user data
        await saveAuthData(token, user);
        await _apiService.setToken(token);

        return {
          'success': true,
          'token': token,
          'user': user,
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<void> saveAuthData(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.authTokenKey, token);
    await prefs.setString(AppConstants.userDataKey, jsonEncode(user.toJson()));
  }

  Future<Map<String, dynamic>?> getAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.authTokenKey);
    final userDataString = prefs.getString(AppConstants.userDataKey);

    if (token == null || userDataString == null) {
      return null;
    }

    try {
      final userData = jsonDecode(userDataString);
      final user = User.fromJson(userData);
      
      await _apiService.setToken(token);

      return {
        'token': token,
        'user': user,
      };
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.authTokenKey);
    await prefs.remove(AppConstants.userDataKey);
    await _apiService.setToken(null);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(AppConstants.authTokenKey);
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(AppConstants.userDataKey);

    if (userDataString == null) return null;

    try {
      final userData = jsonDecode(userDataString);
      return User.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/change-password.php',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      return {
        'success': response.statusCode == 200 && response.data['success'] == true,
        'message': response.data['message'] ?? 'Password change failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
