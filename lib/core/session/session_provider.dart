import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/providers/shared_prefs_provider.dart';
import 'package:petcare/core/services/storage/token_service.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';
import 'package:petcare/core/session/session_state.dart';

/// Central session provider — the single source of truth for auth state.
///
/// All routing guards and UI that depend on login / role should watch this.
final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(
  SessionNotifier.new,
);

class SessionNotifier extends Notifier<SessionState> {
  late final UserSessionService _sessionService;

  @override
  SessionState build() {
    _sessionService = UserSessionService(prefs: ref.read(sharedPrefsProvider));
    return _hydrateFromDisk();
  }

  /// Reads SharedPreferences synchronously and returns a SessionState.
  SessionState _hydrateFromDisk() {
    return SessionState(
      isLoggedIn: _sessionService.isLoggedIn(),
      userId: _sessionService.getUserId(),
      firstName: _sessionService.getFirstName(),
      lastName: _sessionService.getLastName(),
      email: _sessionService.getEmail(),
      role: _sessionService.getRole(),
      providerType: _sessionService.getProviderType(),
      profilePic: _sessionService.getUserProfilePic(),
    );
  }

  /// Call after a successful login / registration.
  Future<void> setSession({
    required String userId,
    required String firstName,
    required String email,
    String? lastName,
    String? role,
    String? providerType,
    String? profilePic,
  }) async {
    await _sessionService.saveSession(
      userId: userId,
      firstName: firstName,
      email: email,
      lastName: lastName ?? '',
      role: role,
      providerType: providerType,
      userProfilePic: profilePic,
    );
    state = _hydrateFromDisk();
  }

  /// Call on logout — clears everything and resets state.
  Future<void> clearSession() async {
    await _sessionService.clearSession();
    // Also clear auth token
    final tokenService = TokenService(prefs: ref.read(sharedPrefsProvider));
    await tokenService.deleteToken();
    state = const SessionState();
  }

  /// Re-read from disk (e.g. after profile update).
  void refresh() {
    state = _hydrateFromDisk();
  }
}
