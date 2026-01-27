import '../../models/pet_model.dart';

abstract class PetLocalDataSource {
  Future<void> savePet(PetModel pet);
  Future<List<PetModel>> getPets();
}
