import 'package:equatable/equatable.dart';
import 'package:petcare/features/auth/domain/entities/auth_entity.dart';

class ProfileState extends Equatable {
  final bool isLoading;
  final AuthEntity? user;
  final String? errorMessage;
  final bool updated;

  const ProfileState({
    this.isLoading = false,
    this.user,
    this.errorMessage,
    this.updated = false,
  });

  ProfileState copyWith({
    bool? isLoading,
    AuthEntity? user,
    String? errorMessage,
    bool? updated,
    bool clearError = false,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      updated: updated ?? this.updated,
    );
  }

  @override
  List<Object?> get props => [isLoading, user, errorMessage, updated];
}
