import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/pet/domain/entities/pet_entity.dart';
import 'package:petcare/features/pet/domain/repository/pet_repository.dart';

class AssignVetParams extends Equatable {
  final String petId;
  final String vetId;

  const AssignVetParams({required this.petId, required this.vetId});

  @override
  List<Object?> get props => [petId, vetId];
}

class AssignVetUsecase
    implements UsecaseWithParams<PetEntity, AssignVetParams> {
  final IPetRepository _repository;

  AssignVetUsecase({required IPetRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, PetEntity>> call(AssignVetParams params) async {
    try {
      final pet = await _repository.assignVet(
        petId: params.petId,
        vetId: params.vetId,
      );
      return Right(pet);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
