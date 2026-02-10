import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/features/splash/presentation/pages/Splash_screen.dart';
import 'package:petcare/app/theme/theme_data.dart';
import 'package:petcare/core/providers/theme_provider.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PawCare',
      theme: getLightTheme(),
      darkTheme: getDarkTheme(),
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}
