import 'package:flutter/material.dart';

class SplashWidget extends StatelessWidget {
  const SplashWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/pawcare.png', width: 120, height: 120),
          const SizedBox(height: 12),
          Text('PawCare', style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    );
  }
}
