import 'package:equatable/equatable.dart';

class SessionState extends Equatable {
  final bool isLoggedIn;
  final String? userId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? role;
  final String? providerType;
  final String? profilePic;

  const SessionState({
    this.isLoggedIn = false,
    this.userId,
    this.firstName,
    this.lastName,
    this.email,
    this.role,
    this.providerType,
    this.profilePic,
  });

  bool get isProvider => (role ?? '').toLowerCase() == 'provider';
  bool get isUser => !isProvider;

  SessionState copyWith({
    bool? isLoggedIn,
    String? userId,
    String? firstName,
    String? lastName,
    String? email,
    String? role,
    String? providerType,
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
        profilePic,
      ];
}
