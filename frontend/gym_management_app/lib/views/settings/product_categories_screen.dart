import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/pos_service.dart';
import '../../models/product_model.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';

class ProductCategoriesScreen extends StatefulWidget {
  const ProductCategoriesScreen({Key? key}) : super(key: key);

  @override
  State<ProductCategoriesScreen> createState() => _ProductCategoriesScreenState();
}

class _ProductCategoriesScreenState extends State<ProductCategoriesScreen> {
  final PosService _posService = PosService();
  bool _isLoading = true;
  List<ProductCategory> _categories = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await _posService.getAllCategories(includeInactive: true);
      if (result['success'] == true) {
        setState(() {
          _categories = result['categories'] ?? [];
        });
      } else {
        Get.snackbar('Error', result['message'] ?? 'Failed to load categories');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load categories');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<ProductCategory> get _filteredCategories {
    if (_searchQuery.isEmpty) return _categories;
    return _categories.where((cat) {
      final name = cat.name.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query);
    }).toList();
  }

  void _showCategoryDialog({ProductCategory? category}) {
    final isEdit = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    final descriptionController = TextEditingController(text: category?.description ?? '');
    bool isActive = category?.isActive ?? true;
    bool isSaving = false;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(isEdit ? 'Edit Category' : 'Add Category'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: nameController,
                    label: 'Category Name',
                    prefixIcon: Icons.category,
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
                  if (isSaving)
                    const Padding(
                      padding: EdgeInsets.only(top: AppSpacing.md),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Get.back(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isSaving ? null : () async {
                  if (nameController.text.trim().isEmpty) {
                    Get.snackbar('Error', 'Please enter category name');
                    return;
                  }
                  
                  setDialogState(() => isSaving = true);
                  
                  try {
                    final categoryData = {
                      'name': nameController.text.trim(),
                      'description': descriptionController.text.trim(),
                      'status': isActive ? 'active' : 'inactive',
                    };
                    
                    Map<String, dynamic> result;
                    if (isEdit && category?.id != null) {
                      result = await _posService.updateCategory(category!.id!, categoryData);
                    } else {
                      result = await _posService.createCategory(categoryData);
                    }
                    
                    if (result['success'] == true) {
                      Get.back();
                      Get.snackbar(
                        'Success',
                        result['message'] ?? (isEdit ? 'Category updated successfully' : 'Category created successfully'),
                        backgroundColor: AppColors.success,
                        colorText: Colors.white,
                      );
                      _loadCategories();
                    } else {
                      Get.snackbar('Error', result['message'] ?? 'Operation failed');
                    }
                  } catch (e) {
                    Get.snackbar('Error', 'Failed to save category');
                  } finally {
                    setDialogState(() => isSaving = false);
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

  void _confirmDelete(ProductCategory category) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Get.back();
              
              try {
                if (category.id != null) {
                  final result = await _posService.deleteCategory(category.id!);
                  if (result['success'] == true) {
                    Get.snackbar(
                      'Success',
                      'Category deleted successfully',
                      backgroundColor: AppColors.success,
                      colorText: Colors.white,
                    );
                    _loadCategories();
                  } else {
                    Get.snackbar('Error', result['message'] ?? 'Failed to delete category');
                  }
                }
              } catch (e) {
                Get.snackbar('Error', 'Failed to delete category');
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCategories,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search categories...',
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
          Expanded(
            child: _isLoading
                ? const LoadingWidget()
                : _filteredCategories.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: 80,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'No categories found',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            ElevatedButton.icon(
                              onPressed: () => _showCategoryDialog(),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Category'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        itemCount: _filteredCategories.length,
                        itemBuilder: (context, index) {
                          final category = _filteredCategories[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppBorderRadius.small),
                                ),
                                child: Icon(
                                  Icons.category,
                                  color: AppColors.primary,
                                ),
                              ),
                              title: Text(
                                category.name,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (category.description != null && category.description!.isNotEmpty)
                                    Text(
                                      category.description!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: category.isActive
                                          ? AppColors.success.withOpacity(0.2)
                                          : AppColors.error.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      category.isActive ? 'Active' : 'Inactive',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: category.isActive
                                            ? AppColors.success
                                            : AppColors.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton(
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: AppColors.error),
                                        const SizedBox(width: 8),
                                        Text('Delete', style: TextStyle(color: AppColors.error)),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showCategoryDialog(category: category);
                                  } else if (value == 'delete') {
                                    _confirmDelete(category);
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
