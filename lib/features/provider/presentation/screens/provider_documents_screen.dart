import 'package:flutter/material.dart';
import 'package:petcare/app/theme/theme_extensions.dart';

class ProviderDocumentsScreen extends StatelessWidget {
  const ProviderDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Documents'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.description_rounded,
                size: 64,
                color: context.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'Documents Management Coming Soon',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload and manage licenses, certificates and compliance documents for your business here.',
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

