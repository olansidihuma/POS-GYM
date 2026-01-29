import '../models/product_model.dart';
import '../models/transaction_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class PosService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int limit = 100,
    String? search,
    int? categoryId,
    bool? isActive,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (categoryId != null) 'category_id': categoryId,
        if (isActive != null) 'is_active': isActive ? 1 : 0,
      };

      final response = await _apiService.get(
        '${AppConstants.productsEndpoint}/list.php',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final List<Product> products;
        
        // Handle both array and single object responses
        if (data is List) {
          products = data.map((json) => Product.fromJson(json as Map<String, dynamic>)).toList();
        } else if (data is Map<String, dynamic>) {
          products = [Product.fromJson(data)];
        } else {
          products = [];
        }

        return {
          'success': true,
          'products': products,
          'total': response.data['total'] ?? products.length,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to load products',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> getProductCategories() async {
    try {
      final response = await _apiService.get(
        '${AppConstants.productsEndpoint}/categories.php',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final List<ProductCategory> categories;
        
        // Handle both array and single object responses
        if (data is List) {
          categories = data.map((json) => ProductCategory.fromJson(json as Map<String, dynamic>)).toList();
        } else if (data is Map<String, dynamic>) {
          categories = [ProductCategory.fromJson(data)];
        } else {
          categories = [];
        }

        return {
          'success': true,
          'categories': categories,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to load categories',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> createTransaction(Transaction transaction) async {
    try {
      final response = await _apiService.post(
        '${AppConstants.transactionsEndpoint}/create.php',
        data: transaction.toJson(),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'transaction': Transaction.fromJson(response.data['data']),
          'message': response.data['message'] ?? 'Transaction created successfully',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to create transaction',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> getTransactions({
    int page = 1,
    int limit = 20,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    int? memberId,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        if (type != null) 'type': type,
        if (startDate != null) 'start_date': startDate.toIso8601String().split('T')[0],
        if (endDate != null) 'end_date': endDate.toIso8601String().split('T')[0],
        if (memberId != null) 'member_id': memberId,
      };

      final response = await _apiService.get(
        '${AppConstants.transactionsEndpoint}/list.php',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final List<Transaction> transactions;
        
        // Handle both array and single object responses
        if (data is List) {
          transactions = data.map((json) => Transaction.fromJson(json as Map<String, dynamic>)).toList();
        } else if (data is Map<String, dynamic>) {
          transactions = [Transaction.fromJson(data)];
        } else {
          transactions = [];
        }

        return {
          'success': true,
          'transactions': transactions,
          'total': response.data['total'] ?? transactions.length,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to load transactions',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> getTransactionById(int id) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.transactionsEndpoint}/detail.php',
        queryParameters: {'id': id},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'transaction': Transaction.fromJson(response.data['data']),
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to load transaction',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> createProduct(Product product) async {
    try {
      final response = await _apiService.post(
        '${AppConstants.productsEndpoint}/create.php',
        data: product.toJson(),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'product': Product.fromJson(response.data['data']),
          'message': response.data['message'] ?? 'Product created successfully',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to create product',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> updateProduct(int id, Product product) async {
    try {
      final response = await _apiService.put(
        '${AppConstants.productsEndpoint}/update.php',
        data: {...product.toJson(), 'id': id},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'product': Product.fromJson(response.data['data']),
          'message': response.data['message'] ?? 'Product updated successfully',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to update product',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> deleteProduct(int id) async {
    try {
      final response = await _apiService.delete(
        '${AppConstants.productsEndpoint}/delete.php',
        queryParameters: {'id': id},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Product deleted successfully',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to delete product',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
