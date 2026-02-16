import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/features/health_records/data/datasource/remote/health_record_remote_datasource.dart';
import 'package:petcare/features/health_records/data/repositories/health_record_repository_impl.dart';
import 'package:petcare/features/health_records/domain/repositories/health_record_repository.dart';
import 'package:petcare/features/health_records/domain/usecases/get_health_records_by_pet_usecase.dart';

final healthRecordRepositoryProvider = Provider<IHealthRecordRepository>((ref) {
  final remote = ref.read(healthRecordRemoteDatasourceProvider);
  return HealthRecordRepositoryImpl(remoteDataSource: remote);
});

final getHealthRecordsByPetUsecaseProvider =
    Provider<GetHealthRecordsByPetUsecase>((ref) {
      final repo = ref.read(healthRecordRepositoryProvider);
      return GetHealthRecordsByPetUsecase(repository: repo);
    });
