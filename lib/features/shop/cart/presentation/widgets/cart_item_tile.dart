import 'package:flutter/material.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/app/theme/theme_extensions.dart';
import 'package:petcare/features/shop/domain/entities/cart_entity.dart';

class CartItemTile extends StatelessWidget {
  final CartItemEntity item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.iconPrimaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.inventory_2_rounded,
              color: AppColors.iconPrimaryColor.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.successColor,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _QuantityButton(icon: Icons.remove, onTap: onDecrement),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '${item.quantity}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: context.textPrimary,
                  ),
                ),
              ),
              _QuantityButton(icon: Icons.add, onTap: onIncrement),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
                color: Colors.red.shade400,
                tooltip: 'Remove item',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: context.borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: context.textPrimary),
      ),
    );
  }
}
