import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/pet/domain/entities/pet_entity.dart';
import 'package:petcare/features/pet/domain/repositories/pet_repository.dart';

class UpdatePetParams extends Equatable {
  final String petId;
  final String name;
  final String species;
  final String? breed;
  final int? age;
  final double? weight;
  final String? imageUrl;

  const UpdatePetParams({
    required this.petId,
    required this.name,
    required this.species,
    this.breed,
    this.age,
    this.weight,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
    petId,
    name,
    species,
    breed,
    age,
    weight,
    imageUrl,
  ];
}

class UpdatePetUsecase
    implements UsecaseWithParams<PetEntity, UpdatePetParams> {
  final IPetRepository _repository;

  UpdatePetUsecase({required IPetRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, PetEntity>> call(UpdatePetParams params) async {
    try {
      final entity = PetEntity(
        petId: params.petId,
        name: params.name,
        species: params.species,
        breed: params.breed,
        age: params.age,
        weight: params.weight,
        imageUrl: params.imageUrl,
      );

      final updated = await _repository.updatePet(params.petId, entity);
      return Right(updated);
    } catch (error) {
      return Left(ServerFailure(message: error.toString()));
    }
  }
}
