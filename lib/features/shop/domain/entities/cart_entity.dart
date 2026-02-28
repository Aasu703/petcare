import 'package:equatable/equatable.dart';
import 'package:petcare/features/shop/domain/entities/product_entity.dart';

class CartItemEntity extends Equatable {
  final ProductEntity product;
  final int quantity;

  const CartItemEntity({required this.product, this.quantity = 1});

  double get subtotal => (product.price ?? 0) * quantity;

  @override
  List<Object?> get props => [product, quantity];

  CartItemEntity copyWith({ProductEntity? product, int? quantity}) {
    return CartItemEntity(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartEntity extends Equatable {
  final List<CartItemEntity> items;

  const CartEntity({this.items = const []});

  double get totalAmount => items.fold(0.0, (sum, item) => sum + item.subtotal);

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [items];
}
