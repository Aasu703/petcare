import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare/app/theme/theme_extensions.dart';

class UserShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const UserShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: DecoratedBox(
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
            child: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              backgroundColor: Colors.transparent,
              indicatorColor: context.primaryColor.withOpacity(0.14),
              elevation: 0,
              height: 70,
              onDestinationSelected: (index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore_rounded),
                  label: 'Explore',
                ),
                NavigationDestination(
                  icon: Icon(Icons.store_outlined),
                  selectedIcon: Icon(Icons.store_rounded),
                  label: 'Shop',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
