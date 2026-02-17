import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/provider/domain/entities/provider_entity.dart';
import 'package:petcare/features/provider/domain/repository/provider_repository.dart';

class ProviderRegisterUsecaseParams extends Equatable {
  final String email;
  final String password;
  final String confirmPassword;
  final String businessName;
  final String address;
  final String phone;
  final String providerType;

  const ProviderRegisterUsecaseParams({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.businessName,
    required this.address,
    required this.phone,
    required this.providerType,
  });

  @override
  List<Object?> get props => [
    email,
    password,
    confirmPassword,
    businessName,
    address,
    phone,
    providerType,
  ];
}

class ProviderRegisterUsecase
    implements UsecaseWithParams<bool, ProviderRegisterUsecaseParams> {
  final IProviderRepository _repository;

  ProviderRegisterUsecase({required IProviderRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(ProviderRegisterUsecaseParams params) {
    final entity = ProviderEntity(
      providerId: '',
      userId: '',
      businessName: params.businessName,
      address: params.address,
      phone: params.phone,
      rating: 0,
      providerType: params.providerType,
      email: params.email,
      password: params.password,
    );

    return _repository.register(entity, params.confirmPassword);
  }
}
