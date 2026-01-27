import '../entities/pet_entity.dart';

abstract class PetRepository {
  Future<void> addPet(PetEntity pet);
  Future<List<PetEntity>> getPets();
}
