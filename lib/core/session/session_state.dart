import 'package:equatable/equatable.dart';

class SessionState extends Equatable {
  final bool isLoggedIn;
  final String? userId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? role;
  final String? providerType;
  final String? providerStatus;
  final String? profilePic;

  const SessionState({
    this.isLoggedIn = false,
    this.userId,
    this.firstName,
    this.lastName,
    this.email,
    this.role,
    this.providerType,
    this.providerStatus,
    this.profilePic,
  });

  bool get isProvider => (role ?? '').toLowerCase() == 'provider';
  bool get isUser => !isProvider;
  bool get hasProviderType => (providerType ?? '').trim().isNotEmpty;
  bool get isProviderApproved =>
      (providerStatus ?? '').trim().toLowerCase() == 'approved';

  SessionState copyWith({
    bool? isLoggedIn,
    String? userId,
    String? firstName,
    String? lastName,
    String? email,
    String? role,
    String? providerType,
    String? providerStatus,
    String? profilePic,
  }) {
    return SessionState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      role: role ?? this.role,
      providerType: providerType ?? this.providerType,
      providerStatus: providerStatus ?? this.providerStatus,
      profilePic: profilePic ?? this.profilePic,
    );
  }

  @override
  List<Object?> get props => [
    isLoggedIn,
    userId,
    firstName,
    lastName,
    email,
    role,
    providerType,
    providerStatus,
    profilePic,
  ];
}
