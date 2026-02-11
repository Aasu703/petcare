import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/features/shop/domain/entities/product_entity.dart';
import 'package:petcare/features/shop/domain/entities/order_entity.dart';

abstract interface class IShopRepository {
  // Products
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    int page,
    int limit,
  });
  Future<Either<Failure, ProductEntity>> getProductById(String productId);

  // Inventory (Provider)
  Future<Either<Failure, List<ProductEntity>>> getProviderInventory(
    String providerId,
  );
  Future<Either<Failure, ProductEntity>> createProduct(ProductEntity product);
  Future<Either<Failure, ProductEntity>> updateProduct(ProductEntity product);
  Future<Either<Failure, bool>> deleteProduct(String productId);

  // Orders
  Future<Either<Failure, OrderEntity>> createOrder(OrderEntity order);
  Future<Either<Failure, List<OrderEntity>>> getUserOrders();
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId);
}
