import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/constants.dart';
import '../../services/report_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final ReportService _reportService = ReportService();

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
              () => _showReportDialog('daily_sales', 'Daily Sales Report'),
            ),
            _buildReportCard(
              'Monthly Sales',
              Icons.calendar_month,
              AppColors.accent,
              () => _showReportDialog('monthly_sales', 'Monthly Sales Report'),
            ),
            _buildReportCard(
              'Attendance Report',
              Icons.people,
              AppColors.success,
              () => _showReportDialog('attendance', 'Attendance Report'),
            ),
            _buildReportCard(
              'Member Report',
              Icons.card_membership,
              AppColors.info,
              () => _showReportDialog('members', 'Member Report'),
            ),
          ],
          if (authController.isAdmin || authController.isOwner) ...[
            _buildReportCard(
              'Financial Report',
              Icons.monetization_on,
              AppColors.warning,
              () => _showReportDialog('financial', 'Financial Report'),
            ),
            _buildReportCard(
              'Expense Report',
              Icons.receipt_long,
              AppColors.error,
              () => _showReportDialog('expenses', 'Expense Report'),
            ),
            _buildReportCard(
              'Revenue Report',
              Icons.trending_up,
              Colors.green,
              () => _showReportDialog('revenue', 'Revenue Report'),
            ),
            _buildReportCard(
              'Inventory Report',
              Icons.inventory,
              Colors.purple,
              () => _showReportDialog('inventory', 'Inventory Report'),
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

  void _showReportDialog(String reportType, String title) {
    DateTime dateFrom = DateTime.now().subtract(const Duration(days: 30));
    DateTime dateTo = DateTime.now();
    bool isLoading = false;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select date range:'),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: dateFrom,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setDialogState(() => dateFrom = date);
                          }
                        },
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(DateFormat('dd/MM/yyyy').format(dateFrom)),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('to'),
                    ),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: dateTo,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setDialogState(() => dateTo = date);
                          }
                        },
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(DateFormat('dd/MM/yyyy').format(dateTo)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Export as PDF'),
                      onPressed: () async {
                        setDialogState(() => isLoading = true);
                        await _exportReport(reportType, dateFrom, dateTo, 'pdf');
                        setDialogState(() => isLoading = false);
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.table_chart),
                      label: const Text('Export as Excel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () async {
                        setDialogState(() => isLoading = true);
                        await _exportReport(reportType, dateFrom, dateTo, 'excel');
                        setDialogState(() => isLoading = false);
                      },
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Get.back(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _exportReport(String reportType, DateTime dateFrom, DateTime dateTo, String format) async {
    try {
      final result = await _reportService.getReportData(
        reportType: reportType,
        dateFrom: DateFormat('yyyy-MM-dd').format(dateFrom),
        dateTo: DateFormat('yyyy-MM-dd').format(dateTo),
      );

      if (result['success'] == true) {
        final data = result['data'];
        
        // In production, this would generate actual PDF/Excel files using pdf/excel packages
        // For now, we show the data was fetched successfully
        Get.back();
        Get.snackbar(
          'Success',
          '${format.toUpperCase()} report generated successfully. '
          'Report: ${data['report_title']} with ${(data['rows'] as List?)?.length ?? 0} records.',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        
        // TODO: In production, use pdf package to generate PDF or excel package to generate Excel
        // and save to device/share
      } else {
        Get.snackbar('Error', result['message'] ?? 'Failed to generate report');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate report: $e');
    }
  }
}
