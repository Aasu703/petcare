import 'package:flutter/material.dart';
import 'package:petcare/app/l10n/app_localizations.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tr('forgotPasswordTitle'))),
      body: Center(child: Text(l10n.tr('forgotPasswordTitle'))),
    );
  }
}
