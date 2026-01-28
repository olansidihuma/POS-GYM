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

            return GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.8,
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
                              size: 60,
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
                                ),
                              ),
                              Text(
                                'Stock: ${product.stock}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: product.isLowStock
                                      ? AppColors.error
                                      : AppColors.textSecondary,
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
                  title: Text(item.productName),
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
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            controller.updateCartItemQuantity(
                              index,
                              item.quantity - 1,
                            );
                          },
                        ),
                        Text('${item.quantity}'),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
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

    Get.defaultDialog(
      title: 'Payment',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: selectedPaymentMethod,
            decoration: const InputDecoration(
              labelText: 'Payment Method',
            ),
            items: AppConstants.paymentMethods.map((method) {
              return DropdownMenuItem(
                value: method,
                child: Text(method),
              );
            }).toList(),
            onChanged: (value) {
              selectedPaymentMethod = value!;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: paidController,
            decoration: const InputDecoration(
              labelText: 'Amount Paid',
              prefixText: 'Rp ',
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      textConfirm: 'Process Payment',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        final paidAmount = double.tryParse(paidController.text) ?? 0;
        final success = await controller.processTransaction(
          paymentMethod: selectedPaymentMethod,
          paidAmount: paidAmount,
        );
        
        if (success) {
          Get.back();
        }
      },
    );
  }
}
