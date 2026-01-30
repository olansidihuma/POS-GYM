import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:convert';
import '../../controllers/pos_controller.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';
import '../../services/printer_service.dart';
import '../../models/transaction_model.dart';

class PosScreen extends StatelessWidget {
  const PosScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PosController());
    final isTablet = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Point of Sale'),
      ),
      body: isTablet ? _buildTabletLayout(controller) : _buildPhoneLayout(controller),
    );
  }

  Widget _buildTabletLayout(PosController controller) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildProductSection(controller),
        ),
        Container(
          width: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
              ),
            ],
          ),
          child: _buildCartSection(controller),
        ),
      ],
    );
  }

  Widget _buildPhoneLayout(PosController controller) {
    return Column(
      children: [
        Expanded(child: _buildProductSection(controller)),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
              ),
            ],
          ),
          child: _buildCartSummary(controller),
        ),
      ],
    );
  }

  Widget _buildProductSection(PosController controller) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                    ),
                  ),
                  onChanged: (value) {
                    controller.searchProducts(value);
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Obx(() {
                return DropdownButton<int?>(
                  value: controller.selectedCategoryId.value,
                  hint: const Text('Category'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Categories'),
                    ),
                    ...controller.categories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    controller.filterByCategory(value);
                  },
                );
              }),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const LoadingWidget();
            }

            if (controller.products.isEmpty) {
              return const Center(child: Text('No products available'));
            }

            // Calculate responsive cross axis count based on screen width
            final screenWidth = MediaQuery.of(context).size.width;
            int crossAxisCount;
            double childAspectRatio;
            
            if (screenWidth > 1200) {
              crossAxisCount = 5;
              childAspectRatio = 0.85;
            } else if (screenWidth > 900) {
              crossAxisCount = 4;
              childAspectRatio = 0.8;
            } else if (screenWidth > 600) {
              crossAxisCount = 3;
              childAspectRatio = 0.75;
            } else if (screenWidth > 400) {
              crossAxisCount = 2;
              childAspectRatio = 0.85;
            } else {
              crossAxisCount = 2;
              childAspectRatio = 0.7;
            }

            return GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: controller.products.length,
              itemBuilder: (context, index) {
                final product = controller.products[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      controller.addToCart(product);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Container(
                            color: AppColors.background,
                            child: Icon(
                              Icons.inventory_2,
                              size: screenWidth > 600 ? 60 : 40,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: screenWidth > 600 ? 14 : 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                NumberFormat.currency(
                                  locale: 'id_ID',
                                  symbol: 'Rp ',
                                  decimalDigits: 0,
                                ).format(product.price),
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth > 600 ? 16 : 13,
                                ),
                              ),
                              Text(
                                'Stock: ${product.stock}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: product.isLowStock
                                      ? AppColors.error
                                      : AppColors.textSecondary,
                                  fontSize: screenWidth > 600 ? 12 : 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCartSection(PosController controller) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          color: AppColors.primary,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cart',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Obx(() {
                return Text(
                  '${controller.cartItemCount} items',
                  style: const TextStyle(color: Colors.white),
                );
              }),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.cartItems.isEmpty) {
              return const Center(
                child: Text('Cart is empty'),
              );
            }

            return ListView.builder(
              itemCount: controller.cartItems.length,
              itemBuilder: (context, index) {
                final item = controller.cartItems[index];
                return ListTile(
                  title: Text(
                    item.productName,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  subtitle: Text(
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(item.price),
                  ),
                  trailing: SizedBox(
                    width: 120,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          onPressed: () {
                            controller.updateCartItemQuantity(
                              index,
                              item.quantity - 1,
                            );
                          },
                        ),
                        SizedBox(
                          width: 24,
                          child: Text(
                            '${item.quantity}',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          onPressed: () {
                            controller.updateCartItemQuantity(
                              index,
                              item.quantity + 1,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              Obx(() {
                return Column(
                  children: [
                    _buildTotalRow('Subtotal', controller.subtotal.value),
                    _buildTotalRow('Discount', controller.discount.value),
                    _buildTotalRow('Tax', controller.tax.value),
                    const Divider(),
                    _buildTotalRow('Total', controller.total.value, isBold: true),
                  ],
                );
              }),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.clearCart();
                      },
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        _showPaymentDialog(controller);
                      },
                      child: const Text('Checkout'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCartSummary(PosController controller) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Obx(() {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total (${controller.cartItemCount} items):'),
                Text(
                  NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(controller.total.value),
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _showCartDetails(controller);
                  },
                  child: const Text('View Cart'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    _showPaymentDialog(controller);
                  },
                  child: const Text('Checkout'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp ',
              decimalDigits: 0,
            ).format(amount),
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _showCartDetails(PosController controller) {
    Get.bottomSheet(
      Container(
        height: 400,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: _buildCartSection(controller),
      ),
    );
  }

  void _showPaymentDialog(PosController controller) {
    final paidController = TextEditingController();
    String selectedPaymentMethod = 'Cash';
    XFile? paymentProofImage;
    String? paymentProofBase64;
    bool isProcessing = false;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          final isCash = PrinterService.isCashPayment(selectedPaymentMethod);
          final showProofUpload = !isCash;
          final paidAmount = double.tryParse(paidController.text) ?? 0;
          final changeAmount = paidAmount - controller.total.value;
          
          Future<void> captureFromCamera() async {
            try {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(
                source: ImageSource.camera,
                maxWidth: 1024,
                maxHeight: 1024,
                imageQuality: 80,
              );
              
              if (image != null) {
                final bytes = await image.readAsBytes();
                final base64Image = base64Encode(bytes);
                setDialogState(() {
                  paymentProofImage = image;
                  paymentProofBase64 = 'data:image/jpeg;base64,$base64Image';
                });
              }
            } catch (e) {
              Get.snackbar('Error', 'Gagal mengambil foto. Silakan coba lagi.');
            }
          }
          
          Future<void> pickFromGallery() async {
            try {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(
                source: ImageSource.gallery,
                maxWidth: 1024,
                maxHeight: 1024,
                imageQuality: 80,
              );
              
              if (image != null) {
                final bytes = await image.readAsBytes();
                final base64Image = base64Encode(bytes);
                setDialogState(() {
                  paymentProofImage = image;
                  paymentProofBase64 = 'data:image/jpeg;base64,$base64Image';
                });
              }
            } catch (e) {
              Get.snackbar('Error', 'Gagal memilih foto. Silakan coba lagi.');
            }
          }
          
          return AlertDialog(
            title: const Text('Pembayaran'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Payment summary
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppBorderRadius.small),
                    ),
                    child: Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:'),
                        Text(
                          NumberFormat.currency(
                            locale: 'id_ID',
                            symbol: 'Rp ',
                            decimalDigits: 0,
                          ).format(controller.total.value),
                          style: AppTextStyles.heading3.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    )),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  DropdownButtonFormField<String>(
                    value: selectedPaymentMethod,
                    decoration: const InputDecoration(
                      labelText: 'Metode Pembayaran',
                      border: OutlineInputBorder(),
                    ),
                    items: AppConstants.paymentMethods.map((method) {
                      return DropdownMenuItem(
                        value: method,
                        child: Text(method),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedPaymentMethod = value!;
                        paymentProofImage = null;
                        paymentProofBase64 = null;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  TextField(
                    controller: paidController,
                    decoration: const InputDecoration(
                      labelText: 'Jumlah Bayar',
                      prefixText: 'Rp ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setDialogState(() {});
                    },
                  ),
                  
                  // Show change amount for Cash payment
                  if (isCash && paidAmount > 0) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: changeAmount >= 0 
                            ? AppColors.success.withOpacity(0.1) 
                            : AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppBorderRadius.small),
                        border: Border.all(
                          color: changeAmount >= 0 
                              ? AppColors.success 
                              : AppColors.error,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Kembalian',
                            style: TextStyle(
                              color: changeAmount >= 0 
                                  ? AppColors.success 
                                  : AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            NumberFormat.currency(
                              locale: 'id_ID',
                              symbol: 'Rp ',
                              decimalDigits: 0,
                            ).format(changeAmount >= 0 ? changeAmount : 0),
                            style: AppTextStyles.heading2.copyWith(
                              color: changeAmount >= 0 
                                  ? AppColors.success 
                                  : AppColors.error,
                            ),
                          ),
                          if (changeAmount < 0)
                            Text(
                              'Jumlah bayar kurang',
                              style: TextStyle(
                                color: AppColors.error,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  
                  // Payment proof upload for non-cash payments
                  if (showProofUpload) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.divider),
                        borderRadius: BorderRadius.circular(AppBorderRadius.small),
                      ),
                      child: Column(
                        children: [
                          if (paymentProofImage != null) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppBorderRadius.small),
                              child: Image.file(
                                File(paymentProofImage!.path),
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, 
                                    color: AppColors.success, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Bukti pembayaran berhasil diambil',
                                  style: TextStyle(
                                    color: AppColors.success,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ] else ...[
                            Icon(
                              Icons.upload_file,
                              size: 40,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Upload bukti pembayaran',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              OutlinedButton.icon(
                                onPressed: captureFromCamera,
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Kamera'),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              OutlinedButton.icon(
                                onPressed: pickFromGallery,
                                icon: const Icon(Icons.photo_library),
                                label: const Text('Galeri'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  if (isProcessing)
                    const Padding(
                      padding: EdgeInsets.only(top: AppSpacing.md),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isProcessing ? null : () => Get.back(),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: isProcessing ? null : () async {
                  final paidAmount = double.tryParse(paidController.text) ?? 0;
                  
                  if (paidAmount <= 0) {
                    Get.snackbar('Error', 'Masukkan jumlah pembayaran yang valid');
                    return;
                  }
                  
                  if (paidAmount < controller.total.value) {
                    Get.snackbar('Error', 'Jumlah pembayaran kurang');
                    return;
                  }
                  
                  // For non-cash payments, require proof
                  if (showProofUpload && paymentProofBase64 == null) {
                    Get.snackbar('Error', 'Silakan upload bukti pembayaran');
                    return;
                  }
                  
                  // Store values before processing (cart will be cleared on success)
                  final totalAmount = controller.total.value;
                  final subtotalAmount = controller.subtotal.value;
                  final discountAmount = controller.discount.value;
                  final taxAmount = controller.tax.value;
                  final cartItemsCopy = controller.cartItems.toList();
                  
                  setDialogState(() => isProcessing = true);
                  
                  try {
                    final success = await controller.processTransaction(
                      paymentMethod: selectedPaymentMethod,
                      paidAmount: paidAmount,
                      paymentProof: paymentProofBase64,
                    );
                    
                    if (success) {
                      Get.back();
                      
                      // Build transaction for receipt using stored values
                      final changeAmt = paidAmount - totalAmount;
                      final receiptTransaction = Transaction(
                        transactionNumber: 'TRX-${DateTime.now().millisecondsSinceEpoch}',
                        type: 'sale',
                        transactionDate: DateTime.now(),
                        subtotal: subtotalAmount,
                        discount: discountAmount,
                        tax: taxAmount,
                        total: totalAmount,
                        paymentMethod: selectedPaymentMethod,
                        paidAmount: paidAmount,
                        changeAmount: changeAmt > 0 ? changeAmt : 0,
                        items: cartItemsCopy,
                      );
                      
                      // Show success dialog with change amount and print option
                      _showPaymentSuccessDialog(
                        selectedPaymentMethod,
                        paidAmount,
                        totalAmount,
                        receiptTransaction,
                      );
                    }
                  } finally {
                    setDialogState(() => isProcessing = false);
                  }
                },
                child: const Text('Proses Pembayaran'),
              ),
            ],
          );
        },
      ),
    );
  }
  
  void _showPaymentSuccessDialog(
    String paymentMethod,
    double paidAmount,
    double totalAmount,
    Transaction transaction,
  ) {
    final changeAmount = paidAmount - totalAmount;
    final isCash = PrinterService.isCashPayment(paymentMethod);
    final printerService = PrinterService();
    
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 28),
            const SizedBox(width: 8),
            const Text('Pembayaran Berhasil'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              ),
              child: Column(
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(totalAmount),
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Metode:', style: TextStyle(color: AppColors.textSecondary)),
                      Text(paymentMethod, style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Bayar:', style: TextStyle(color: AppColors.textSecondary)),
                      Text(
                        NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(paidAmount),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  if (isCash && changeAmount > 0) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppBorderRadius.small),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'KEMBALIAN',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            NumberFormat.currency(
                              locale: 'id_ID',
                              symbol: 'Rp ',
                              decimalDigits: 0,
                            ).format(changeAmount),
                            style: AppTextStyles.heading1.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              // Try to print receipt
              if (printerService.isConnected) {
                final printed = await printerService.printReceipt(transaction);
                if (printed) {
                  Get.snackbar(
                    'Berhasil',
                    'Struk berhasil dicetak',
                    backgroundColor: AppColors.success,
                    colorText: Colors.white,
                  );
                } else {
                  Get.snackbar('Error', 'Gagal mencetak struk');
                }
              } else {
                // Show printer not connected message
                Get.snackbar(
                  'Info',
                  'Printer belum terhubung. Silakan hubungkan printer di Pengaturan.',
                  duration: const Duration(seconds: 4),
                );
              }
            },
            icon: const Icon(Icons.print),
            label: const Text('Cetak Struk'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
