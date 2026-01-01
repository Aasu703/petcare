import 'package:flutter/material.dart';
import 'package:petcare/features/bottomnavigation/presentation/pages/discover_screen.dart';
import 'package:petcare/features/bottomnavigation/presentation/pages/explore_screen.dart';
import 'package:petcare/features/bottomnavigation/presentation/pages/home_screen.dart';
import 'package:petcare/features/bottomnavigation/presentation/pages/profile_screen.dart';
import 'package:petcare/app/theme/app_colors.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  List<Widget> lstBottomScreen = [
    HomeScreen(),
    ProfileScreen(),
    ExploreScreen(),
    DiscoverScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PawCare"),
        centerTitle: true,
        backgroundColor: AppColors.iconPrimaryColor,
      ),
      body: lstBottomScreen[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_rounded),
            label: "Explore",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: "Discover",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person_4), label: "Profile"),
        ],
      ),
    );
  }
}
