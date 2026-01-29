import '../models/membership_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class MembershipService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getMembershipPackages() async {
    try {
      final response = await _apiService.get(
        '${AppConstants.membershipEndpoint}/packages.php',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final List<MembershipPackage> packages;
        
        // Handle both array and single object responses
        if (data is List) {
          packages = data.map((json) => MembershipPackage.fromJson(json as Map<String, dynamic>)).toList();
        } else if (data is Map<String, dynamic>) {
          packages = [MembershipPackage.fromJson(data)];
        } else {
          packages = [];
        }

        return {
          'success': true,
          'packages': packages,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to load packages',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> subscribe({
    required int memberId,
    required int packageId,
    required String paymentMethod,
    String? paymentReference,
  }) async {
    try {
      final response = await _apiService.post(
        '${AppConstants.membershipEndpoint}/subscribe.php',
        data: {
          'member_id': memberId,
          'package_id': packageId,
          'payment_method': paymentMethod,
          'payment_reference': paymentReference,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'membership': Membership.fromJson(response.data['data']),
          'message': response.data['message'] ?? 'Subscription successful',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Subscription failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> renewMembership({
    required int memberId,
    required int packageId,
    required String paymentMethod,
    String? paymentReference,
  }) async {
    try {
      final response = await _apiService.post(
        '${AppConstants.membershipEndpoint}/renew.php',
        data: {
          'member_id': memberId,
          'package_id': packageId,
          'payment_method': paymentMethod,
          'payment_reference': paymentReference,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'membership': Membership.fromJson(response.data['data']),
          'message': response.data['message'] ?? 'Membership renewed successfully',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Renewal failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> getMemberMemberships(int memberId) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.membershipEndpoint}/member-history.php',
        queryParameters: {'member_id': memberId},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final List<Membership> memberships;
        
        // Handle both array and single object responses
        if (data is List) {
          memberships = data.map((json) => Membership.fromJson(json as Map<String, dynamic>)).toList();
        } else if (data is Map<String, dynamic>) {
          memberships = [Membership.fromJson(data)];
        } else {
          memberships = [];
        }

        return {
          'success': true,
          'memberships': memberships,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to load membership history',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> getExpiringMemberships({int days = 7}) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.membershipEndpoint}/expiring.php',
        queryParameters: {'days': days},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final List<Membership> memberships;
        
        // Handle both array and single object responses
        if (data is List) {
          memberships = data.map((json) => Membership.fromJson(json as Map<String, dynamic>)).toList();
        } else if (data is Map<String, dynamic>) {
          memberships = [Membership.fromJson(data)];
        } else {
          memberships = [];
        }

        return {
          'success': true,
          'memberships': memberships,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to load expiring memberships',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
