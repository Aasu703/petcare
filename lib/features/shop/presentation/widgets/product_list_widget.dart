import 'package:flutter/material.dart';

class ProductListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  const ProductListWidget({super.key, this.products = const []});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Center(child: Text('No products yet'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final p = products[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Icon(Icons.storefront, size: 48)),
                const SizedBox(height: 8),
                Text(
                  p['name'] ?? 'Product',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(p['price'] != null ? '\$${p['price']}' : ''),
              ],
            ),
          ),
        );
      },
    );
  }
}
