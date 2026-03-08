import 'dart:io';

import 'package:flutter_riverpod/legacy.dart';
import 'package:petcare/core/session/session_provider.dart';
import 'package:petcare/features/auth/presentation/providers/auth_providers.dart';
import 'package:petcare/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:petcare/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:petcare/features/auth/presentation/state/profile_state.dart';

final profileViewModelProvider =
    StateNotifierProvider<ProfileViewModel, ProfileState>((ref) {
      return ProfileViewModel(
        getCurrentUserUsecase: ref.read(getCurrentUserUsecaseProvider),
        updateProfileUsecase: ref.read(updateProfileUsecaseProvider),
        sessionNotifier: ref.read(sessionProvider.notifier),
      );
    });

class ProfileViewModel extends StateNotifier<ProfileState> {
  final GetCurrentUserUsecase _getCurrentUserUsecase;
  final UpdateProfileUsecase _updateProfileUsecase;
  final SessionNotifier _sessionNotifier;

  ProfileViewModel({
    required GetCurrentUserUsecase getCurrentUserUsecase,
    required UpdateProfileUsecase updateProfileUsecase,
    required SessionNotifier sessionNotifier,
  }) : _getCurrentUserUsecase = getCurrentUserUsecase,
       _updateProfileUsecase = updateProfileUsecase,
       _sessionNotifier = sessionNotifier,
       super(const ProfileState());

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, clearError: true, updated: false);

    final result = await _getCurrentUserUsecase();

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (user) {
        state = state.copyWith(isLoading: false, user: user);
      },
    );
  }

  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    File? imageFile,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, updated: false);

    final result = await _updateProfileUsecase(
      UpdateProfileParams(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        imageFile: imageFile,
      ),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
          updated: false,
        );
        return false;
      },
      (user) async {
        await _sessionNotifier.setSession(
          userId: user.userId,
          firstName: user.FirstName,
          email: user.email,
        );
        state = state.copyWith(isLoading: false, user: user, updated: true);
        return true;
      },
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
