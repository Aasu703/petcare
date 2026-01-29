import '../entities/pet_entity.dart';
import '../repositories/pet_repository.dart';

class AddPetUseCase {
  final PetRepository repository;

  AddPetUseCase(this.repository);

  Future<PetEntity> call({
    required String token,
    required String name,
    required String species,
    required String breed,
    required String age,
    required String weight,
    String? imagePath,
  }) {
    return repository.addPet(
      token: token,
      name: name,
      species: species,
      breed: breed,
      age: age,
      weight: weight,
      imagePath: imagePath,
    );
  }
}
