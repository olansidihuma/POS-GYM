import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';
import 'profile_screen.dart';
import 'user_management_screen.dart';
import 'product_categories_screen.dart';
import 'membership_packages_screen.dart';
import 'printer_settings_screen.dart';
import 'products_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            subtitle: Obx(() => Text(authController.currentUser.value?.email ?? '')),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Get.to(() => const ProfileScreen());
            },
          ),
          const Divider(),
          
          if (authController.isAdmin) ...[
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('User Management'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Get.to(() => const UserManagementScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2),
              title: const Text('Products'),
              subtitle: const Text('Manage products'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Get.to(() => const ProductsScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Product Categories'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Get.to(() => const ProductCategoriesScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.card_membership),
              title: const Text('Membership Packages'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Get.to(() => const MembershipPackagesScreen());
              },
            ),
            const Divider(),
          ],
          
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showChangePasswordDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.print),
            title: const Text('Printer Settings'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Get.to(() => const PrinterSettingsScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup & Restore'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Get.snackbar('Info', 'Backup settings coming soon');
            },
          ),
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Get.defaultDialog(
                title: 'About',
                middleText: 'Gym Management System v1.0.0\n\n'
                    'A complete solution for managing gym operations including '
                    'members, attendance, POS, and reports.',
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: AppColors.error),
            title: Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () {
              Get.defaultDialog(
                title: 'Confirm Logout',
                middleText: 'Are you sure you want to logout?',
                textConfirm: 'Logout',
                textCancel: 'Cancel',
                confirmTextColor: Colors.white,
                buttonColor: AppColors.error,
                onConfirm: () {
                  authController.logout();
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final AuthService authService = AuthService();
    bool isLoading = false;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Change Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                ),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: AppSpacing.md),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Get.back(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  if (currentPasswordController.text.isEmpty) {
                    Get.snackbar('Error', 'Please enter current password');
                    return;
                  }
                  if (newPasswordController.text.isEmpty) {
                    Get.snackbar('Error', 'Please enter new password');
                    return;
                  }
                  if (newPasswordController.text != confirmPasswordController.text) {
                    Get.snackbar('Error', 'Passwords do not match');
                    return;
                  }
                  if (newPasswordController.text.length < 6) {
                    Get.snackbar('Error', 'Password must be at least 6 characters');
                    return;
                  }
                  
                  setDialogState(() => isLoading = true);
                  
                  // Simulate API call - In production, call the actual API
                  await Future.delayed(const Duration(seconds: 1));
                  
                  setDialogState(() => isLoading = false);
                  
                  Get.back();
                  Get.snackbar(
                    'Success',
                    'Password changed successfully',
                    backgroundColor: AppColors.success,
                    colorText: Colors.white,
                  );
                },
                child: const Text('Change'),
              ),
            ],
          );
        },
      ),
    );
  }
}
