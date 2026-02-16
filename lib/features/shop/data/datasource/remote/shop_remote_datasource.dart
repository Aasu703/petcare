import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/api/api_client.dart';
import 'package:petcare/core/api/api_endpoints.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';
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
}

final shopRemoteDatasourceProvider = Provider<IShopRemoteDataSource>((ref) {
  return ShopRemoteDataSource(
    apiClient: ref.read(apiClientProvider),
    sessionService: ref.read(userSessionServiceProvider),
  );
});

class ShopRemoteDataSource implements IShopRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _sessionService;

  ShopRemoteDataSource({
    required ApiClient apiClient,
    required UserSessionService sessionService,
  }) : _apiClient = apiClient,
       _sessionService = sessionService;

  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await _apiClient.get(ApiEndpoints.products);
    final data = response.data;
    List<dynamic> list = [];
    if (data is Map<String, dynamic>) {
      final inner = data['data'];
      if (inner is List) {
        list = inner;
      } else if (inner is Map<String, dynamic>) {
        list = inner['items'] ?? [];
      }
    } else if (data is List) {
      list = data;
    }
    return list
        .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ProductModel>> getProviderInventory(String providerId) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.inventoryByProvider}/$providerId',
    );
    final data = response.data;
    List<dynamic> list = [];
    if (data is Map<String, dynamic>) {
      list = data['data'] ?? [];
    } else if (data is List) {
      list = data;
    }
    return list
        .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ProductModel?> getProductById(String productId) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.inventoryById}/$productId',
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final inner = data['data'] ?? data;
      if (inner is Map<String, dynamic>) {
        return ProductModel.fromJson(inner);
      }
    }
    return null;
  }

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    final response = await _apiClient.post(
      ApiEndpoints.inventoryCreate,
      data: product.toJson(),
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final inner = data['data'] ?? data;
      if (inner is Map<String, dynamic>) {
        return ProductModel.fromJson(inner);
      }
    }
    return product;
  }

  @override
  Future<ProductModel> updateProduct(
    String productId,
    ProductModel product,
  ) async {
    final response = await _apiClient.put(
      '${ApiEndpoints.inventoryUpdate}/$productId',
      data: product.toJson(),
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final inner = data['data'] ?? data;
      if (inner is Map<String, dynamic>) {
        return ProductModel.fromJson(inner);
      }
    }
    return product;
  }

  @override
  Future<bool> deleteProduct(String productId) async {
    final response = await _apiClient.delete(
      '${ApiEndpoints.inventoryDelete}/$productId',
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data['success'] == true;
    }
    return false;
  }

  // Cart methods
  @override
  Future<Map<String, dynamic>> getCart() async {
    if (!_sessionService.isLoggedIn()) {
      throw Exception('User not authenticated');
    }
    final response = await _apiClient.get(ApiEndpoints.cartGet);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data['data'] ?? data;
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> addToCart(String productId, int quantity) async {
    if (!_sessionService.isLoggedIn()) {
      throw Exception('User not authenticated');
    }
    final response = await _apiClient.post(
      ApiEndpoints.cartAdd,
      data: {'productId': productId, 'quantity': quantity},
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data['data'] ?? data;
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> updateCartItem(
    String itemId,
    int quantity,
  ) async {
    if (!_sessionService.isLoggedIn()) {
      throw Exception('User not authenticated');
    }
    final response = await _apiClient.put(
      '${ApiEndpoints.cartUpdateItem}/$itemId',
      data: {'quantity': quantity},
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data['data'] ?? data;
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> removeCartItem(String itemId) async {
    if (!_sessionService.isLoggedIn()) {
      throw Exception('User not authenticated');
    }
    final response = await _apiClient.delete(
      '${ApiEndpoints.cartRemoveItem}/$itemId',
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data['data'] ?? data;
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> updateCart(Map<String, dynamic> cartData) async {
    if (!_sessionService.isLoggedIn()) {
      throw Exception('User not authenticated');
    }
    final response = await _apiClient.put(
      ApiEndpoints.cartUpdate,
      data: cartData,
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data['data'] ?? data;
    }
    return {};
  }

  @override
  Future<void> clearCart() async {
    if (!_sessionService.isLoggedIn()) {
      throw Exception('User not authenticated');
    }
    await _apiClient.delete(ApiEndpoints.cartClear);
  }

  @override
  Future<Map<String, dynamic>> createOrder(
    Map<String, dynamic> orderData,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.orderCreate,
      data: orderData,
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data['data'] ?? data;
    }
    return {};
  }

  @override
  Future<List<Map<String, dynamic>>> getUserOrders() async {
    final response = await _apiClient.get(ApiEndpoints.orderMy);
    final data = response.data;
    List<dynamic> list = [];
    if (data is Map<String, dynamic>) {
      list = data['data'] ?? data['orders'] ?? [];
    } else if (data is List) {
      list = data;
    }
    return list.cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>?> getOrderById(String orderId) async {
    final response = await _apiClient.get('${ApiEndpoints.orderById}/$orderId');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data['data'] ?? data;
    }
    return null;
  }
}
