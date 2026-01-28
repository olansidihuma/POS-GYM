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
      id: json['id'],
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      price: double.parse(json['price'].toString()),
      cost: json['cost'] != null ? double.parse(json['cost'].toString()) : 0,
      stock: json['stock'] ?? 0,
      minStock: json['min_stock'] ?? 0,
      unit: json['unit'],
      barcode: json['barcode'],
      image: json['image'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
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
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
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
