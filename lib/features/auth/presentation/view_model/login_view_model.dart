import 'package:flutter_riverpod/legacy.dart';
import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/session/session_provider.dart';
import 'package:petcare/features/auth/presentation/providers/auth_providers.dart';
import 'package:petcare/features/auth/domain/entities/auth_entity.dart';
import 'package:petcare/features/auth/domain/usecases/login_usecase.dart';
import 'package:petcare/features/auth/presentation/state/profile_state.dart';

class LoginViewModel extends StateNotifier<ProfileState> {
  final LoginUsecase _loginUsecase;
  final SessionNotifier _sessionNotifier;

  LoginViewModel({
    required LoginUsecase loginUsecase,
    required SessionNotifier sessionNotifier,
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

    // Handle result outside fold to properly await async operations
    if (result.isRight()) {
      final user = result.getOrElse(() => throw StateError('unreachable'));
      await _sessionNotifier.setSession(
        userId: user.userId,
        firstName: user.FirstName,
        lastName: user.LastName,
        email: user.email,
      );
      state = state.copyWith(isLoading: false, user: user);
    } else {
      result.fold((failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      }, (_) {});
    }

    return result;
  }
}

final loginViewModelProvider =
    StateNotifierProvider<LoginViewModel, ProfileState>((ref) {
      final loginUsecase = ref.read(loginUsecaseProvider);
      final sessionNotifier = ref.read(sessionProvider.notifier);
      return LoginViewModel(
        loginUsecase: loginUsecase,
        sessionNotifier: sessionNotifier,
      );
    });
