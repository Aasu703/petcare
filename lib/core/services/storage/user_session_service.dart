import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/providers/shared_prefs_provider.dart';

// UserSessionService to manage user session data
final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  final prefs = ref.read(sharedPrefsProvider);
  return UserSessionService(prefs: prefs);
});

class UserSessionService {
  final SharedPreferences _prefs;

  // keys for storing session data
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userIdKey = 'user_id';
  static const String _firstNameKey = 'first_name';
  static const String _emailKey = 'email';
  static const String _lastNameKey = 'last_name';
  static const String _phoneKey = 'phone';
  static const String _userProfilePicKey = 'profile_pic';
  static const String _roleKey = 'role';
  static const String _providerTypeKey = 'provider_type';
  static const String _providerStatusKey = 'provider_status';

  // Sensor settings keys
  static const String _proximityAlertEnabledKey = 'proximity_alert_enabled';
  static const String _autoBrightnessEnabledKey = 'auto_brightness_enabled';
  static const String _proximityThresholdKey = 'proximity_threshold';

  UserSessionService({required SharedPreferences prefs}) : _prefs = prefs;

  // Save user session data
  Future<void> saveSession({
    required String userId,
    required String firstName,
    required String email,
    required String lastName,
    String? phone,
    String? userProfilePic,
    String? role,
    String? providerType,
    String? providerStatus,
  }) async {
    await _prefs.setBool(_isLoggedInKey, true);
    await _prefs.setString(_userIdKey, userId);
    await _prefs.setString(_firstNameKey, firstName);
    await _prefs.setString(_emailKey, email);
    await _prefs.setString(_lastNameKey, lastName);
    if (phone != null) {
      await _prefs.setString(_phoneKey, phone);
    }
    if (userProfilePic != null) {
      await _prefs.setString(_userProfilePicKey, userProfilePic);
    }
    if (role != null) {
      await _prefs.setString(_roleKey, role);
    }
    if (providerType != null) {
      await _prefs.setString(_providerTypeKey, providerType);
    }
    if (providerStatus != null) {
      await _prefs.setString(_providerStatusKey, providerStatus);
    }
  }

  // check if user is logged in
  bool isLoggedIn() {
    return _prefs.getBool(_isLoggedInKey) ?? false;
  }

  // get current user ID
  String? getUserId() {
    return _prefs.getString(_userIdKey);
  }

  // get current user email
  String? getEmail() {
    return _prefs.getString(_emailKey);
  }

  // get current user first name
  String? getFirstName() {
    return _prefs.getString(_firstNameKey);
  }

  // get current user last name
  String? getLastName() {
    return _prefs.getString(_lastNameKey);
  }

  // get current user phone
  String? getPhone() {
    return _prefs.getString(_phoneKey);
  }

  // get current user profile picture
  String? getUserProfilePic() {
    return _prefs.getString(_userProfilePicKey);
  }

  // get current user role
  String? getRole() {
    return _prefs.getString(_roleKey);
  }

  // get current provider type (shop, vet, babysitter)
  String? getProviderType() {
    return _prefs.getString(_providerTypeKey);
  }

  String? getProviderStatus() {
    return _prefs.getString(_providerStatusKey);
  }

  // Sensor settings methods
  bool isProximitySensorEnabled() {
    return _prefs.getBool(_proximityAlertEnabledKey) ?? true;
  }

  Future<void> setProximitySensorEnabled(bool enabled) async {
    await _prefs.setBool(_proximityAlertEnabledKey, enabled);
  }

  bool isAutoBrightnessEnabled() {
    return _prefs.getBool(_autoBrightnessEnabledKey) ?? true;
  }

  Future<void> setAutoBrightnessEnabled(bool enabled) async {
    await _prefs.setBool(_autoBrightnessEnabledKey, enabled);
  }

  int getProximityThreshold() {
    return _prefs.getInt(_proximityThresholdKey) ?? 5;
  }

  Future<void> setProximityThreshold(int threshold) async {
    await _prefs.setInt(_proximityThresholdKey, threshold);
  }

  // Clear user session data
  Future<void> clearSession() async {
    await _prefs.remove(_isLoggedInKey);
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_firstNameKey);
    await _prefs.remove(_emailKey);
    await _prefs.remove(_lastNameKey);
    await _prefs.remove(_phoneKey);
    await _prefs.remove(_userProfilePicKey);
    await _prefs.remove(_roleKey);
    await _prefs.remove(_providerTypeKey);
    await _prefs.remove(_providerStatusKey);
  }
}
