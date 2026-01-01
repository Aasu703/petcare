import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String userId;
  final String email;
  final String FirstName;
  final String LastName;
  final String phoneNumber;
  final String username;
  final String? password;
  final String? avatar;

  AuthEntity({
    required this.userId,
    required this.email,
    required this.FirstName,
    required this.LastName,
    required this.phoneNumber,
    required this.username,
    this.password,
    this.avatar,
  });

  @override
  List<Object?> get props => [
    userId,
    email,
    FirstName,
    LastName,
    phoneNumber,
    username,
    password,
    avatar,
  ];
}
