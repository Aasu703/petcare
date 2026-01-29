import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Simple auth state
class AuthState {
  final String? token;
  final bool isAuthenticated;

  AuthState({this.token, this.isAuthenticated = false});
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final SharedPreferences _prefs;

  AuthNotifier(this._prefs) : super(AuthState()) {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final token = _prefs.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      state = AuthState(token: token, isAuthenticated: true);
    }
  }

  Future<void> setToken(String token) async {
    await _prefs.setString('auth_token', token);
    state = AuthState(token: token, isAuthenticated: true);
  }

  Future<void> logout() async {
    await _prefs.remove('auth_token');
    state = AuthState();
  }
}

// Shared Preferences Provider for auth
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthNotifier(prefs);
});
