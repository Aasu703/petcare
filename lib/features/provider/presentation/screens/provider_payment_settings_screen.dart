import 'package:flutter/material.dart';
import 'package:petcare/app/theme/theme_extensions.dart';

class ProviderPaymentSettingsScreen extends StatelessWidget {
  const ProviderPaymentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Settings'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.payment_rounded,
                size: 64,
                color: context.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'Payment Settings Coming Soon',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Configure payout methods, billing information and pricing preferences here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: context.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

