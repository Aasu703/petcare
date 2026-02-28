import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/pet/domain/entities/pet_entity.dart';
import 'package:petcare/features/pet/domain/repository/pet_repository.dart';

class AddPetUsecaseParams extends Equatable {
  final String name;
  final String species;
  final String? breed;
  final int? age;
  final double? weight;
  final String? imageUrl; // Local file path before upload

  const AddPetUsecaseParams({
    required this.name,
    required this.species,
    this.breed,
    this.age,
    this.weight,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [name, species, breed, age, weight, imageUrl];
}

class AddPetUsecase
    implements UsecaseWithParams<PetEntity, AddPetUsecaseParams> {
  final IPetRepository _repository;

  AddPetUsecase({required IPetRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, PetEntity>> call(AddPetUsecaseParams params) async {
    try {
      // Create entity from params (no petId yet - backend generates it)
      final petEntity = PetEntity(
        name: params.name,
        species: params.species,
        breed: params.breed,
        age: params.age,
        weight: params.weight,
        imageUrl: params.imageUrl, // Local path or null
      );

      // Call repository and get back the created pet WITH the generated ID
      final createdPet = await _repository.addPet(petEntity);

      return Right(createdPet);
    } catch (error) {
      return Left(ServerFailure(message: error.toString()));
    }
  }
}
