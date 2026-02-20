import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/features/shop/data/datasource/remote/shop_remote_datasource.dart';
import 'package:petcare/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:petcare/features/shop/domain/repositories/shop_repository.dart';
import 'package:petcare/features/shop/domain/usecases/get_products_usecase.dart';
import 'package:petcare/features/shop/domain/usecases/create_order_usecase.dart';
import 'package:petcare/features/shop/domain/usecases/get_user_orders_usecase.dart';

// Repository
final shopRepositoryProvider = Provider<IShopRepository>((ref) {
  final remote = ref.read(shopRemoteDatasourceProvider);
  return ShopRepositoryImpl(remoteDataSource: remote);
});

// Usecases
final getProductsUsecaseProvider = Provider<GetProductsUsecase>((ref) {
  final repo = ref.read(shopRepositoryProvider);
  return GetProductsUsecase(repository: repo);
});

final createOrderUsecaseProvider = Provider<CreateOrderUsecase>((ref) {
  final repo = ref.read(shopRepositoryProvider);
  return CreateOrderUsecase(repository: repo);
});

final getUserOrdersUsecaseProvider = Provider<GetUserOrdersUsecase>((ref) {
  final repo = ref.read(shopRepositoryProvider);
  return GetUserOrdersUsecase(repository: repo);
});
