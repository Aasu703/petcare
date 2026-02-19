import 'package:flutter/material.dart';
import 'package:petcare/app/theme/theme_extensions.dart';

class MyPetEmptyState extends StatelessWidget {
  const MyPetEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(40),
      children: [
        const SizedBox(height: 80),
        Icon(
          Icons.pets,
          size: 120,
          color: context.textSecondary.withValues(alpha: 0.3),
        ),
        const SizedBox(height: 24),
        Text(
          'No Pets Yet',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Start adding your beloved pets to keep track of their information and care.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: context.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
