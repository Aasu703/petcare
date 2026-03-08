import 'package:flutter/material.dart';
import 'package:petcare/app/l10n/app_localizations.dart';

class EarningsDashboardWidget extends StatelessWidget {
  final String total;
  const EarningsDashboardWidget({super.key, this.total = '\$0.00'});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.tr('earnings'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: Text(l10n.tr('totalEarnings')),
              trailing: Text(
                total,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Earnings chart placeholder'),
        ],
      ),
    );
  }
}
