import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/app/routes/app_router.dart';
import 'package:petcare/app/theme/app_theme.dart';
import 'package:petcare/app/theme/theme_provider.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'PawCare',
      theme: getLightTheme(),
      darkTheme: getDarkTheme(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
