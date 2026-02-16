class BaseState {
  final bool isLoading;
  final String? error;

  const BaseState({this.isLoading = false, this.error});

  BaseState copyWith({bool? isLoading, String? error}) {
    return BaseState(isLoading: isLoading ?? this.isLoading, error: error);
  }
}
