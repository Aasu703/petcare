import 'package:flutter_riverpod/legacy.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';

class UserSessionNotifier extends StateNotifier<dynamic> {
  final UserSessionService _service;

  UserSessionNotifier(this._service) : super(null);

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
      lastName: '',
      role: role,
    );
    state = null;
  }

  Future<void> clearSession() async {
    await _service.clearSession();
    state = null;
  }
}

final UserSessionNotifierProvider =
    StateNotifierProvider<UserSessionNotifier, dynamic>((ref) {
      final service = ref.read(userSessionServiceProvider);
      return UserSessionNotifier(service);
    });

// legacy lowercase alias used in some files
final userSessionNotifierProvider = UserSessionNotifierProvider;
