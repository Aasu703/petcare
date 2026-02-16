import 'package:flutter_riverpod/legacy.dart';
import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/features/auth/di/auth_providers.dart';
import 'package:petcare/features/auth/domain/entities/auth_entity.dart';
import 'package:petcare/features/auth/domain/usecases/login_usecase.dart';
import 'package:petcare/features/auth/presentation/state/profile_state.dart';
import 'package:petcare/features/auth/presentation/view_model/session_notifier.dart';

class LoginViewModel extends StateNotifier<ProfileState> {
  final LoginUsecase _loginUsecase;
  final UserSessionNotifier _sessionNotifier;

  LoginViewModel({
    required LoginUsecase loginUsecase,
    required UserSessionNotifier sessionNotifier,
  }) : _loginUsecase = loginUsecase,
       _sessionNotifier = sessionNotifier,
       super(const ProfileState());

  Future<Either<Failure, AuthEntity>> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _loginUsecase(
      LoginUsecaseParams(email: email, password: password),
    );
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (user) async {
        await _sessionNotifier.setSession(
          userId: user.userId,
          firstName: user.FirstName,
          email: user.email,
        );
        state = state.copyWith(isLoading: false, user: user);
      },
    );
    return result;
  }
}

final loginViewModelProvider =
    StateNotifierProvider<LoginViewModel, ProfileState>((ref) {
      final loginUsecase = ref.read(loginUsecaseProvider);
      final sessionNotifier = ref.read(UserSessionNotifierProvider.notifier);
      return LoginViewModel(
        loginUsecase: loginUsecase,
        sessionNotifier: sessionNotifier,
      );
    });
