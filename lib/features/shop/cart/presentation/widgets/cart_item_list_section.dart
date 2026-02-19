import 'package:flutter/material.dart';
import 'package:petcare/app/theme/theme_extensions.dart';
import 'package:petcare/features/shop/cart/presentation/widgets/cart_item_tile.dart';
import 'package:petcare/features/shop/domain/entities/cart_entity.dart';

class CartItemListSection extends StatelessWidget {
  final List<CartItemEntity> items;
  final ValueChanged<CartItemEntity> onIncrement;
  final ValueChanged<CartItemEntity> onDecrement;
  final ValueChanged<CartItemEntity> onRemove;

  const CartItemListSection({
    super.key,
    required this.items,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => Divider(color: context.borderColor),
      itemBuilder: (context, index) {
        final item = items[index];
        return CartItemTile(
          item: item,
          onIncrement: () => onIncrement(item),
          onDecrement: () => onDecrement(item),
          onRemove: () => onRemove(item),
        );
      },
    );
  }
}
