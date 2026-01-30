import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import 'settings_service.dart';

class PrinterService {
  static final PrinterService _instance = PrinterService._internal();
  factory PrinterService() => _instance;
  PrinterService._internal();

  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  final SettingsService _settingsService = SettingsService();
  
  BluetoothDevice? _connectedDevice;
  bool _isConnected = false;
  String? _lastError;

  bool get isConnected => _isConnected;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  String? get lastError => _lastError;

  Future<List<BluetoothDevice>> scanDevices() async {
    try {
      _lastError = null;
      return await bluetooth.getBondedDevices();
    } catch (e) {
      _lastError = 'Gagal memindai perangkat: $e';
      return [];
    }
  }

  Future<bool> connect(BluetoothDevice device) async {
    try {
      _lastError = null;
      await bluetooth.connect(device);
      _connectedDevice = device;
      _isConnected = true;
      return true;
    } catch (e) {
      _lastError = 'Gagal menghubungkan printer: $e';
      _isConnected = false;
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      _lastError = null;
      await bluetooth.disconnect();
      _connectedDevice = null;
      _isConnected = false;
    } catch (e) {
      _lastError = 'Gagal memutuskan koneksi: $e';
    }
  }

  /// Check if payment method is cash (case-insensitive)
  static bool isCashPayment(String paymentMethod) {
    return paymentMethod.toLowerCase() == 'cash';
  }

  Future<bool> printReceipt(Transaction transaction) async {
    if (!_isConnected) {
      _lastError = 'Printer tidak terhubung';
      return false;
    }

    try {
      _lastError = null;
      
      // Get shop settings
      String shopName = 'Gym Management';
      String shopAddress = '';
      String shopPhone = '';
      String footerText = 'Terima kasih!';

      try {
        final settings = await _settingsService.getSettings();
        if (settings['success'] == true) {
          final settingsData = settings['settings'] as Map<String, dynamic>? ?? {};
          shopName = settingsData['shop_name']?['value'] ?? 'Gym Management';
          shopAddress = settingsData['shop_address']?['value'] ?? '';
          shopPhone = settingsData['shop_phone']?['value'] ?? '';
          footerText = settingsData['receipt_footer']?['value'] ?? 'Terima kasih!';
        }
      } catch (_) {}

      final currencyFormat = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );

      final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

      // Print header
      bluetooth.printNewLine();
      bluetooth.printCustom(shopName, 2, 1); // Size 2, Center aligned
      if (shopAddress.isNotEmpty) {
        bluetooth.printCustom(shopAddress, 0, 1);
      }
      if (shopPhone.isNotEmpty) {
        bluetooth.printCustom(shopPhone, 0, 1);
      }
      bluetooth.printCustom('================================', 0, 1);
      
      // Transaction info
      bluetooth.printLeftRight('No:', transaction.transactionNumber, 0);
      bluetooth.printLeftRight('Tanggal:', dateFormat.format(transaction.transactionDate), 0);
      bluetooth.printLeftRight('Metode:', transaction.paymentMethod, 0);
      bluetooth.printCustom('--------------------------------', 0, 1);

      // Items
      if (transaction.items != null) {
        for (var item in transaction.items!) {
          bluetooth.printCustom(item.productName, 0, 0); // Left aligned
          bluetooth.printLeftRight(
            '  ${item.quantity} x ${currencyFormat.format(item.price)}',
            currencyFormat.format(item.subtotal),
            0,
          );
        }
      }
      bluetooth.printCustom('--------------------------------', 0, 1);

      // Totals
      bluetooth.printLeftRight('Subtotal:', currencyFormat.format(transaction.subtotal), 0);
      if (transaction.discount > 0) {
        bluetooth.printLeftRight('Diskon:', '-${currencyFormat.format(transaction.discount)}', 0);
      }
      if (transaction.tax > 0) {
        bluetooth.printLeftRight('Pajak:', currencyFormat.format(transaction.tax), 0);
      }
      bluetooth.printCustom('================================', 0, 1);
      bluetooth.printLeftRight('TOTAL:', currencyFormat.format(transaction.total), 1);
      bluetooth.printCustom('================================', 0, 1);

      // Payment info
      bluetooth.printLeftRight('Bayar:', currencyFormat.format(transaction.paidAmount), 0);
      if (isCashPayment(transaction.paymentMethod)) {
        bluetooth.printLeftRight('Kembalian:', currencyFormat.format(transaction.changeAmount), 1);
      }

      bluetooth.printNewLine();
      bluetooth.printCustom(footerText, 0, 1);
      bluetooth.printNewLine();
      bluetooth.printNewLine();
      bluetooth.printNewLine();

      return true;
    } catch (e) {
      _lastError = 'Gagal mencetak: $e';
      return false;
    }
  }
}
