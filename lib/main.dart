import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/app/app.dart';
import 'package:petcare/app/bootstrap/app_bootstrap.dart';
import 'package:petcare/core/providers/shared_prefs_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bootstrap = await AppBootstrap.initialize();

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(bootstrap.sharedPreferences),
      ],
      child: const App(),
    ),
  );
}
