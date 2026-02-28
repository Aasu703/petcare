import 'package:flutter/material.dart';
import 'package:petcare/app/theme/app_colors.dart';

/// Submit button for booking confirmation
class BookingSubmitButton extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const BookingSubmitButton({
    super.key,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.iconPrimaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isSubmitting
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Confirm Booking',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
