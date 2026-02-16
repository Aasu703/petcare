import 'package:flutter/material.dart';

class ProductDetailWidget extends StatelessWidget {
  final String name;
  final String? description;
  final double? price;

  const ProductDetailWidget({
    super.key,
    required this.name,
    this.description,
    this.price,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 220,
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(Icons.inventory_2_rounded, size: 80),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (price != null) ...[
            const SizedBox(height: 8),
            Text(
              '\$${price!.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (description != null) Text(description!),
        ],
      ),
    );
  }
}
