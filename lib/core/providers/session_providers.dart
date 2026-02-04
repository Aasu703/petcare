import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:petcare/core/providers/shared_prefs_provider.dart';
import 'package:petcare/core/services/session/session_service.dart';

class SessionState {
  final bool isLoggedIn;
  final String? userId;
  final String? firstName;
  final String? email;
  final String? Lastname;
  final String? role;

  const SessionState({
    required this.isLoggedIn,
    this.userId,
    this.firstName,
    this.email,
    this.Lastname,
    this.role,
  });

  SessionState copyWith({
    bool? isLoggedIn,
    String? userId,
    String? firstName,
    String? email,
    String? role,
  }) {
    return SessionState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }

  static const initial = SessionState(isLoggedIn: false);
}

final sessionServiceProvider = Provider<SessionService>((ref) {
  final prefs = ref.read(sharedPrefsProvider);
  return SessionService(prefs);
});

final sessionStateProvider =
    StateNotifierProvider<SessionController, SessionState>((ref) {
      final service = ref.read(sessionServiceProvider);
      return SessionController(service)..load();
    });

class SessionController extends StateNotifier<SessionState> {
  final SessionService _service;
  SessionController(this._service) : super(SessionState.initial);

  Future<void> load() async {
    final logged = _service.isLoggedIn(); // Remove await
    if (!logged) {
      state = SessionState.initial;
      return;
    }

    final userId = _service.getUserId(); // Remove await
    final firstName = _service.getFirstName(); // Remove await
    final email = _service.getEmail(); // Remove await
    final role = _service.getRole(); // Remove await

    state = SessionState(
      isLoggedIn: true,
      userId: userId,
      firstName: firstName,
      email: email,
      role: role,
    );
  }

  Future<void> setSession({
    required String userId,
    required String firstName,
    required String email,
    String? role,
  }) async {
    await _service.saveSession(
      userId: userId,
      firstName: firstName,
      email: email,
      role: role,
    );
    state = SessionState(
      isLoggedIn: true,
      userId: userId,
      firstName: firstName,
      email: email,
      role: role,
    );
  }

  Future<void> clearSession() async {
    await _service.clearSession();
    state = SessionState.initial;
  }
}
