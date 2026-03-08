class ForgotPasswordState {
  final bool isLoading;
  final bool success;
  final String? error;

  const ForgotPasswordState({
    this.isLoading = false,
    this.success = false,
    this.error,
  });

  ForgotPasswordState copyWith({
    bool? isLoading,
    bool? success,
    String? error,
    bool clearError = false,
  }) {
    return ForgotPasswordState(
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      error: clearError ? null : error ?? this.error,
    );
  }
}
