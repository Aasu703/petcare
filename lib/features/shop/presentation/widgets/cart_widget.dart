import 'package:flutter/material.dart';

class CartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const CartWidget({super.key, this.items = const []});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const Center(child: Text('Your cart is empty'));
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final it = items[index];
        return ListTile(
          leading: const Icon(Icons.inventory_2_rounded),
          title: Text(it['name'] ?? 'Item'),
          subtitle: Text('\$${it['price'] ?? 0}'),
          trailing: Text('x${it['qty'] ?? 1}'),
        );
      },
    );
  }
}
