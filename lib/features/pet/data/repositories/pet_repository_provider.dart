import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/features/pet/data/datasource/local/pet_local_datasource.dart';
import 'package:petcare/features/pet/data/repositories/pet_repository_impl.dart';
import 'package:petcare/features/pet/domain/repositories/pet_repository.dart';

final petRepositoryProvider = Provider<PetRepository>((ref) {
  // TODO: Replace with actual local data source implementation
  throw UnimplementedError('Provide a real PetLocalDataSource');
  // Example:
  // final localDataSource = ref.watch(petLocalDataSourceProvider);
  // return PetRepositoryImpl(localDataSource: localDataSource);
});
