import 'package:petcare/features/shop/data/models/product_model.dart';

abstract interface class IShopRemoteDataSource {
  // Products / Inventory
  Future<List<ProductModel>> getProducts();
  Future<List<ProductModel>> getProviderInventory(String providerId);
  Future<ProductModel?> getProductById(String productId);
  Future<ProductModel> createProduct(ProductModel product);
  Future<ProductModel> updateProduct(String productId, ProductModel product);
  Future<bool> deleteProduct(String productId);

  // Cart
  Future<Map<String, dynamic>> getCart();
  Future<Map<String, dynamic>> addToCart(String productId, int quantity);
  Future<Map<String, dynamic>> updateCartItem(String itemId, int quantity);
  Future<Map<String, dynamic>> removeCartItem(String itemId);
  Future<Map<String, dynamic>> updateCart(Map<String, dynamic> cartData);
  Future<void> clearCart();

  // Orders
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData);
  Future<List<Map<String, dynamic>>> getUserOrders();
  Future<Map<String, dynamic>?> getOrderById(String orderId);
  Future<List<Map<String, dynamic>>> getProviderOrders();
  Future<Map<String, dynamic>?> updateProviderOrderStatus(
    String orderId,
    String status,
  );
}
