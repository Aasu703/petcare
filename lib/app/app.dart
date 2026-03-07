import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/app/l10n/app_localizations.dart';
import 'package:petcare/app/l10n/locale_provider.dart';
import 'package:petcare/app/routes/app_router.dart';
import 'package:petcare/app/theme/app_theme.dart';
import 'package:petcare/app/theme/theme_provider.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(appLocaleProvider);
    final router = ref.watch(appRouterProvider);
    final l10n = AppLocalizations(locale);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: l10n.tr('appTitle'),
      theme: getLightTheme(),
      darkTheme: getDarkTheme(),
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
