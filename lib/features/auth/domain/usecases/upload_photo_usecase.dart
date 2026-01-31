import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/auth/di/auth_providers.dart';
import 'package:petcare/features/auth/domain/repositories/auth_repository.dart';

final uploadPhotoUsecaseProvider = Provider<UploadPhotoUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return UploadPhotoUsecase(authRepository: authRepository);
});

class UploadPhotoUsecase implements UsecaseWithParams<String, File> {
  final IAuthRepository _authRepository;

  UploadPhotoUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, String>> call(File photo) {
    return _authRepository.uploadPhoto(photo);
  }
}
