import '../entities/pet_entity.dart';
import '../repositories/pet_repository.dart';

class AddPetUseCase {
  final PetRepository repository;

  AddPetUseCase(this.repository);

  Future<void> call(PetEntity pet) {
    return repository.addPet(pet);
  }
}
