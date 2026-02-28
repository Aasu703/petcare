import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/providers/shared_prefs_provider.dart';
import 'package:petcare/features/bottomnavigation/presentation/pages/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  testWidgets('HomeScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
        child: const MaterialApp(home: HomeScreen(firstName: 'Aayush')),
      ),
    );

    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Hello, Aayush!'), findsOneWidget);
    expect(find.text('Ready to care for your pets?'), findsOneWidget);
    expect(find.text('My Pets'), findsOneWidget);
  });
}
