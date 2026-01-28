import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../controllers/attendance_controller.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrController;
  bool isScanning = false;

  @override
  void dispose() {
    qrController?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    qrController = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (!isScanning) {
        isScanning = true;
        qrController?.pauseCamera();
        
        final attendanceController = Get.find<AttendanceController>();
        await attendanceController.scanQrCode(scanData.code ?? '');
        
        await Future.delayed(const Duration(seconds: 2));
        qrController?.resumeCamera();
        isScanning = false;
      }
    });
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
          // QR Scanner
          Container(
            height: 250,
            color: Colors.black,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: AppColors.primary,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 200,
              ),
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
