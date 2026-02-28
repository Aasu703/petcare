import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/pet/domain/entities/pet_care_entity.dart';
import 'package:petcare/features/pet/domain/repository/pet_repository.dart';

class UpdatePetCareParams extends Equatable {
  final String petId;
  final PetCareEntity care;

  const UpdatePetCareParams({required this.petId, required this.care});

  @override
  List<Object?> get props => [petId, care];
}

class UpdatePetCareUsecase
    implements UsecaseWithParams<PetCareEntity, UpdatePetCareParams> {
  final IPetRepository _repository;

  UpdatePetCareUsecase({required IPetRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, PetCareEntity>> call(
    UpdatePetCareParams params,
  ) async {
    try {
      final updated = await _repository.updatePetCare(
        params.petId,
        params.care,
      );
      return Right(updated);
    } catch (error) {
      return Left(ServerFailure(message: error.toString()));
    }
  }
}
