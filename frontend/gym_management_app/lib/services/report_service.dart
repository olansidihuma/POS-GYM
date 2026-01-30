import 'api_service.dart';

class ReportService {
  final ApiService _apiService = ApiService();

  /// Get report data for export
  Future<Map<String, dynamic>> getReportData({
    required String reportType,
    required String dateFrom,
    required String dateTo,
  }) async {
    try {
      final response = await _apiService.get(
        '/reports/export.php',
        queryParameters: {
          'report_type': reportType,
          'date_from': dateFrom,
          'date_to': dateTo,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to load report data',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Get profit/loss report
  Future<Map<String, dynamic>> getProfitLossReport({
    required String dateFrom,
    required String dateTo,
  }) async {
    try {
      final response = await _apiService.get(
        '/reports/profit_loss.php',
        queryParameters: {
          'date_from': dateFrom,
          'date_to': dateTo,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to load report',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
