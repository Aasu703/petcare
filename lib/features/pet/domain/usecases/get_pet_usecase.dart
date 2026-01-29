import '../entities/pet_entity.dart';
import '../repositories/pet_repository.dart';

class GetPetsUseCase {
  final PetRepository repository;

  GetPetsUseCase(this.repository);

  Future<List<PetEntity>> call(String token) {
    return repository.getPets(token);
  }
}
