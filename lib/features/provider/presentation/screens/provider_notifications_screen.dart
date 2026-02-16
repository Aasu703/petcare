import 'package:flutter/material.dart';
import 'package:petcare/app/theme/theme_extensions.dart';

class ProviderNotificationsScreen extends StatelessWidget {
  const ProviderNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.notifications_active_outlined,
                size: 64,
                color: context.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'Notifications Coming Soon',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We\'ll show booking updates, reviews, and important alerts for your business here.',
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

