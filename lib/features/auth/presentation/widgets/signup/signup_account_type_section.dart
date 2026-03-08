import 'package:flutter/material.dart';
import 'package:petcare/app/l10n/app_localizations.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/features/auth/presentation/widgets/account_type_chip.dart';

/// Account type selector section with animated chips
/// Allows users to choose between Pet Owner and Provider accounts
class SignupAccountTypeSection extends StatelessWidget {
  final bool isProvider;
  final ValueChanged<bool> onAccountTypeChanged;

  const SignupAccountTypeSection({
    super.key,
    required this.isProvider,
    required this.onAccountTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentColor.withValues(alpha: 0.08),
            AppColors.accentColor.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accentColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.badge_outlined,
                  size: 20,
                  color: AppColors.accentColor,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context).tr('accountType'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Account type chips
          Row(
            children: [
              Expanded(
                child: AccountTypeChip(
                  label: AppLocalizations.of(context).tr('petOwner'),
                  icon: Icons.pets,
                  selected: !isProvider,
                  onTap: () => onAccountTypeChanged(false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AccountTypeChip(
                  label: AppLocalizations.of(context).tr('provider'),
                  icon: Icons.store_rounded,
                  selected: isProvider,
                  onTap: () => onAccountTypeChanged(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
