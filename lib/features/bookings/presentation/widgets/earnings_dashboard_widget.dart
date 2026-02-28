import 'package:flutter/material.dart';

class EarningsDashboardWidget extends StatelessWidget {
  final String total;
  const EarningsDashboardWidget({super.key, this.total = '\$0.00'});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Earnings', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Total Earnings'),
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
