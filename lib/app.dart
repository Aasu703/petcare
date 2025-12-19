import 'package:flutter/material.dart';
import 'package:petcare/Screens/Splash_screen.dart';
// import 'package:petcare/Screens/onboarding_screen.dart';
// import 'package:petcare/screens/dashboard.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PawCare',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const SplashScreen(),
    );
  }
}
