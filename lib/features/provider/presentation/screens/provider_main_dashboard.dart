import 'package:flutter/material.dart';
import 'package:petcare/features/provider/presentation/screens/provider_dashboard_screen.dart';
import 'package:petcare/features/provider/presentation/screens/provider_profile_screen.dart';
import 'package:petcare/features/provider_service/presentation/pages/my_provider_services.dart';
import 'package:petcare/app/theme/theme_extensions.dart';

class ProviderDashboard extends StatefulWidget {
  const ProviderDashboard({super.key});

  @override
  State<ProviderDashboard> createState() => _ProviderDashboardState();
}

class _ProviderDashboardState extends State<ProviderDashboard> {
  int _selectedIndex = 0;

  List<Widget> get _screens => [
    const ProviderDashboardScreen(),
    const MyProviderServicesScreen(),
    ProviderProfileScreen(),
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(
      icon: Icons.dashboard_rounded,
      activeIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    _NavItem(
      icon: Icons.medical_services_outlined,
      activeIcon: Icons.medical_services_rounded,
      label: 'Services',
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final primary = context.iconPrimaryColor;
    final surface = context.surfaceColor;
    final background = context.backgroundColor;
    final textSecondary = context.textSecondary;
    final navShadow = context.textPrimary.withValues(alpha: 0.08);

    return Scaffold(
      backgroundColor: background,
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              color: surface,
              boxShadow: [
                BoxShadow(
                  color: navShadow,
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: context.dividerColor.withValues(alpha: 0.25),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    _navItems.length,
                    (index) => _buildNavItem(index, primary, textSecondary),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, Color primary, Color textSecondary) {
    final isSelected = _selectedIndex == index;
    final item = _navItems[index];
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? primary.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? item.activeIcon : item.icon,
              color: isSelected ? primary : textSecondary,
              size: 20,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                item.label,
                style: TextStyle(
                  color: primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}
