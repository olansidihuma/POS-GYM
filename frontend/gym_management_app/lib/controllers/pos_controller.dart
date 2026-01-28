import 'package:get/get.dart';
import '../models/product_model.dart';
import '../models/transaction_model.dart';
import '../services/pos_service.dart';

class PosController extends GetxController {
  final PosService _posService = PosService();
  
  final RxList<Product> products = <Product>[].obs;
  final RxList<ProductCategory> categories = <ProductCategory>[].obs;
  final RxList<TransactionItem> cartItems = <TransactionItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final Rx<int?> selectedCategoryId = Rx<int?>(null);
  
  final RxDouble subtotal = 0.0.obs;
  final RxDouble discount = 0.0.obs;
  final RxDouble tax = 0.0.obs;
  final RxDouble total = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
    fetchCategories();
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    try {
      final result = await _posService.getProducts(
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        categoryId: selectedCategoryId.value,
        isActive: true,
      );

      if (result['success'] == true) {
        products.value = result['products'];
      } else {
        Get.snackbar('Error', result['message']);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCategories() async {
    try {
      final result = await _posService.getProductCategories();

      if (result['success'] == true) {
        categories.value = result['categories'];
      }
    } catch (e) {
      // Silent fail for categories
    }
  }

  void searchProducts(String query) {
    searchQuery.value = query;
    fetchProducts();
  }

  void filterByCategory(int? categoryId) {
    selectedCategoryId.value = categoryId;
    fetchProducts();
  }

  void addToCart(Product product, {int quantity = 1}) {
    final existingIndex = cartItems.indexWhere((item) => item.productId == product.id);

    if (existingIndex >= 0) {
      final existingItem = cartItems[existingIndex];
      final newQuantity = existingItem.quantity + quantity;
      
      if (newQuantity > product.stock) {
        Get.snackbar('Error', 'Insufficient stock');
        return;
      }

      final newSubtotal = product.price * newQuantity;
      cartItems[existingIndex] = TransactionItem(
        productId: product.id!,
        productName: product.name,
        price: product.price,
        quantity: newQuantity,
        subtotal: newSubtotal,
        total: newSubtotal,
      );
    } else {
      if (quantity > product.stock) {
        Get.snackbar('Error', 'Insufficient stock');
        return;
      }

      final itemSubtotal = product.price * quantity;
      cartItems.add(TransactionItem(
        productId: product.id!,
        productName: product.name,
        price: product.price,
        quantity: quantity,
        subtotal: itemSubtotal,
        total: itemSubtotal,
      ));
    }

    calculateTotals();
  }

  void updateCartItemQuantity(int index, int quantity) {
    if (index < 0 || index >= cartItems.length) return;

    final item = cartItems[index];
    final product = products.firstWhere((p) => p.id == item.productId);

    if (quantity > product.stock) {
      Get.snackbar('Error', 'Insufficient stock');
      return;
    }

    if (quantity <= 0) {
      removeFromCart(index);
      return;
    }

    final newSubtotal = item.price * quantity;
    cartItems[index] = TransactionItem(
      productId: item.productId,
      productName: item.productName,
      price: item.price,
      quantity: quantity,
      subtotal: newSubtotal,
      total: newSubtotal,
    );

    calculateTotals();
  }

  void removeFromCart(int index) {
    if (index >= 0 && index < cartItems.length) {
      cartItems.removeAt(index);
      calculateTotals();
    }
  }

  void clearCart() {
    cartItems.clear();
    discount.value = 0;
    tax.value = 0;
    calculateTotals();
  }

  void setDiscount(double value) {
    discount.value = value;
    calculateTotals();
  }

  void setTax(double value) {
    tax.value = value;
    calculateTotals();
  }

  void calculateTotals() {
    subtotal.value = cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
    total.value = subtotal.value - discount.value + tax.value;
  }

  Future<bool> processTransaction({
    required String paymentMethod,
    required double paidAmount,
    int? memberId,
    String? notes,
  }) async {
    if (cartItems.isEmpty) {
      Get.snackbar('Error', 'Cart is empty');
      return false;
    }

    if (paidAmount < total.value) {
      Get.snackbar('Error', 'Insufficient payment amount');
      return false;
    }

    isLoading.value = true;
    try {
      final transaction = Transaction(
        transactionNumber: 'TRX-${DateTime.now().millisecondsSinceEpoch}',
        type: 'sale',
        transactionDate: DateTime.now(),
        memberId: memberId,
        subtotal: subtotal.value,
        discount: discount.value,
        tax: tax.value,
        total: total.value,
        paymentMethod: paymentMethod,
        paidAmount: paidAmount,
        changeAmount: paidAmount - total.value,
        notes: notes,
        items: cartItems,
      );

      final result = await _posService.createTransaction(transaction);

      if (result['success'] == true) {
        Get.snackbar('Success', result['message']);
        clearCart();
        return true;
      } else {
        Get.snackbar('Error', result['message']);
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  int get cartItemCount => cartItems.length;
  int get totalItemQuantity => cartItems.fold(0, (sum, item) => sum + item.quantity);
}
