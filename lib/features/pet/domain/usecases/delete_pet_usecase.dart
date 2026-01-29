import '../repositories/pet_repository.dart';

class DeletePetUseCase {
  final PetRepository repository;

  DeletePetUseCase(this.repository);

  Future<void> call(String token, String petId) {
    return repository.deletePet(token, petId);
  }
}
