import 'package:flutter/material.dart';
import 'package:petcare/Screens/Splash_screen.dart';
import 'package:petcare/theme/theme_data.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PawCare',
      theme: getApplicationTheme(),
      home: const SplashScreen(),
    );
  }
}
