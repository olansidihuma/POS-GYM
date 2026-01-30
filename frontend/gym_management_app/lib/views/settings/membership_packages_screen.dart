import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';
import '../../services/membership_service.dart';

class MembershipPackagesScreen extends StatefulWidget {
  const MembershipPackagesScreen({Key? key}) : super(key: key);

  @override
  State<MembershipPackagesScreen> createState() => _MembershipPackagesScreenState();
}

class _MembershipPackagesScreenState extends State<MembershipPackagesScreen> {
  final MembershipService _membershipService = MembershipService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _packages = [];

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await _membershipService.getMembershipPackages();
      if (result['success'] == true) {
        final packages = result['packages'] as List;
        setState(() {
          _packages = packages.map((p) => {
            'id': p.id,
            'name': p.name,
            'price': p.price,
            'duration_days': p.effectiveDurationDays,
            'description': p.description ?? '',
            'status': p.isActive ? 'active' : 'inactive',
          }).toList();
        });
      } else {
        Get.snackbar('Error', result['message'] ?? 'Failed to load packages');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load packages');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showPackageDialog({Map<String, dynamic>? package}) {
    final isEdit = package != null;
    final nameController = TextEditingController(text: package?['name'] ?? '');
    final priceController = TextEditingController(
      text: package?['price']?.toString() ?? '',
    );
    final durationController = TextEditingController(
      text: package?['duration_days']?.toString() ?? '365',
    );
    final descriptionController = TextEditingController(
      text: package?['description'] ?? '',
    );
    bool isActive = package?['status'] == 'active';
    bool isSaving = false;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(isEdit ? 'Edit Package' : 'Add Package'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: nameController,
                    label: 'Package Name',
                    prefixIcon: Icons.card_membership,
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
                    controller: durationController,
                    label: 'Duration (days)',
                    prefixIcon: Icons.calendar_today,
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
                    Get.snackbar('Error', 'Please enter package name');
                    return;
                  }
                  if (priceController.text.trim().isEmpty) {
                    Get.snackbar('Error', 'Please enter price');
                    return;
                  }
                  
                  setDialogState(() => isSaving = true);
                  
                  try {
                    final packageData = {
                      'name': nameController.text.trim(),
                      'price': double.tryParse(priceController.text) ?? 0,
                      'duration_days': int.tryParse(durationController.text) ?? 365,
                      'description': descriptionController.text.trim(),
                      'status': isActive ? 'active' : 'inactive',
                    };
                    
                    Map<String, dynamic> result;
                    if (isEdit && package?['id'] != null) {
                      result = await _membershipService.updatePackage(package!['id'], packageData);
                    } else {
                      result = await _membershipService.createPackage(packageData);
                    }
                    
                    if (result['success'] == true) {
                      Get.back();
                      Get.snackbar(
                        'Success',
                        result['message'] ?? (isEdit ? 'Package updated successfully' : 'Package created successfully'),
                        backgroundColor: AppColors.success,
                        colorText: Colors.white,
                      );
                      _loadPackages();
                    } else {
                      Get.snackbar('Error', result['message'] ?? 'Operation failed');
                    }
                  } catch (e) {
                    Get.snackbar('Error', 'Failed to save package');
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

  void _confirmDelete(Map<String, dynamic> package) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${package['name']}"?'),
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
                final result = await _membershipService.deletePackage(package['id']);
                if (result['success'] == true) {
                  Get.snackbar(
                    'Success',
                    'Package deleted successfully',
                    backgroundColor: AppColors.success,
                    colorText: Colors.white,
                  );
                  _loadPackages();
                } else {
                  Get.snackbar('Error', result['message'] ?? 'Failed to delete package');
                }
              } catch (e) {
                Get.snackbar('Error', 'Failed to delete package');
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
        title: const Text('Membership Packages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPackages,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _packages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.card_membership_outlined,
                        size: 80,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'No packages found',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ElevatedButton.icon(
                        onPressed: () => _showPackageDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Package'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: _packages.length,
                  itemBuilder: (context, index) {
                    final package = _packages[index];
                    final isActive = package['status'] == 'active';
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        package['name'] ?? '-',
                                        style: AppTextStyles.heading3,
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.sm,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? AppColors.success.withOpacity(0.2)
                                              : AppColors.error.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          isActive ? 'Active' : 'Inactive',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: isActive
                                                ? AppColors.success
                                                : AppColors.error,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton(
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
                                      _showPackageDialog(package: package);
                                    } else if (value == 'delete') {
                                      _confirmDelete(package);
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(AppSpacing.md),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(AppBorderRadius.small),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(Icons.attach_money, color: AppColors.primary),
                                        const SizedBox(height: 4),
                                        Text(
                                          currencyFormat.format(package['price'] ?? 0),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        Text(
                                          'Price',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(AppSpacing.md),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(AppBorderRadius.small),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(Icons.calendar_today, color: AppColors.secondary),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${package['duration_days'] ?? 0} days',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.secondary,
                                          ),
                                        ),
                                        Text(
                                          'Duration',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (package['description'] != null && 
                                package['description'].toString().isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                package['description'],
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPackageDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
