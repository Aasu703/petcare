import 'package:flutter/material.dart';
import 'package:petcare/app/theme/app_colors.dart';

/// Signup action button with loading state
/// Displays "Continue to Provider Signup" for providers, "Create Account" for pet owners
class SignupActionsSection extends StatelessWidget {
  final bool isSubmitting;
  final bool isProvider;
  final VoidCallback onSignupPressed;

  const SignupActionsSection({
    super.key,
    required this.isSubmitting,
    required this.isProvider,
    required this.onSignupPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : onSignupPressed,
        style:
            ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: AppColors.accentColor.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ).copyWith(
              elevation: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.pressed)) {
                  return 0;
                }
                return 8;
              }),
            ),
        child: isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isProvider
                        ? 'Continue to Provider Signup'
                        : 'Create Account',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 22,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ],
              ),
      ),
    );
  }
}
