import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/session/session_provider.dart';
import 'package:petcare/core/session/session_state.dart';

/// A [ChangeNotifier] that the [GoRouter] can use as [refreshListenable].
///
/// It listens to the [sessionProvider] and calls [notifyListeners] whenever
/// the session state changes (login / logout / role change).
final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

class RouterNotifier extends ChangeNotifier {
  late final ProviderSubscription<SessionState> _sub;

  RouterNotifier(Ref ref) {
    _sub = ref.listen<SessionState>(sessionProvider, (previous, next) {
      // Only notify when auth-relevant fields change.
      if (previous?.isLoggedIn != next.isLoggedIn ||
          previous?.role != next.role) {
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}
