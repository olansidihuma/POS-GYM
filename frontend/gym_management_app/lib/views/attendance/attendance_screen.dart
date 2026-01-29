import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/attendance_controller.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';
import 'package:intl/intl.dart';

/// Attendance screen with USB barcode/QR scanner support.
/// USB scanners act as keyboard input devices (keyboard wedge mode),
/// so we use a TextField to capture scanned data.
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final TextEditingController _scannerController = TextEditingController();
  final FocusNode _scannerFocusNode = FocusNode();
  bool _isProcessing = false;
  String _lastScannedCode = '';
  DateTime? _lastScanTime;

  @override
  void initState() {
    super.initState();
    // Auto-focus the scanner input field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scannerFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _scannerFocusNode.dispose();
    super.dispose();
  }

  /// Process scanned QR/barcode data from USB scanner
  Future<void> _processScannedCode(String code) async {
    if (code.isEmpty || _isProcessing) return;
    
    // Prevent duplicate scans within 2 seconds
    final now = DateTime.now();
    if (_lastScannedCode == code && 
        _lastScanTime != null && 
        now.difference(_lastScanTime!).inSeconds < 2) {
      _scannerController.clear();
      return;
    }
    
    setState(() {
      _isProcessing = true;
      _lastScannedCode = code;
      _lastScanTime = now;
    });
    
    try {
      final attendanceController = Get.find<AttendanceController>();
      await attendanceController.scanQrCode(code);
    } finally {
      setState(() {
        _isProcessing = false;
      });
      _scannerController.clear();
      _scannerFocusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AttendanceController());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: controller.selectedDate.value,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                controller.changeDate(date);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // USB Scanner Input Section
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.qr_code_scanner,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  _isProcessing ? 'Processing...' : 'Ready to Scan',
                  style: AppTextStyles.heading3.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Use USB barcode/QR scanner to check-in members',
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                // Hidden text field for capturing USB scanner input
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                  ),
                  child: TextField(
                    controller: _scannerController,
                    focusNode: _scannerFocusNode,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Scan QR code or type member code...',
                      prefixIcon: Icon(
                        Icons.qr_code,
                        color: _isProcessing ? AppColors.warning : AppColors.primary,
                      ),
                      suffixIcon: _isProcessing
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: () => _processScannedCode(_scannerController.text.trim()),
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    enabled: !_isProcessing,
                    onSubmitted: (value) => _processScannedCode(value.trim()),
                    // USB scanners typically send Enter after the scan
                    textInputAction: TextInputAction.done,
                  ),
                ),
                if (_lastScannedCode.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Last scan: $_lastScannedCode',
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.white54),
                  ),
                ],
              ],
            ),
          ),
          
          // Stats
          Obx(() {
            final stats = controller.stats.value;
            return Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              color: AppColors.primary.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Today', '${stats?.todayCheckIns ?? 0}'),
                  _buildStatItem('Monthly', '${stats?.monthlyCheckIns ?? 0}'),
                  _buildStatItem('Active Now', '${stats?.activeMembersToday ?? 0}'),
                ],
              ),
            );
          }),
          
          // Attendance List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const LoadingWidget();
              }

              if (controller.attendances.isEmpty) {
                return const Center(
                  child: Text('No attendance records for this date'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: controller.attendances.length,
                itemBuilder: (context, index) {
                  final attendance = controller.attendances[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: attendance.isCheckedOut
                            ? AppColors.success
                            : AppColors.warning,
                        child: Icon(
                          attendance.isCheckedOut
                              ? Icons.check
                              : Icons.login,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(attendance.memberName ?? 'Unknown'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Check-in: ${DateFormat('HH:mm').format(attendance.checkInTime)}'),
                          if (attendance.checkOutTime != null)
                            Text('Check-out: ${DateFormat('HH:mm').format(attendance.checkOutTime!)}'),
                          if (attendance.duration != null)
                            Text('Duration: ${attendance.durationString}'),
                        ],
                      ),
                      trailing: !attendance.isCheckedOut
                          ? ElevatedButton(
                              onPressed: () {
                                controller.checkOut(attendance.id!);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                              ),
                              child: const Text('Check Out'),
                            )
                          : null,
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }
}
