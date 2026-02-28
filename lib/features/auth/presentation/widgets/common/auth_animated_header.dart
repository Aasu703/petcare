import 'package:flutter/material.dart';
import 'package:petcare/app/theme/app_colors.dart';

/// Animated header icon with scale animation
/// Used in auth screens for visual appeal
class AuthAnimatedHeader extends StatelessWidget {
  final Animation<double> scaleAnimation;
  final IconData icon;
  final double size;

  const AuthAnimatedHeader({
    super.key,
    required this.scaleAnimation,
    this.icon = Icons.pets,
    this.size = 90,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.accentColor,
                AppColors.accentColor.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(size * 0.31), // 28/90 ≈ 0.31
            boxShadow: [
              BoxShadow(
                color: AppColors.accentColor.withValues(alpha: 0.4),
                blurRadius: 30,
                offset: const Offset(0, 15),
                spreadRadius: -5,
              ),
            ],
          ),
          child: Icon(icon, size: size * 0.5, color: Colors.white),
        ),
      ),
    );
  }
}
