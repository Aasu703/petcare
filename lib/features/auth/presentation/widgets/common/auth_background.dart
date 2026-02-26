import 'package:flutter/material.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/app/theme/theme_extensions.dart';

/// Animated gradient background with floating orbs
/// Used across all auth screens for consistent visual styling
class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animated gradient background
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.accentColor.withValues(alpha: 0.08),
                  context.backgroundColor,
                  context.accentColor.withValues(alpha: 0.05),
                ],
              ),
            ),
          ),
        ),

        // Floating orb - top right
        Positioned(
          right: -80,
          top: 100,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accentColor.withValues(alpha: 0.15),
                  AppColors.accentColor.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),

        // Floating orb - bottom left
        Positioned(
          left: -60,
          bottom: 150,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accentColor.withValues(alpha: 0.12),
                  AppColors.accentColor.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
