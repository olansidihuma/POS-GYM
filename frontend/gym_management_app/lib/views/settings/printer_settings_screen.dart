import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../utils/constants.dart';
import '../../services/settings_service.dart';

class PrinterSettingsScreen extends StatefulWidget {
  const PrinterSettingsScreen({Key? key}) : super(key: key);

  @override
  State<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends State<PrinterSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final SettingsService _settingsService = SettingsService();
  
  final _shopNameController = TextEditingController(text: 'Gym Management');
  final _shopAddressController = TextEditingController();
  final _shopPhoneController = TextEditingController();
  final _footerController = TextEditingController(text: 'Thank you for your visit!');
  
  String? _selectedPrinter;
  bool _isScanning = false;
  bool _isPrinting = false;
  bool _isLoading = true;
  bool _isSaving = false;
  List<Map<String, String>> _availablePrinters = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await _settingsService.getSettings();
      if (result['success'] == true) {
        final settings = result['settings'] as Map<String, dynamic>? ?? {};
        
        setState(() {
          if (settings['shop_name'] != null) {
            _shopNameController.text = settings['shop_name']['value'] ?? 'Gym Management';
          }
          if (settings['shop_address'] != null) {
            _shopAddressController.text = settings['shop_address']['value'] ?? '';
          }
          if (settings['shop_phone'] != null) {
            _shopPhoneController.text = settings['shop_phone']['value'] ?? '';
          }
          if (settings['receipt_footer'] != null) {
            _footerController.text = settings['receipt_footer']['value'] ?? 'Thank you for your visit!';
          }
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load settings');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _shopAddressController.dispose();
    _shopPhoneController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  Future<void> _scanPrinters() async {
    setState(() => _isScanning = true);
    
    // Simulate scanning - In production, use blue_thermal_printer package
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _availablePrinters = [
        {'name': 'Thermal Printer 58mm', 'address': '00:11:22:33:44:55'},
        {'name': 'POS Printer', 'address': '66:77:88:99:AA:BB'},
      ];
      _isScanning = false;
    });
  }

  Future<void> _printTestReceipt() async {
    if (_selectedPrinter == null) {
      Get.snackbar('Error', 'Please select a printer first');
      return;
    }
    
    setState(() => _isPrinting = true);
    
    // Simulate printing - In production, use blue_thermal_printer package
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() => _isPrinting = false);
    
    Get.snackbar(
      'Success',
      'Test receipt printed successfully',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
    );
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      
      try {
        final result = await _settingsService.updateSettings({
          'shop_name': _shopNameController.text,
          'shop_address': _shopAddressController.text,
          'shop_phone': _shopPhoneController.text,
          'receipt_footer': _footerController.text,
        });
        
        if (result['success'] == true) {
          Get.snackbar(
            'Success',
            'Printer settings saved',
            backgroundColor: AppColors.success,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar('Error', result['message'] ?? 'Failed to save settings');
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to save settings');
      } finally {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Printer Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bluetooth Printer Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.bluetooth, color: AppColors.primary),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Bluetooth Printer',
                            style: AppTextStyles.heading3,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      
                      ElevatedButton.icon(
                        onPressed: _isScanning ? null : _scanPrinters,
                        icon: _isScanning 
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.search),
                        label: Text(_isScanning ? 'Scanning...' : 'Scan for Printers'),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      
                      if (_availablePrinters.isNotEmpty) ...[
                        const Text('Available Printers:'),
                        const SizedBox(height: AppSpacing.sm),
                        ...List.generate(_availablePrinters.length, (index) {
                          final printer = _availablePrinters[index];
                          final isSelected = _selectedPrinter == printer['address'];
                          
                          return Card(
                            color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
                            child: ListTile(
                              leading: Icon(
                                Icons.print,
                                color: isSelected ? AppColors.primary : null,
                              ),
                              title: Text(printer['name'] ?? 'Unknown'),
                              subtitle: Text(printer['address'] ?? ''),
                              trailing: isSelected 
                                  ? Icon(Icons.check_circle, color: AppColors.success)
                                  : null,
                              onTap: () {
                                setState(() {
                                  _selectedPrinter = printer['address'];
                                });
                              },
                            ),
                          );
                        }),
                      ],
                      
                      if (_selectedPrinter != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        OutlinedButton.icon(
                          onPressed: _isPrinting ? null : _printTestReceipt,
                          icon: _isPrinting 
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.print),
                          label: Text(_isPrinting ? 'Printing...' : 'Print Test Receipt'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Receipt Settings Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.receipt_long, color: AppColors.primary),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Receipt Settings',
                            style: AppTextStyles.heading3,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      
                      // Logo Upload
                      Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: Icon(
                              Icons.image,
                              size: 40,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Receipt Logo'),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'Recommended size: 200x80 pixels',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                OutlinedButton(
                                  onPressed: () {
                                    Get.snackbar('Info', 'Logo upload coming soon');
                                  },
                                  child: const Text('Upload Logo'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      
                      CustomTextField(
                        controller: _shopNameController,
                        label: 'Shop Name',
                        prefixIcon: Icons.store,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter shop name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      
                      CustomTextField(
                        controller: _shopAddressController,
                        label: 'Shop Address',
                        prefixIcon: Icons.location_on,
                        maxLines: 2,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      
                      CustomTextField(
                        controller: _shopPhoneController,
                        label: 'Shop Phone',
                        prefixIcon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      
                      CustomTextField(
                        controller: _footerController,
                        label: 'Receipt Footer',
                        prefixIcon: Icons.text_fields,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Receipt Preview Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.preview, color: AppColors.primary),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Receipt Preview',
                            style: AppTextStyles.heading3,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.divider),
                          borderRadius: BorderRadius.circular(AppBorderRadius.small),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.fitness_center,
                              size: 40,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              _shopNameController.text.isNotEmpty 
                                  ? _shopNameController.text 
                                  : 'Shop Name',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (_shopAddressController.text.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                _shopAddressController.text,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                            if (_shopPhoneController.text.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                _shopPhoneController.text,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              '--------------------------------',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            const Text('Sample Item x1     Rp 25,000'),
                            const Text('Sample Item x2     Rp 30,000'),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              '--------------------------------',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            const Text(
                              'Total: Rp 55,000',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              _footerController.text.isNotEmpty 
                                  ? _footerController.text 
                                  : 'Footer Text',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              CustomButton(
                text: _isSaving ? 'Saving...' : 'Save Settings',
                onPressed: _isSaving ? null : _saveSettings,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
