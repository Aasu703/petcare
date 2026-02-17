import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/app/theme/theme_extensions.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';
import 'package:petcare/features/provider/presentation/screens/provider_dashboard_screen.dart';
import 'package:petcare/features/provider/presentation/screens/provider_profile_screen.dart';
import 'package:petcare/features/provider_service/presentation/pages/my_provider_services.dart';
import 'package:petcare/features/shop/presentation/pages/manage_inventory_page.dart';

class ProviderDashboard extends ConsumerStatefulWidget {
  const ProviderDashboard({super.key});

  @override
  ConsumerState<ProviderDashboard> createState() => _ProviderDashboardState();
}

class _ProviderDashboardState extends ConsumerState<ProviderDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(userSessionServiceProvider);
    final providerType = (session.getProviderType() ?? '').toLowerCase();
    final isShop = providerType == 'shop';

    final screens = [
      const ProviderDashboardScreen(),
      isShop ? const ManageInventoryPage() : const MyProviderServicesScreen(),
      ProviderProfileScreen(),
    ];

    final navItems = [
      const _NavItem(
        icon: Icons.dashboard_rounded,
        activeIcon: Icons.dashboard_rounded,
        label: 'Dashboard',
      ),
      _NavItem(
        icon: isShop ? Icons.inventory_2_outlined : Icons.medical_services_outlined,
        activeIcon:
            isShop ? Icons.inventory_2 : Icons.medical_services_rounded,
        label: isShop ? 'Inventory' : 'Services',
      ),
      const _NavItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'Profile',
      ),
    ];

    final primary = context.iconPrimaryColor;
    final surface = context.surfaceColor;
    final background = context.backgroundColor;
    final textSecondary = context.textSecondary;
    final navShadow = context.textPrimary.withValues(alpha: 0.08);

    return Scaffold(
      backgroundColor: background,
      body: IndexedStack(index: _selectedIndex, children: screens),
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
                    navItems.length,
                    (index) => _buildNavItem(
                      index,
                      navItems,
                      primary,
                      textSecondary,
                    ),
                  ),
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    List<_NavItem> navItems,
    Color primary,
    Color textSecondary,
  ) {
    final isSelected = _selectedIndex == index;
    final item = navItems[index];
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
