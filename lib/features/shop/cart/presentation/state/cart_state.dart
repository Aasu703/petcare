class CartState {
  final bool isCheckingOut;
  final String? errorMessage;

  const CartState({this.isCheckingOut = false, this.errorMessage});

  CartState copyWith({
    bool? isCheckingOut,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CartState(
      isCheckingOut: isCheckingOut ?? this.isCheckingOut,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
