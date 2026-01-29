import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../services/pos_service.dart';
import '../../models/product_model.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final PosService _posService = PosService();
  bool _isLoading = true;
  List<Product> _products = [];
  List<ProductCategory> _categories = [];
  String _searchQuery = '';
  int? _selectedCategoryFilter;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final productsResult = await _posService.getProducts();
      final categoriesResult = await _posService.getProductCategories();
      
      setState(() {
        if (productsResult['success'] == true) {
          _products = productsResult['products'] ?? [];
        }
        if (categoriesResult['success'] == true) {
          _categories = categoriesResult['categories'] ?? [];
        }
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to load data');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Product> get _filteredProducts {
    var filtered = _products;
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        final name = product.name.toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query);
      }).toList();
    }
    
    if (_selectedCategoryFilter != null) {
      filtered = filtered.where((product) => 
        product.categoryId == _selectedCategoryFilter
      ).toList();
    }
    
    return filtered;
  }

  void _showProductDialog({Product? product}) {
    final isEdit = product != null;
    final nameController = TextEditingController(text: product?.name ?? '');
    final codeController = TextEditingController(text: product?.code ?? '');
    final priceController = TextEditingController(
      text: product?.price.toString() ?? '',
    );
    final stockController = TextEditingController(
      text: product?.stock.toString() ?? '0',
    );
    final descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    int? selectedCategoryId = product?.categoryId;
    bool isActive = product?.isActive ?? true;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(isEdit ? 'Edit Product' : 'Add Product'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      controller: codeController,
                      label: 'Product Code',
                      prefixIcon: Icons.qr_code,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CustomTextField(
                      controller: nameController,
                      label: 'Product Name',
                      prefixIcon: Icons.inventory,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<int>(
                      value: selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((cat) {
                        return DropdownMenuItem<int>(
                          value: cat.id,
                          child: Text(cat.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedCategoryId = value;
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CustomTextField(
                      controller: priceController,
                      label: 'Price (Rp)',
                      prefixIcon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CustomTextField(
                      controller: stockController,
                      label: 'Stock',
                      prefixIcon: Icons.inventory_2,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CustomTextField(
                      controller: descriptionController,
                      label: 'Description',
                      prefixIcon: Icons.description,
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SwitchListTile(
                      title: const Text('Active'),
                      value: isActive,
                      onChanged: (value) {
                        setDialogState(() {
                          isActive = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty) {
                    Get.snackbar('Error', 'Please enter product name');
                    return;
                  }
                  if (priceController.text.trim().isEmpty) {
                    Get.snackbar('Error', 'Please enter price');
                    return;
                  }
                  if (selectedCategoryId == null) {
                    Get.snackbar('Error', 'Please select a category');
                    return;
                  }
                  
                  Get.back();
                  
                  final newProduct = Product(
                    id: product?.id,
                    code: codeController.text.trim(),
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim(),
                    categoryId: selectedCategoryId!,
                    price: double.tryParse(priceController.text) ?? 0,
                    stock: int.tryParse(stockController.text) ?? 0,
                    isActive: isActive,
                  );
                  
                  Map<String, dynamic> result;
                  if (isEdit && product?.id != null) {
                    result = await _posService.updateProduct(product!.id!, newProduct);
                  } else {
                    result = await _posService.createProduct(newProduct);
                  }
                  
                  if (result['success'] == true) {
                    Get.snackbar(
                      'Success',
                      isEdit ? 'Product updated successfully' : 'Product created successfully',
                      backgroundColor: AppColors.success,
                      colorText: Colors.white,
                    );
                    _loadData();
                  } else {
                    Get.snackbar('Error', result['message'] ?? 'Failed to save product');
                  }
                },
                child: Text(isEdit ? 'Update' : 'Create'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDelete(Product product) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Get.back();
              
              if (product.id != null) {
                final result = await _posService.deleteProduct(product.id!);
                if (result['success'] == true) {
                  Get.snackbar(
                    'Success',
                    'Product deleted successfully',
                    backgroundColor: AppColors.success,
                    colorText: Colors.white,
                  );
                  _loadData();
                } else {
                  Get.snackbar('Error', result['message'] ?? 'Failed to delete product');
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                DropdownButton<int?>(
                  value: _selectedCategoryFilter,
                  hint: const Text('Category'),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('All Categories'),
                    ),
                    ..._categories.map((cat) {
                      return DropdownMenuItem<int?>(
                        value: cat.id,
                        child: Text(cat.name),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedCategoryFilter = value);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const LoadingWidget()
                : _filteredProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 80,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'No products found',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            ElevatedButton.icon(
                              onPressed: () => _showProductDialog(),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Product'),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppSpacing.md,
                          mainAxisSpacing: AppSpacing.md,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () => _showProductDialog(product: product),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      color: AppColors.background,
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: Icon(
                                              Icons.inventory_2,
                                              size: 60,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: product.isActive
                                                    ? AppColors.success
                                                    : AppColors.error,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                product.isActive ? 'Active' : 'Inactive',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(AppSpacing.sm),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            currencyFormat.format(product.price),
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Stock: ${product.stock}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: product.isLowStock
                                                      ? AppColors.error
                                                      : AppColors.textSecondary,
                                                ),
                                              ),
                                              PopupMenuButton(
                                                padding: EdgeInsets.zero,
                                                iconSize: 20,
                                                itemBuilder: (context) => [
                                                  const PopupMenuItem(
                                                    value: 'edit',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.edit, size: 18),
                                                        SizedBox(width: 8),
                                                        Text('Edit'),
                                                      ],
                                                    ),
                                                  ),
                                                  PopupMenuItem(
                                                    value: 'delete',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.delete, size: 18, color: AppColors.error),
                                                        const SizedBox(width: 8),
                                                        Text('Delete', style: TextStyle(color: AppColors.error)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                                onSelected: (value) {
                                                  if (value == 'edit') {
                                                    _showProductDialog(product: product);
                                                  } else if (value == 'delete') {
                                                    _confirmDelete(product);
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
