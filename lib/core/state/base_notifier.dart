import 'package:flutter_riverpod/legacy.dart';
import 'base_state.dart';

class BaseNotifier<T extends BaseState> extends StateNotifier<T> {
  BaseNotifier(super.state);

  void setLoading(bool loading) {
    state = (state.copyWith(isLoading: loading) as T);
  }

  void setError(String? message) {
    state = (state.copyWith(error: message, isLoading: false) as T);
  }
}
