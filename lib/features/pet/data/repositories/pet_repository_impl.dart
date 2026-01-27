import 'package:petcare/features/pet/domain/entities/pet_entity.dart';
import 'package:petcare/features/pet/domain/repositories/pet_repository.dart';
import 'package:petcare/features/pet/data/models/pet_model.dart';
import 'package:petcare/features/pet/data/datasource/local/pet_local_datasource.dart';

class PetRepositoryImpl implements PetRepository {
  final PetLocalDataSource localDataSource;
  // Optionally, add remoteDataSource if needed

  PetRepositoryImpl({required this.localDataSource});

  @override
  Future<void> addPet(PetEntity pet) async {
    final model = PetModel(
      id: pet.id,
      name: pet.name,
      gender: pet.gender,
      imagePath: pet.imagePath,
    );
    await localDataSource.savePet(model);
  }

  @override
  Future<List<PetEntity>> getPets() async {
    final models = await localDataSource.getPets();
    return models;
  }
}
