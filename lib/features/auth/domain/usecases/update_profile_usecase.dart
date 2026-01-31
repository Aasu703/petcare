import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/auth/domain/entities/auth_entity.dart';
import 'package:petcare/features/auth/domain/repositories/auth_repository.dart';

class UpdateProfileParams extends Equatable {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final File? imageFile;

  const UpdateProfileParams({
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.imageFile,
  });

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    email,
    phoneNumber,
    imageFile,
  ];
}

class UpdateProfileUsecase
    implements UsecaseWithParams<AuthEntity, UpdateProfileParams> {
  final IAuthRepository _repository;

  UpdateProfileUsecase({required IAuthRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, AuthEntity>> call(UpdateProfileParams params) {
    return _repository.updateProfile(
      firstName: params.firstName,
      lastName: params.lastName,
      email: params.email,
      phoneNumber: params.phoneNumber,
      imageFile: params.imageFile,
    );
  }
}
