import 'package:flutter/material.dart';
import 'package:petcare/features/bottomnavigation/presentation/pages/explore_screen.dart';
import 'package:petcare/features/bottomnavigation/presentation/pages/home_screen.dart';
import 'package:petcare/features/bottomnavigation/presentation/pages/profile_screen.dart';
import 'package:petcare/features/shop/presentation/pages/product_list_page.dart';
import 'package:petcare/app/theme/theme_extensions.dart';
import 'package:petcare/app/l10n/app_localizations.dart';

class Dashboard extends StatefulWidget {
  final String firstName;
  final String email;
  const Dashboard({super.key, this.firstName = 'User', this.email = ''});
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;
  List<Widget> get _screens => [
    HomeScreen(firstName: widget.firstName),
    const ExploreScreen(),
    const ProductListPage(),
    const ProfileScreen(),
  ];
  final List<_NavItem> _navItems = const [
    _NavItem(
      icon: Icons.home_rounded,
      activeIcon: Icons.home_rounded,
      labelKey: 'home',
    ),
    _NavItem(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
      labelKey: 'explore',
    ),
    _NavItem(
      icon: Icons.store_outlined,
      activeIcon: Icons.store_rounded,
      labelKey: 'shop',
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      labelKey: 'profile',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: context.surfaceColor.withOpacity(0.96),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: context.borderColor),
              boxShadow: [
                BoxShadow(
                  color: context.primaryColor.withOpacity(0.14),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                  spreadRadius: -12,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, _buildNavItem),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final l10n = AppLocalizations.of(context);
    final isSelected = _selectedIndex == index;
    final item = _navItems[index];
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [context.primaryColor, context.accentColor],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? item.activeIcon : item.icon,
              color: isSelected ? Colors.white : context.iconSecondaryColor,
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                l10n.tr(item.labelKey),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
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
  final IconData icon;
  final IconData activeIcon;
  final String labelKey;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.labelKey,
  });
}
