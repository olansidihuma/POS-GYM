import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';

class MembershipPackagesScreen extends StatefulWidget {
  const MembershipPackagesScreen({Key? key}) : super(key: key);

  @override
  State<MembershipPackagesScreen> createState() => _MembershipPackagesScreenState();
}

class _MembershipPackagesScreenState extends State<MembershipPackagesScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _packages = [];

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    setState(() => _isLoading = true);
    
    // Simulate API call - In production, fetch from actual API
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _packages = [
        {
          'id': 1,
          'name': 'New Member',
          'price': 45000.0,
          'duration_days': 365,
          'description': 'Membership for new members - 1 year',
          'status': 'active',
        },
        {
          'id': 2,
          'name': 'Renewal',
          'price': 35000.0,
          'duration_days': 365,
          'description': 'Membership renewal - 1 year',
          'status': 'active',
        },
        {
          'id': 3,
          'name': 'Monthly',
          'price': 50000.0,
          'duration_days': 30,
          'description': 'Monthly membership package',
          'status': 'inactive',
        },
      ];
      _isLoading = false;
    });
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
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty) {
                    Get.snackbar('Error', 'Please enter package name');
                    return;
                  }
                  if (priceController.text.trim().isEmpty) {
                    Get.snackbar('Error', 'Please enter price');
                    return;
                  }
                  Get.back();
                  Get.snackbar(
                    'Success',
                    isEdit ? 'Package updated successfully' : 'Package created successfully',
                    backgroundColor: AppColors.success,
                    colorText: Colors.white,
                  );
                  _loadPackages();
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
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Success',
                'Package deleted successfully',
                backgroundColor: AppColors.success,
                colorText: Colors.white,
              );
              _loadPackages();
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
