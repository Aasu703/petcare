import 'package:flutter/material.dart';

class OnboardingWidget extends StatelessWidget {
  const OnboardingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Text(
          'Welcome to PawCare',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        const Text('Quick intro slides placeholder'),
      ],
    );
  }
}
