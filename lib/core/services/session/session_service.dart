import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  SessionService._internal();
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;

  static const String _keyUserId = 'current_user_id';
  static const String _keyFirstName = 'first_name';
  static const String _keyEmail = 'email';

  Future<SharedPreferences> _prefs() async => SharedPreferences.getInstance();

  Future<void> saveSession({
    required String userId,
    required String firstName,
    required String email,
  }) async {
    final p = await _prefs();
    await p.setString(_keyUserId, userId);
    await p.setString(_keyFirstName, firstName);
    await p.setString(_keyEmail, email);
  }

  Future<bool> isLoggedIn() async {
    final p = await _prefs();
    return p.containsKey(_keyUserId);
  }

  Future<String?> getUserId() async {
    final p = await _prefs();
    return p.getString(_keyUserId);
  }

  Future<String?> getFirstName() async {
    final p = await _prefs();
    return p.getString(_keyFirstName);
  }

  Future<String?> getEmail() async {
    final p = await _prefs();
    return p.getString(_keyEmail);
  }

  Future<void> clearSession() async {
    final p = await _prefs();
    await p.remove(_keyUserId);
    await p.remove(_keyFirstName);
    await p.remove(_keyEmail);
  }
}
