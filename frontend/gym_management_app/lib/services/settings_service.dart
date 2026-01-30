import 'api_service.dart';

class SettingsService {
  final ApiService _apiService = ApiService();

  /// Get all settings from the server
  Future<Map<String, dynamic>> getSettings() async {
    try {
      final response = await _apiService.get('/master/settings.php');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'settings': response.data['data'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to load settings',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Update settings on the server
  Future<Map<String, dynamic>> updateSettings(Map<String, String> settings) async {
    try {
      final response = await _apiService.post(
        '/master/settings.php',
        data: {'settings': settings},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'settings': response.data['data'],
          'message': response.data['message'] ?? 'Settings updated successfully',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to update settings',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
