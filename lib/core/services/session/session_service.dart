import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _keyUserId = 'userId';
  static const String _keyFirstName = 'firstName';
  static const String _keyEmail = 'email';
  static const String _keyToken = 'token'; // JWT token
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyRole = 'role';

  final SharedPreferences _prefs;

  SessionService(this._prefs);

  // Save session (including token)
  Future<void> saveSession({
    required String userId,
    required String firstName,
    required String email,
    String? token,
    String? role,
  }) async {
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyFirstName, firstName);
    await _prefs.setString(_keyEmail, email);
    if (token != null) {
      await _prefs.setString(_keyToken, token);
    }
    if (role != null) {
      await _prefs.setString(_keyRole, role);
    }
    await _prefs.setBool(_keyIsLoggedIn, true);
  }

  // Get token - SYNCHRONOUS (SharedPreferences is already loaded)
  String? getToken() {
    return _prefs.getString(_keyToken);
  }

  // Get user ID
  String? getUserId() {
    return _prefs.getString(_keyUserId);
  }

  // Get first name
  String? getFirstName() {
    return _prefs.getString(_keyFirstName);
  }

  // Get email
  String? getEmail() {
    return _prefs.getString(_keyEmail);
  }

  // Get role
  String? getRole() {
    return _prefs.getString(_keyRole);
  }

  // Check if logged in
  bool isLoggedIn() {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Clear session (logout)
  Future<void> clearSession() async {
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyFirstName);
    await _prefs.remove(_keyEmail);
    await _prefs.remove(_keyToken);
    await _prefs.remove(_keyRole);
    await _prefs.setBool(_keyIsLoggedIn, false);
  }
}
