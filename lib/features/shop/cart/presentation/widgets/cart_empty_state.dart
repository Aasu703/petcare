import 'package:flutter/material.dart';
import 'package:petcare/app/theme/theme_extensions.dart';

class CartEmptyState extends StatelessWidget {
  const CartEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: context.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            'Your cart is empty',
            style: TextStyle(fontSize: 16, color: context.textSecondary),
          ),
        ],
      ),
    );
  }
}
