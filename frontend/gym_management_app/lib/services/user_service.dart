import 'api_service.dart';
import '../models/user_model.dart';

class UserService {
  final ApiService _apiService = ApiService();

  /// Get all users
  Future<Map<String, dynamic>> getUsers({bool includeInactive = false, String? search}) async {
    try {
      final queryParams = {
        if (includeInactive) 'include_inactive': '1',
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await _apiService.get(
        '/master/users.php',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final List<Map<String, dynamic>> users;
        
        if (data is List) {
          users = data.map((json) => json as Map<String, dynamic>).toList();
        } else {
          users = [];
        }

        return {
          'success': true,
          'users': users,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to load users',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Get user by ID
  Future<Map<String, dynamic>> getUserById(int id) async {
    try {
      final response = await _apiService.get(
        '/master/users.php',
        queryParameters: {'id': id},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'user': response.data['data'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to load user',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Create new user
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await _apiService.post(
        '/master/users.php',
        data: userData,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'user': response.data['data'],
          'message': response.data['message'] ?? 'User created successfully',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to create user',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Update user
  Future<Map<String, dynamic>> updateUser(int id, Map<String, dynamic> userData) async {
    try {
      final response = await _apiService.put(
        '/master/users.php',
        data: {'id': id, ...userData},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'user': response.data['data'],
          'message': response.data['message'] ?? 'User updated successfully',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to update user',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Delete (deactivate) user
  Future<Map<String, dynamic>> deleteUser(int id) async {
    try {
      final response = await _apiService.delete(
        '/master/users.php',
        queryParameters: {'id': id},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'User deleted successfully',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to delete user',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Get all roles
  Future<Map<String, dynamic>> getRoles() async {
    try {
      final response = await _apiService.get('/master/roles.php');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final List<Map<String, dynamic>> roles;
        
        if (data is List) {
          roles = data.map((json) => json as Map<String, dynamic>).toList();
        } else {
          roles = [];
        }

        return {
          'success': true,
          'roles': roles,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to load roles',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
