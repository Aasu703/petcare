import 'package:flutter/material.dart';
import 'package:petcare/app/theme/theme_extensions.dart';

class ProviderHelpScreen extends StatelessWidget {
  const ProviderHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.help_center_rounded,
                size: 64,
                color: context.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'Help Center Coming Soon',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Browse FAQs or contact our support team for help with your provider account.',
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

