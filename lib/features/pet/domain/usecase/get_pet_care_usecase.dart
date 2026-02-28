import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/pet/domain/entities/pet_care_entity.dart';
import 'package:petcare/features/pet/domain/repository/pet_repository.dart';

class GetPetCareParams extends Equatable {
  final String petId;

  const GetPetCareParams({required this.petId});

  @override
  List<Object?> get props => [petId];
}

class GetPetCareUsecase
    implements UsecaseWithParams<PetCareEntity, GetPetCareParams> {
  final IPetRepository _repository;

  GetPetCareUsecase({required IPetRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, PetCareEntity>> call(GetPetCareParams params) async {
    try {
      final care = await _repository.getPetCare(params.petId);
      return Right(care);
    } catch (error) {
      return Left(ServerFailure(message: error.toString()));
    }
  }
}
