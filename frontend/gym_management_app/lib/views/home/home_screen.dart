import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/attendance_controller.dart';
import '../../routes/app_routes.dart';
import '../../utils/constants.dart';

/// Modern, unique and informative dashboard for the Gym Management System.
/// Features a gradient header with welcome message, animated stat cards,
/// quick action buttons, and a modern menu grid.
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final attendanceController = Get.put(AttendanceController());
    final isTablet = MediaQuery.of(context).size.width > 600;
    final today = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with Gradient
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withBlue(200),
                      AppColors.secondary,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Obx(() {
                      final user = authController.currentUser.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  child: Text(
                                    (user?.fullName ?? user?.username ?? 'U')[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome back,',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                    Text(
                                      user?.fullName ?? user?.username ?? 'User',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.calendar_today, size: 14, color: Colors.white),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  today,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
            actions: [
              Obx(() {
                final user = authController.currentUser.value;
                return PopupMenuButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.more_vert, color: Colors.white),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      enabled: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? user?.username ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            user?.role.toUpperCase() ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Divider(),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'settings',
                      child: Row(
                        children: [
                          Icon(Icons.settings_outlined),
                          SizedBox(width: 12),
                          Text('Settings'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: AppColors.error),
                          const SizedBox(width: 12),
                          Text('Logout', style: TextStyle(color: AppColors.error)),
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
                );
              }),
              const SizedBox(width: AppSpacing.sm),
            ],
          ),

          // Dashboard Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Section
                  Row(
                    children: [
                      Icon(Icons.insights, color: AppColors.primary, size: 24),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Today\'s Overview',
                        style: AppTextStyles.heading3,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  // Modern Stats Cards
                  Obx(() {
                    final stats = attendanceController.stats.value;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: isTablet ? 4 : 2,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: isTablet ? 1.8 : 1.4,
                      children: [
                        _buildModernStatCard(
                          'Today Check-ins',
                          '${stats?.todayCheckIns ?? 0}',
                          Icons.login_rounded,
                          const Color(0xFF4CAF50),
                          const Color(0xFF81C784),
                        ),
                        _buildModernStatCard(
                          'Active Now',
                          '${stats?.activeMembersToday ?? 0}',
                          Icons.people_alt_rounded,
                          const Color(0xFF2196F3),
                          const Color(0xFF64B5F6),
                        ),
                        _buildModernStatCard(
                          'Monthly Check-ins',
                          '${stats?.monthlyCheckIns ?? 0}',
                          Icons.calendar_month_rounded,
                          const Color(0xFFFF9800),
                          const Color(0xFFFFB74D),
                        ),
                        _buildModernStatCard(
                          'Total Check-ins',
                          '${stats?.totalCheckIns ?? 0}',
                          Icons.bar_chart_rounded,
                          const Color(0xFF9C27B0),
                          const Color(0xFFBA68C8),
                        ),
                      ],
                    );
                  }),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Quick Actions Section
                  Row(
                    children: [
                      Icon(Icons.flash_on, color: AppColors.accent, size: 24),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Quick Actions',
                        style: AppTextStyles.heading3,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  // Quick Action Buttons
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        if (authController.hasPermission('record_attendance'))
                          _buildQuickAction(
                            'Quick Check-in',
                            Icons.qr_code_scanner,
                            AppColors.success,
                            () => Get.toNamed(AppRoutes.attendance),
                          ),
                        if (authController.hasPermission('pos_operations'))
                          _buildQuickAction(
                            'New Sale',
                            Icons.point_of_sale,
                            AppColors.warning,
                            () => Get.toNamed(AppRoutes.pos),
                          ),
                        if (authController.hasPermission('view_members'))
                          _buildQuickAction(
                            'Add Member',
                            Icons.person_add,
                            AppColors.primary,
                            () => Get.toNamed(AppRoutes.memberList),
                          ),
                        if (authController.hasPermission('view_reports'))
                          _buildQuickAction(
                            'View Reports',
                            Icons.analytics,
                            AppColors.info,
                            () => Get.toNamed(AppRoutes.reports),
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Menu Grid Section
                  Row(
                    children: [
                      Icon(Icons.apps, color: AppColors.primary, size: 24),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Main Menu',
                        style: AppTextStyles.heading3,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  // Modern Menu Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: isTablet ? 4 : 3,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: 1.0,
                    children: _buildMenuItems(authController),
                  ),
                  
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatCard(
    String title,
    String value,
    IconData icon,
    Color primaryColor,
    Color secondaryColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, secondaryColor],
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 24, color: Colors.white),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: AppSpacing.md),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.large),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 24, color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMenuItems(AuthController authController) {
    final items = <Map<String, dynamic>>[
      {
        'title': 'Members',
        'subtitle': 'Manage gym members',
        'icon': Icons.people_alt_rounded,
        'color': const Color(0xFF2196F3),
        'route': AppRoutes.memberList,
        'permission': 'view_members',
      },
      {
        'title': 'Membership',
        'subtitle': 'Subscriptions',
        'icon': Icons.card_membership_rounded,
        'color': const Color(0xFFFF9800),
        'route': AppRoutes.subscription,
        'permission': 'manage_membership',
      },
      {
        'title': 'Attendance',
        'subtitle': 'Check-in system',
        'icon': Icons.qr_code_scanner_rounded,
        'color': const Color(0xFF4CAF50),
        'route': AppRoutes.attendance,
        'permission': 'record_attendance',
      },
      {
        'title': 'POS',
        'subtitle': 'Point of sale',
        'icon': Icons.point_of_sale_rounded,
        'color': const Color(0xFFE91E63),
        'route': AppRoutes.pos,
        'permission': 'pos_operations',
      },
      {
        'title': 'Reports',
        'subtitle': 'Analytics & data',
        'icon': Icons.analytics_rounded,
        'color': const Color(0xFF9C27B0),
        'route': AppRoutes.reports,
        'permission': 'view_reports',
      },
      {
        'title': 'Settings',
        'subtitle': 'App configuration',
        'icon': Icons.settings_rounded,
        'color': const Color(0xFF607D8B),
        'route': AppRoutes.settings,
        'permission': 'view_settings',
      },
    ];

    return items
        .where((item) => authController.hasPermission(item['permission']))
        .map((item) => _buildModernMenuItem(
              item['title'],
              item['subtitle'],
              item['icon'],
              item['color'],
              item['route'],
            ))
        .toList();
  }

  Widget _buildModernMenuItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String route,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.toNamed(route),
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppBorderRadius.large),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
