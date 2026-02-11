import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/features/shop/data/datasource/remote/shop_remote_datasource.dart';
import 'package:petcare/features/shop/data/models/product_model.dart';
import 'package:petcare/features/shop/domain/entities/order_entity.dart';
import 'package:petcare/features/shop/domain/entities/product_entity.dart';
import 'package:petcare/features/shop/domain/repositories/shop_repository.dart';

class ShopRepositoryImpl implements IShopRepository {
  final IShopRemoteDataSource _remoteDataSource;

  ShopRepositoryImpl({required IShopRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // For now, inventory is provider-scoped. This loads all.
      // Can be expanded when a public product listing endpoint is added.
      final models = await _remoteDataSource.getProviderInventory('');
      return Right(ProductModel.toEntityList(models));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(
    String productId,
  ) async {
    try {
      final model = await _remoteDataSource.getProductById(productId);
      if (model == null) {
        return const Left(ServerFailure(message: 'Product not found'));
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProviderInventory(
    String providerId,
  ) async {
    try {
      final models = await _remoteDataSource.getProviderInventory(providerId);
      return Right(ProductModel.toEntityList(models));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> createProduct(
    ProductEntity product,
  ) async {
    try {
      final model = ProductModel.fromEntity(product);
      final result = await _remoteDataSource.createProduct(model);
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> updateProduct(
    ProductEntity product,
  ) async {
    try {
      final model = ProductModel.fromEntity(product);
      final result = await _remoteDataSource.updateProduct(
        product.productId ?? '',
        model,
      );
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteProduct(String productId) async {
    try {
      final result = await _remoteDataSource.deleteProduct(productId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> createOrder(OrderEntity order) async {
    try {
      final orderData = {
        'items': order.items
            .map(
              (item) => {
                'productId': item.productId,
                'productName': item.productName,
                'quantity': item.quantity,
                'price': item.price,
              },
            )
            .toList(),
        'totalAmount': order.totalAmount,
        if (order.shippingAddress != null)
          'shippingAddress': order.shippingAddress,
        if (order.notes != null) 'notes': order.notes,
      };
      final result = await _remoteDataSource.createOrder(orderData);
      // Parse result back to entity
      return Right(
        OrderEntity(
          orderId: (result['_id'] ?? result['id'])?.toString(),
          userId: result['userId']?.toString(),
          items: order.items,
          totalAmount: order.totalAmount,
          status: result['status']?.toString() ?? 'pending',
          createdAt: result['createdAt']?.toString(),
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getUserOrders() async {
    try {
      final results = await _remoteDataSource.getUserOrders();
      final orders = results.map((json) {
        final items = (json['items'] as List? ?? []).map((item) {
          final itemMap = item as Map<String, dynamic>;
          return OrderItemEntity(
            productId: itemMap['productId']?.toString() ?? '',
            productName: itemMap['productName']?.toString() ?? '',
            quantity: (itemMap['quantity'] as num?)?.toInt() ?? 0,
            price: (itemMap['price'] as num?)?.toDouble() ?? 0,
          );
        }).toList();
        return OrderEntity(
          orderId: (json['_id'] ?? json['id'])?.toString(),
          userId: json['userId']?.toString(),
          items: items,
          totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
          status: json['status']?.toString() ?? 'pending',
          shippingAddress: json['shippingAddress']?.toString(),
          notes: json['notes']?.toString(),
          createdAt: json['createdAt']?.toString(),
        );
      }).toList();
      return Right(orders);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId) async {
    try {
      final json = await _remoteDataSource.getOrderById(orderId);
      if (json == null) {
        return const Left(ServerFailure(message: 'Order not found'));
      }
      final items = (json['items'] as List? ?? []).map((item) {
        final itemMap = item as Map<String, dynamic>;
        return OrderItemEntity(
          productId: itemMap['productId']?.toString() ?? '',
          productName: itemMap['productName']?.toString() ?? '',
          quantity: (itemMap['quantity'] as num?)?.toInt() ?? 0,
          price: (itemMap['price'] as num?)?.toDouble() ?? 0,
        );
      }).toList();
      return Right(
        OrderEntity(
          orderId: (json['_id'] ?? json['id'])?.toString(),
          userId: json['userId']?.toString(),
          items: items,
          totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
          status: json['status']?.toString() ?? 'pending',
          shippingAddress: json['shippingAddress']?.toString(),
          notes: json['notes']?.toString(),
          createdAt: json['createdAt']?.toString(),
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
