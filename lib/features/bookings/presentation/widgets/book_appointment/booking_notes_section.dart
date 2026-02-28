import 'package:flutter/material.dart';
import 'package:petcare/app/theme/theme_extensions.dart';

/// Optional notes section for booking form
class BookingNotesSection extends StatelessWidget {
  final TextEditingController notesController;

  const BookingNotesSection({super.key, required this.notesController});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes (optional)',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: notesController,
          maxLines: 3,
          style: TextStyle(color: context.textPrimary),
          decoration: InputDecoration(
            hintText: 'Any special instructions...',
            hintStyle: TextStyle(color: context.hintColor),
            filled: true,
            fillColor: context.surfaceColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
