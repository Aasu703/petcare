import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/pet/domain/entities/pet_entity.dart';
import 'package:petcare/features/pet/domain/repository/pet_repository.dart';

class GetAllUserPetsUsecase implements UsecaseWithoutParams<List<PetEntity>> {
  final IPetRepository _repository;

  GetAllUserPetsUsecase({required IPetRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<PetEntity>>> call() async {
    try {
      final pets = await _repository.getAllUserPets();
      return Right(pets);
    } catch (error) {
      return Left(ServerFailure(message: error.toString()));
    }
  }
}
