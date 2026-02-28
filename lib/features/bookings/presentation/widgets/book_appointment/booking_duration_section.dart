import 'package:flutter/material.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/app/theme/theme_extensions.dart';

/// Booking section for selecting appointment duration
class BookingDurationSection extends StatelessWidget {
  final int durationMinutes;
  final ValueChanged<int> onDurationChanged;

  const BookingDurationSection({
    super.key,
    required this.durationMinutes,
    required this.onDurationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [30, 60, 90, 120].map((minutes) {
            final isSelected = durationMinutes == minutes;
            return ChoiceChip(
              label: Text('$minutes min'),
              selected: isSelected,
              selectedColor: AppColors.iconPrimaryColor.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? context.textPrimary : context.textSecondary,
              ),
              backgroundColor: context.surfaceColor,
              onSelected: (_) => onDurationChanged(minutes),
            );
          }).toList(),
        ),
      ],
    );
  }
}
