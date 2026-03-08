import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare/app/l10n/app_localizations.dart';
import 'package:petcare/app/routes/route_paths.dart';
import 'package:petcare/app/theme/app_colors.dart';

/// Footer with login link for existing users
class SignupFooter extends StatelessWidget {
  const SignupFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context).tr('alreadyHaveAccount'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.black.withValues(alpha: 0.6),
              fontSize: 15,
            ),
          ),
          GestureDetector(
            onTap: () => context.push(RoutePaths.login),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.accentColor, width: 2),
                ),
              ),
              child: Text(
                AppLocalizations.of(context).tr('signIn'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.accentColor,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
