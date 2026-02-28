import 'package:flutter/material.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/app/theme/theme_extensions.dart';

class MyPetEmptyState extends StatefulWidget {
  const MyPetEmptyState({super.key});

  @override
  State<MyPetEmptyState> createState() => _MyPetEmptyStateState();
}

class _MyPetEmptyStateState extends State<MyPetEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      children: [
        const SizedBox(height: 40),
        FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                // Animated Icon Container
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor.withValues(alpha: 0.1),
                        AppColors.accentColor.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: AppColors.primaryColor.withValues(alpha: 0.15),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.pets,
                      size: 70,
                      color: AppColors.primaryColor.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Title
                Text(
                  'No Pets Yet',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                    fontSize: 26,
                  ),
                ),
                const SizedBox(height: 16),
                // Subtitle
                Text(
                  'Start adding your beloved pets to keep track of their information, health records, and care schedules.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: context.textSecondary,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),
                // Features List
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: context.borderColor.withValues(alpha: 0.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _FeatureItem(
                        icon: Icons.favorite_outline,
                        title: 'Health Tracking',
                        description: 'Monitor your pet\'s health and wellness',
                        color: AppColors.errorColor,
                      ),
                      const SizedBox(height: 16),
                      _FeatureItem(
                        icon: Icons.medical_information_outlined,
                        title: 'Medical Records',
                        description:
                            'Keep all checkups and vaccinations organized',
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(height: 16),
                      _FeatureItem(
                        icon: Icons.calendar_today,
                        title: 'Care Schedules',
                        description:
                            'Never miss important pet care appointments',
                        color: AppColors.accentColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.1),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Center(child: Icon(icon, color: color, size: 22)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: context.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
