import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/constants.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: GridView.count(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
        padding: const EdgeInsets.all(AppSpacing.lg),
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        children: [
          if (authController.hasPermission('view_reports')) ...[
            _buildReportCard(
              'Daily Sales',
              Icons.today,
              AppColors.primary,
              () => _generateReport('daily_sales'),
            ),
            _buildReportCard(
              'Monthly Sales',
              Icons.calendar_month,
              AppColors.accent,
              () => _generateReport('monthly_sales'),
            ),
            _buildReportCard(
              'Attendance Report',
              Icons.people,
              AppColors.success,
              () => _generateReport('attendance'),
            ),
            _buildReportCard(
              'Member Report',
              Icons.card_membership,
              AppColors.info,
              () => _generateReport('members'),
            ),
          ],
          if (authController.isAdmin || authController.isOwner) ...[
            _buildReportCard(
              'Financial Report',
              Icons.monetization_on,
              AppColors.warning,
              () => _generateReport('financial'),
            ),
            _buildReportCard(
              'Expense Report',
              Icons.receipt_long,
              AppColors.error,
              () => _generateReport('expenses'),
            ),
            _buildReportCard(
              'Revenue Report',
              Icons.trending_up,
              Colors.green,
              () => _generateReport('revenue'),
            ),
            _buildReportCard(
              'Inventory Report',
              Icons.inventory,
              Colors.purple,
              () => _generateReport('inventory'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReportCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
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

  void _generateReport(String reportType) {
    Get.defaultDialog(
      title: 'Generate Report',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Select date range for $reportType report'),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Export as PDF'),
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Success',
                'PDF report generated successfully',
                backgroundColor: AppColors.success,
                colorText: Colors.white,
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          ElevatedButton.icon(
            icon: const Icon(Icons.table_chart),
            label: const Text('Export as Excel'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Success',
                'Excel report generated successfully',
                backgroundColor: AppColors.success,
                colorText: Colors.white,
              );
            },
          ),
        ],
      ),
    );
  }
}
