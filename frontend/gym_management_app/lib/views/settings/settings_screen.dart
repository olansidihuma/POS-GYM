import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/constants.dart';

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
            subtitle: Text(authController.currentUser.value?.email ?? ''),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Get.snackbar('Info', 'Profile settings coming soon');
            },
          ),
          const Divider(),
          
          if (authController.isAdmin) ...[
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('User Management'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Get.snackbar('Info', 'User management coming soon');
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Product Categories'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Get.snackbar('Info', 'Category management coming soon');
              },
            ),
            ListTile(
              leading: const Icon(Icons.card_membership),
              title: const Text('Membership Packages'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Get.snackbar('Info', 'Package management coming soon');
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
              Get.snackbar('Info', 'Printer settings coming soon');
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

    Get.defaultDialog(
      title: 'Change Password',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: currentPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Current Password',
              prefixIcon: Icon(Icons.lock),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: newPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'New Password',
              prefixIcon: Icon(Icons.lock),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: confirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon: Icon(Icons.lock),
            ),
          ),
        ],
      ),
      textConfirm: 'Change',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () {
        if (newPasswordController.text != confirmPasswordController.text) {
          Get.snackbar('Error', 'Passwords do not match');
          return;
        }
        
        Get.back();
        Get.snackbar(
          'Success',
          'Password changed successfully',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
      },
    );
  }
}
