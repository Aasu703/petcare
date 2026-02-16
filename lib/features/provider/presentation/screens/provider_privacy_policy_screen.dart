import 'package:flutter/material.dart';
import 'package:petcare/app/theme/theme_extensions.dart';

class ProviderPrivacyPolicyScreen extends StatelessWidget {
  const ProviderPrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Provider Privacy Policy',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This is a placeholder for your provider privacy policy. '
              'You can describe how you handle customer data, bookings, payments, and communications.',
              style: TextStyle(
                fontSize: 14,
                color: context.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Key sections you might include:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _buildBullet(context, 'What information you collect about pet owners.'),
            _buildBullet(context, 'How booking and medical information is stored.'),
            _buildBullet(context, 'How long data is retained and how it can be deleted.'),
            _buildBullet(context, 'Contact details for privacy-related questions.'),
          ],
        ),
      ),
    );
  }

  Widget _buildBullet(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: context.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

