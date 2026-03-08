import 'package:flutter_riverpod/legacy.dart';
import 'package:petcare/features/auth/presentation/providers/auth_providers.dart';
import 'package:petcare/features/auth/domain/usecases/request_password_reset_usecase.dart';
import 'package:petcare/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:petcare/features/forgotpassword/presentation/state/forgot_password_state.dart';

class ForgotPasswordNotifier extends StateNotifier<ForgotPasswordState> {
  final RequestPasswordResetUsecase _requestReset;
  final ResetPasswordUsecase _reset;

  ForgotPasswordNotifier({
    required RequestPasswordResetUsecase requestReset,
    required ResetPasswordUsecase reset,
  }) : _requestReset = requestReset,
       _reset = reset,
       super(const ForgotPasswordState());

  Future<bool> sendResetLink(String email) async {
    state = state.copyWith(isLoading: true, success: false, clearError: true);
    final result = await _requestReset(email);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false, success: true, error: null);
        return true;
      },
    );
  }

  Future<bool> resetPassword({
    required String token,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, success: false, clearError: true);
    final result = await _reset(
      ResetPasswordParams(token: token, newPassword: password),
    );
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false, success: true, error: null);
        return true;
      },
    );
  }
}

final forgotPasswordNotifierProvider =
    StateNotifierProvider<ForgotPasswordNotifier, ForgotPasswordState>((ref) {
      return ForgotPasswordNotifier(
        requestReset: ref.read(requestPasswordResetUsecaseProvider),
        reset: ref.read(resetPasswordUsecaseProvider),
      );
    });
