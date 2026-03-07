import 'package:flutter/material.dart';
import 'package:petcare/app/l10n/app_localizations.dart';

class OnboardingWidget extends StatelessWidget {
  const OnboardingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        const SizedBox(height: 24),
        Text(
          l10n.tr('welcomeToPawCare'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Text(l10n.tr('quickIntroPlaceholder')),
      ],
    );
  }
}
