import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/pos_controller.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';
import 'package:intl/intl.dart';

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
    String? paymentProofPath;
    bool isProcessing = false;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          final showProofUpload = selectedPaymentMethod != 'Cash';
          
          return AlertDialog(
            title: const Text('Payment'),
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
                      labelText: 'Payment Method',
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
                        paymentProofPath = null;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  TextField(
                    controller: paidController,
                    decoration: const InputDecoration(
                      labelText: 'Amount Paid',
                      prefixText: 'Rp ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  
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
                          Icon(
                            paymentProofPath != null
                                ? Icons.check_circle
                                : Icons.upload_file,
                            size: 40,
                            color: paymentProofPath != null
                                ? AppColors.success
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            paymentProofPath != null
                                ? 'Payment proof uploaded'
                                : 'Upload payment proof',
                            style: TextStyle(
                              color: paymentProofPath != null
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {
                                  // In production, use image_picker to capture from camera
                                  setDialogState(() {
                                    paymentProofPath = 'camera_proof_${DateTime.now().millisecondsSinceEpoch}.jpg';
                                  });
                                  Get.snackbar('Info', 'Camera capture simulated');
                                },
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Camera'),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              OutlinedButton.icon(
                                onPressed: () {
                                  // In production, use image_picker to select from gallery
                                  setDialogState(() {
                                    paymentProofPath = 'gallery_proof_${DateTime.now().millisecondsSinceEpoch}.jpg';
                                  });
                                  Get.snackbar('Info', 'Gallery selection simulated');
                                },
                                icon: const Icon(Icons.photo_library),
                                label: const Text('Gallery'),
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
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isProcessing ? null : () async {
                  final paidAmount = double.tryParse(paidController.text) ?? 0;
                  
                  if (paidAmount <= 0) {
                    Get.snackbar('Error', 'Please enter a valid amount');
                    return;
                  }
                  
                  if (paidAmount < controller.total.value) {
                    Get.snackbar('Error', 'Insufficient payment amount');
                    return;
                  }
                  
                  // For non-cash payments, require proof
                  if (showProofUpload && paymentProofPath == null) {
                    Get.snackbar('Error', 'Please upload payment proof');
                    return;
                  }
                  
                  setDialogState(() => isProcessing = true);
                  
                  try {
                    final success = await controller.processTransaction(
                      paymentMethod: selectedPaymentMethod,
                      paidAmount: paidAmount,
                      // In production, paymentProofPath would be uploaded to server
                    );
                    
                    if (success) {
                      Get.back();
                      Get.snackbar(
                        'Success',
                        'Payment processed successfully',
                        backgroundColor: AppColors.success,
                        colorText: Colors.white,
                      );
                    }
                  } finally {
                    setDialogState(() => isProcessing = false);
                  }
                },
                child: const Text('Process Payment'),
              ),
            ],
          );
        },
      ),
    );
  }
}
