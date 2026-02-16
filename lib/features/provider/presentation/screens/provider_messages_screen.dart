import 'package:flutter/material.dart';
import 'package:petcare/app/theme/theme_extensions.dart';

class ProviderMessagesScreen extends StatelessWidget {
  const ProviderMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 64,
                color: context.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'Messages Coming Soon',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You will be able to chat with pet owners about bookings and services here.',
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

