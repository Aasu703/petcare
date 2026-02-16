import 'package:flutter/material.dart';

class ManageInventoryWidget extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const ManageInventoryWidget({super.key, this.items = const []});

  @override
  Widget build(BuildContext context) {
    return items.isEmpty
        ? const Center(child: Text('No inventory'))
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final p = items[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.inventory),
                  title: Text(p['name'] ?? 'Item'),
                  subtitle: Text('Qty: ${p['qty'] ?? 0}'),
                ),
              );
            },
          );
  }
}
