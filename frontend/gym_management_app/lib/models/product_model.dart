class Product {
  final int? id;
  final String code;
  final String name;
  final String? description;
  final int categoryId;
  final String? categoryName;
  final double price;
  final double cost;
  final int stock;
  final int minStock;
  final String? unit;
  final String? barcode;
  final String? image;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    this.id,
    required this.code,
    required this.name,
    this.description,
    required this.categoryId,
    this.categoryName,
    required this.price,
    this.cost = 0,
    this.stock = 0,
    this.minStock = 0,
    this.unit,
    this.barcode,
    this.image,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] is int ? json['id'] : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      categoryId: json['category_id'] is int ? json['category_id'] : (json['category_id'] != null ? int.tryParse(json['category_id'].toString()) ?? 0 : 0),
      categoryName: json['category_name']?.toString(),
      price: json['price'] != null ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0,
      cost: json['cost'] != null ? double.tryParse(json['cost'].toString()) ?? 0.0 : 0.0,
      stock: json['stock'] is int ? json['stock'] : (json['stock'] != null ? int.tryParse(json['stock'].toString()) ?? 0 : 0),
      minStock: json['min_stock'] is int ? json['min_stock'] : (json['min_stock'] != null ? int.tryParse(json['min_stock'].toString()) ?? 0 : 0),
      unit: json['unit']?.toString(),
      barcode: json['barcode']?.toString(),
      image: json['image']?.toString(),
      isActive: json['is_active'] == 1 || json['is_active'] == true || json['status'] == 'active',
      createdAt: json['created_at'] != null && json['created_at'].toString().isNotEmpty
          ? DateTime.tryParse(json['created_at'].toString()) 
          : null,
      updatedAt: json['updated_at'] != null && json['updated_at'].toString().isNotEmpty
          ? DateTime.tryParse(json['updated_at'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'category_id': categoryId,
      'category_name': categoryName,
      'price': price,
      'cost': cost,
      'stock': stock,
      'min_stock': minStock,
      'unit': unit,
      'barcode': barcode,
      'image': image,
      'is_active': isActive ? 1 : 0,
    };
  }

  bool get isLowStock => stock <= minStock;
  bool get isOutOfStock => stock <= 0;
  double get profit => price - cost;
  double get profitMargin => cost > 0 ? ((price - cost) / cost * 100) : 0;
}

class ProductCategory {
  final int? id;
  final String name;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;

  ProductCategory({
    this.id,
    required this.name,
    this.description,
    this.isActive = true,
    this.createdAt,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] is int ? json['id'] : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      isActive: json['is_active'] == 1 || json['is_active'] == true || json['status'] == 'active',
      createdAt: json['created_at'] != null && json['created_at'].toString().isNotEmpty
          ? DateTime.tryParse(json['created_at'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'is_active': isActive ? 1 : 0,
    };
  }
}
