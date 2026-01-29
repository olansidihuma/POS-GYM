import '../models/member_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class MemberService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getMembers({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isActive,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (isActive != null) 'is_active': isActive ? 1 : 0,
        if (sortBy != null) 'sort_by': sortBy,
        if (sortOrder != null) 'sort_order': sortOrder,
      };

      final response = await _apiService.get(
        '${AppConstants.membersEndpoint}/list.php',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final List<Member> members;
        
        // Handle both array and single object responses
        if (data is List) {
          members = data.map((json) => Member.fromJson(json as Map<String, dynamic>)).toList();
        } else if (data is Map<String, dynamic>) {
          members = [Member.fromJson(data)];
        } else {
          members = [];
        }

        return {
          'success': true,
          'members': members,
          'total': response.data['total'] ?? members.length,
          'page': page,
          'totalPages': response.data['total_pages'] ?? 1,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to load members',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> getMemberById(int id) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.membersEndpoint}/detail.php',
        queryParameters: {'id': id},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'member': Member.fromJson(response.data['data']),
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to load member',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> createMember(Member member) async {
    try {
      final response = await _apiService.post(
        '${AppConstants.membersEndpoint}/create.php',
        data: member.toJson(),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'member': Member.fromJson(response.data['data']),
          'message': response.data['message'] ?? 'Member created successfully',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to create member',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> updateMember(int id, Member member) async {
    try {
      final response = await _apiService.put(
        '${AppConstants.membersEndpoint}/update.php',
        data: {...member.toJson(), 'id': id},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'member': Member.fromJson(response.data['data']),
          'message': response.data['message'] ?? 'Member updated successfully',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to update member',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> deleteMember(int id) async {
    try {
      final response = await _apiService.delete(
        '${AppConstants.membersEndpoint}/delete.php',
        queryParameters: {'id': id},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Member deleted successfully',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to delete member',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> uploadMemberPhoto(int memberId, String filePath) async {
    try {
      final response = await _apiService.uploadFile(
        '${AppConstants.membersEndpoint}/upload-photo.php',
        filePath,
        data: {'member_id': memberId},
        fieldName: 'photo',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'photo_url': response.data['data']['photo_url'],
          'message': response.data['message'] ?? 'Photo uploaded successfully',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to upload photo',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> getKabupaten(String provinsiId) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.masterDataEndpoint}/kabupaten.php',
        queryParameters: {'provinsi_id': provinsiId},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      }

      return {'success': false, 'data': []};
    } catch (e) {
      return {'success': false, 'data': []};
    }
  }

  Future<Map<String, dynamic>> getKecamatan(String kabupatenId) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.masterDataEndpoint}/kecamatan.php',
        queryParameters: {'kabupaten_id': kabupatenId},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      }

      return {'success': false, 'data': []};
    } catch (e) {
      return {'success': false, 'data': []};
    }
  }

  Future<Map<String, dynamic>> getKelurahan(String kecamatanId) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.masterDataEndpoint}/kelurahan.php',
        queryParameters: {'kecamatan_id': kecamatanId},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      }

      return {'success': false, 'data': []};
    } catch (e) {
      return {'success': false, 'data': []};
    }
  }
}
