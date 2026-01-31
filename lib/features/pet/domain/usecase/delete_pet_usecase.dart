import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/pet/domain/repository/pet_repository.dart';

class DeletePetParams extends Equatable {
  final String petId;

  const DeletePetParams({required this.petId});

  @override
  List<Object?> get props => [petId];
}

class DeletePetUsecase implements UsecaseWithParams<bool, DeletePetParams> {
  final IPetRepository _repository;

  DeletePetUsecase({required IPetRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(DeletePetParams params) async {
    try {
      final result = await _repository.deletePet(params.petId);
      return Right(result);
    } catch (error) {
      return Left(ServerFailure(message: error.toString()));
    }
  }
}
