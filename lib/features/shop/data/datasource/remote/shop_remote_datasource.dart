import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/api/api_client.dart';
import 'package:petcare/core/api/api_endpoints.dart';
import 'package:petcare/features/shop/data/models/product_model.dart';

abstract interface class IShopRemoteDataSource {
  // Products / Inventory
  Future<List<ProductModel>> getProviderInventory(String providerId);
  Future<ProductModel?> getProductById(String productId);
  Future<ProductModel> createProduct(ProductModel product);
  Future<ProductModel> updateProduct(String productId, ProductModel product);
  Future<bool> deleteProduct(String productId);

  // Orders
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData);
  Future<List<Map<String, dynamic>>> getUserOrders();
  Future<Map<String, dynamic>?> getOrderById(String orderId);
}

final shopRemoteDatasourceProvider = Provider<IShopRemoteDataSource>((ref) {
  return ShopRemoteDataSource(apiClient: ref.read(apiClientProvider));
});

class ShopRemoteDataSource implements IShopRemoteDataSource {
  final ApiClient _apiClient;

  ShopRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

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
