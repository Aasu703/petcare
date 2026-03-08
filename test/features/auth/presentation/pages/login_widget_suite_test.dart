import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/features/auth/presentation/pages/login.dart';

Future<void> _pumpLogin(WidgetTester tester) async {
  await tester.pumpWidget(
    const ProviderScope(child: MaterialApp(home: Login())),
  );
  await tester.pumpAndSettle();
}

TextFormField _emailField(WidgetTester tester) {
  return tester.widgetList<TextFormField>(find.byType(TextFormField)).first;
}

TextFormField _passwordField(WidgetTester tester) {
  return tester
      .widgetList<TextFormField>(find.byType(TextFormField))
      .elementAt(1);
}

TextField _passwordTextField(WidgetTester tester) {
  return tester.widgetList<TextField>(find.byType(TextField)).elementAt(1);
}

void main() {
  group('Login Widget Suite (20 tests)', () {
    testWidgets('1. renders Login page', (tester) async {
      await _pumpLogin(tester);
      expect(find.byType(Login), findsOneWidget);
    });

    testWidgets('2. shows app logo icon', (tester) async {
      await _pumpLogin(tester);
      expect(find.byIcon(Icons.pets), findsOneWidget);
    });

    testWidgets('3. shows welcome text', (tester) async {
      await _pumpLogin(tester);
      expect(find.text('Welcome Back'), findsOneWidget);
    });

    testWidgets('4. shows subtitle text', (tester) async {
      await _pumpLogin(tester);
      expect(
        find.textContaining(
          RegExp('continue\\s+to\\s+pawcare', caseSensitive: false),
        ),
        findsOneWidget,
      );
    });

    testWidgets('5. shows two text form fields', (tester) async {
      await _pumpLogin(tester);
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('6. shows email field label', (tester) async {
      await _pumpLogin(tester);
      expect(
        find.widgetWithText(TextFormField, 'Email Address'),
        findsOneWidget,
      );
    });

    testWidgets('7. shows password field label', (tester) async {
      await _pumpLogin(tester);
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    });

    testWidgets('8. shows forgot password action', (tester) async {
      await _pumpLogin(tester);
      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('9. shows sign in button', (tester) async {
      await _pumpLogin(tester);
      expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);
    });

    testWidgets('10. shows sign up action', (tester) async {
      await _pumpLogin(tester);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('11. shows provider login action', (tester) async {
      await _pumpLogin(tester);
      expect(find.text('Login as Provider'), findsOneWidget);
    });

    testWidgets('12. contains one form widget', (tester) async {
      await _pumpLogin(tester);
      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('13. contains one elevated button', (tester) async {
      await _pumpLogin(tester);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('14. email input accepts typed text', (tester) async {
      await _pumpLogin(tester);
      await tester.enterText(
        find.byType(TextFormField).first,
        'hello@example.com',
      );
      expect(find.text('hello@example.com'), findsOneWidget);
    });

    testWidgets('15. password input accepts typed text', (tester) async {
      await _pumpLogin(tester);
      await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
      expect(find.text('secret123'), findsOneWidget);
    });

    testWidgets('16. password field is obscured by default', (tester) async {
      await _pumpLogin(tester);
      expect(_passwordTextField(tester).obscureText, isTrue);
    });

    testWidgets('17. tapping eye icon toggles password visibility', (
      tester,
    ) async {
      await _pumpLogin(tester);
      expect(_passwordTextField(tester).obscureText, isTrue);

      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      expect(_passwordTextField(tester).obscureText, isFalse);
    });

    testWidgets('18. email validator rejects empty value', (tester) async {
      await _pumpLogin(tester);
      final email = _emailField(tester);
      expect(email.validator?.call(''), isNotNull);
    });

    testWidgets('19. email validator rejects invalid address', (tester) async {
      await _pumpLogin(tester);
      final email = _emailField(tester);
      expect(email.validator?.call('invalid-email'), isNotNull);
    });

    testWidgets('20. password validator accepts non-empty value', (
      tester,
    ) async {
      await _pumpLogin(tester);
      final password = _passwordField(tester);
      expect(password.validator?.call('mypassword'), isNull);
    });
  });
}
