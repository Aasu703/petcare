import 'package:flutter/material.dart';
import 'package:petcare/app/l10n/app_localizations.dart';

class ManageInventoryWidget extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const ManageInventoryWidget({super.key, this.items = const []});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return items.isEmpty
        ? Center(child: Text(l10n.tr('noInventoryItems')))
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final p = items[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.inventory),
                  title: Text(p['name'] ?? 'Item'),
                  subtitle: Text('${l10n.tr('quantity')}: ${p['qty'] ?? 0}'),
                ),
              );
            },
          );
  }
}
