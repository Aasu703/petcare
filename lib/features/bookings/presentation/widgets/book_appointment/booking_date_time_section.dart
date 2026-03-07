import 'package:flutter/material.dart';
import 'package:petcare/app/l10n/app_localizations.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/app/theme/theme_extensions.dart';

/// Booking section for date and time selection
class BookingDateTimeSection extends StatelessWidget {
  final String dateStr;
  final String timeStr;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;

  const BookingDateTimeSection({
    super.key,
    required this.dateStr,
    required this.timeStr,
    required this.onPickDate,
    required this.onPickTime,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.tr('selectDate'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onPickDate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              border: Border.all(color: context.borderColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: AppColors.iconPrimaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  dateStr,
                  style: TextStyle(fontSize: 16, color: context.textPrimary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.tr('selectTime'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onPickTime,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              border: Border.all(color: context.borderColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: AppColors.iconPrimaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  timeStr,
                  style: TextStyle(fontSize: 16, color: context.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
