import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';
import '../../services/user_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final UserService _userService = UserService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _roles = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load users and roles in parallel
      final results = await Future.wait([
        _userService.getUsers(includeInactive: true),
        _userService.getRoles(),
      ]);
      
      final usersResult = results[0];
      final rolesResult = results[1];
      
      setState(() {
        if (usersResult['success'] == true) {
          _users = (usersResult['users'] as List).map((u) => {
            'id': u['id'],
            'username': u['username'],
            'full_name': u['full_name'],
            'email': u['email'],
            'phone': u['phone'],
            'role': u['role_name'],
            'role_id': u['role_id'],
            'status': u['status'],
          }).toList();
        }
        if (rolesResult['success'] == true) {
          _roles = (rolesResult['roles'] as List).map((r) => {
            'id': r['id'],
            'name': r['name'],
          }).toList();
        }
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to load data');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;
    return _users.where((user) {
      final name = user['full_name']?.toString().toLowerCase() ?? '';
      final username = user['username']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || username.contains(query);
    }).toList();
  }

  void _showUserDialog({Map<String, dynamic>? user}) {
    final isEdit = user != null;
    final usernameController = TextEditingController(text: user?['username'] ?? '');
    final fullNameController = TextEditingController(text: user?['full_name'] ?? '');
    final emailController = TextEditingController(text: user?['email'] ?? '');
    final phoneController = TextEditingController(text: user?['phone'] ?? '');
    final passwordController = TextEditingController();
    int? selectedRoleId = user?['role_id'];
    bool isSaving = false;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(isEdit ? 'Edit User' : 'Add User'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: usernameController,
                    label: 'Username',
                    prefixIcon: Icons.person,
                    enabled: !isEdit,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  CustomTextField(
                    controller: fullNameController,
                    label: 'Full Name',
                    prefixIcon: Icons.badge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  CustomTextField(
                    controller: emailController,
                    label: 'Email',
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  CustomTextField(
                    controller: phoneController,
                    label: 'Phone',
                    prefixIcon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (!isEdit)
                    CustomTextField(
                      controller: passwordController,
                      label: 'Password',
                      prefixIcon: Icons.lock,
                      obscureText: true,
                    ),
                  if (!isEdit) const SizedBox(height: AppSpacing.md),
                  if (isEdit) ...[
                    CustomTextField(
                      controller: passwordController,
                      label: 'New Password (leave blank to keep)',
                      prefixIcon: Icons.lock,
                      obscureText: true,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  DropdownButtonFormField<int>(
                    value: selectedRoleId,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      prefixIcon: Icon(Icons.admin_panel_settings),
                      border: OutlineInputBorder(),
                    ),
                    items: _roles.map((role) {
                      return DropdownMenuItem<int>(
                        value: role['id'],
                        child: Text(role['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedRoleId = value;
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
                  if (fullNameController.text.trim().isEmpty) {
                    Get.snackbar('Error', 'Please enter full name');
                    return;
                  }
                  if (!isEdit && usernameController.text.trim().isEmpty) {
                    Get.snackbar('Error', 'Please enter username');
                    return;
                  }
                  if (!isEdit && passwordController.text.isEmpty) {
                    Get.snackbar('Error', 'Please enter password');
                    return;
                  }
                  if (selectedRoleId == null) {
                    Get.snackbar('Error', 'Please select a role');
                    return;
                  }
                  
                  setDialogState(() => isSaving = true);
                  
                  try {
                    final userData = <String, dynamic>{
                      'full_name': fullNameController.text.trim(),
                      'email': emailController.text.trim(),
                      'phone': phoneController.text.trim(),
                      'role_id': selectedRoleId,
                    };
                    
                    if (!isEdit) {
                      userData['username'] = usernameController.text.trim();
                      userData['password'] = passwordController.text;
                    } else if (passwordController.text.isNotEmpty) {
                      userData['password'] = passwordController.text;
                    }
                    
                    Map<String, dynamic> result;
                    if (isEdit && user?['id'] != null) {
                      result = await _userService.updateUser(user!['id'], userData);
                    } else {
                      result = await _userService.createUser(userData);
                    }
                    
                    if (result['success'] == true) {
                      Get.back();
                      Get.snackbar(
                        'Success',
                        result['message'] ?? (isEdit ? 'User updated successfully' : 'User created successfully'),
                        backgroundColor: AppColors.success,
                        colorText: Colors.white,
                      );
                      _loadData();
                    } else {
                      Get.snackbar('Error', result['message'] ?? 'Operation failed');
                    }
                  } catch (e) {
                    Get.snackbar('Error', 'Failed to save user');
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

  void _confirmDelete(Map<String, dynamic> user) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to deactivate ${user['full_name']}?'),
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
                final result = await _userService.deleteUser(user['id']);
                if (result['success'] == true) {
                  Get.snackbar(
                    'Success',
                    'User deactivated successfully',
                    backgroundColor: AppColors.success,
                    colorText: Colors.white,
                  );
                  _loadData();
                } else {
                  Get.snackbar('Error', result['message'] ?? 'Failed to delete user');
                }
              } catch (e) {
                Get.snackbar('Error', 'Failed to delete user');
              }
            },
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showUserDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search users...',
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
                : _filteredUsers.isEmpty
                    ? const Center(child: Text('No users found'))
                    : ListView.builder(
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  (user['full_name'] ?? 'U')[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(user['full_name'] ?? '-'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('@${user['username']}'),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.sm,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: user['role'] == 'Admin'
                                              ? AppColors.warning.withOpacity(0.2)
                                              : AppColors.info.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          user['role'] ?? '-',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: user['role'] == 'Admin'
                                                ? AppColors.warning
                                                : AppColors.info,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.sm,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: user['status'] == 'active'
                                              ? AppColors.success.withOpacity(0.2)
                                              : AppColors.error.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          user['status'] ?? '-',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: user['status'] == 'active'
                                                ? AppColors.success
                                                : AppColors.error,
                                          ),
                                        ),
                                      ),
                                    ],
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
                                    _showUserDialog(user: user);
                                  } else if (value == 'delete') {
                                    _confirmDelete(user);
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
        onPressed: () => _showUserDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
