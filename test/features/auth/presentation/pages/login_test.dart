import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/features/auth/presentation/pages/login.dart';

void main() {
  group('Login Page Widget Tests', () {
    // Helper function to pump the Login widget
    Future<void> _buildLoginPage(WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(child: MaterialApp(home: Login())));
      await tester.pumpAndSettle();
    }

    testWidgets('Email TextFormField is present', (WidgetTester tester) async {
      await _buildLoginPage(tester);

      final emailField = find.widgetWithText(TextFormField, 'Email Address');

      expect(emailField, findsOneWidget);
    });

    testWidgets('Password TextFormField is present', (
      WidgetTester tester,
    ) async {
      await _buildLoginPage(tester);

      final passwordField = find.widgetWithText(TextFormField, 'Password');

      expect(passwordField, findsOneWidget);
    });

    testWidgets('Sign In button is present', (WidgetTester tester) async {
      await _buildLoginPage(tester);

      final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');

      expect(signInButton, findsOneWidget);
    });

    testWidgets('Sign Up link is present', (WidgetTester tester) async {
      await _buildLoginPage(tester);

      final signUpLink = find.text('Sign Up');

      expect(signUpLink, findsOneWidget);
    });

    testWidgets('Provider login button is present', (
      WidgetTester tester,
    ) async {
      await _buildLoginPage(tester);

      final providerLoginButton = find.text('Login as Provider');

      expect(providerLoginButton, findsOneWidget);
    });
  });
}
