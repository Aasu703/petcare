import 'package:petcare/features/shop/domain/entities/cart_entity.dart';
import 'package:petcare/features/shop/data/models/product_model.dart';

/// CartModel is a local-only structure (not sent to backend).
/// Orders are created from CartEntity data when the user checks out.
class CartModel {
  final List<CartItemModel> items;

  CartModel({this.items = const []});

  CartEntity toEntity() {
    return CartEntity(items: items.map((item) => item.toEntity()).toList());
  }
}

class CartItemModel {
  final ProductModel product;
  final int quantity;

  CartItemModel({required this.product, this.quantity = 1});

  CartItemEntity toEntity() {
    return CartItemEntity(product: product.toEntity(), quantity: quantity);
  }
}
