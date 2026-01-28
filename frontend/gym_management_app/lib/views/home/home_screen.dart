import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/attendance_controller.dart';
import '../../routes/app_routes.dart';
import '../../utils/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final attendanceController = Get.put(AttendanceController());
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym Management System'),
        actions: [
          Obx(() {
            final user = authController.currentUser.value;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        user?.fullName ?? user?.username ?? '',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        user?.role.toUpperCase() ?? '',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  PopupMenuButton(
                    icon: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: AppColors.primary),
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'settings',
                        child: Row(
                          children: [
                            Icon(Icons.settings),
                            SizedBox(width: 8),
                            Text('Settings'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout),
                            SizedBox(width: 8),
                            Text('Logout'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'logout') {
                        authController.logout();
                      } else if (value == 'settings') {
                        Get.toNamed(AppRoutes.settings);
                      }
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards
            Obx(() {
              final stats = attendanceController.stats.value;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isTablet ? 4 : 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: isTablet ? 1.5 : 1.2,
                children: [
                  _buildStatCard(
                    'Today Check-ins',
                    '${stats?.todayCheckIns ?? 0}',
                    Icons.login,
                    AppColors.success,
                  ),
                  _buildStatCard(
                    'Active Members',
                    '${stats?.activeMembersToday ?? 0}',
                    Icons.people,
                    AppColors.primary,
                  ),
                  _buildStatCard(
                    'Monthly Check-ins',
                    '${stats?.monthlyCheckIns ?? 0}',
                    Icons.calendar_today,
                    AppColors.accent,
                  ),
                  _buildStatCard(
                    'Total Check-ins',
                    '${stats?.totalCheckIns ?? 0}',
                    Icons.bar_chart,
                    AppColors.info,
                  ),
                ],
              );
            }),
            const SizedBox(height: AppSpacing.xl),
            
            // Menu Grid
            Text(
              'Main Menu',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: AppSpacing.md),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isTablet ? 4 : 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              children: _buildMenuItems(authController),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: AppTextStyles.heading2.copyWith(color: color),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              title,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMenuItems(AuthController authController) {
    final items = <Map<String, dynamic>>[
      {
        'title': 'Members',
        'icon': Icons.people,
        'color': AppColors.primary,
        'route': AppRoutes.memberList,
        'permission': 'view_members',
      },
      {
        'title': 'Membership',
        'icon': Icons.card_membership,
        'color': AppColors.accent,
        'route': AppRoutes.subscription,
        'permission': 'manage_membership',
      },
      {
        'title': 'Attendance',
        'icon': Icons.qr_code_scanner,
        'color': AppColors.success,
        'route': AppRoutes.attendance,
        'permission': 'record_attendance',
      },
      {
        'title': 'POS',
        'icon': Icons.point_of_sale,
        'color': AppColors.warning,
        'route': AppRoutes.pos,
        'permission': 'pos_operations',
      },
      {
        'title': 'Reports',
        'icon': Icons.analytics,
        'color': AppColors.info,
        'route': AppRoutes.reports,
        'permission': 'view_reports',
      },
      {
        'title': 'Settings',
        'icon': Icons.settings,
        'color': AppColors.textSecondary,
        'route': AppRoutes.settings,
        'permission': 'view_settings',
      },
    ];

    return items
        .where((item) => authController.hasPermission(item['permission']))
        .map((item) => _buildMenuItem(
              item['title'],
              item['icon'],
              item['color'],
              item['route'],
            ))
        .toList();
  }

  Widget _buildMenuItem(String title, IconData icon, Color color, String route) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => Get.toNamed(route),
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
