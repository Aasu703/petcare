import 'package:petcare/features/health_records/data/models/health_record_model.dart';

abstract interface class IHealthRecordRemoteDataSource {
  Future<List<HealthRecordModel>> getByPetId(String petId);
  Future<HealthRecordModel> createRecord(HealthRecordModel record);
  Future<HealthRecordModel> updateRecord(
    String recordId,
    HealthRecordModel record,
  );
  Future<bool> deleteRecord(String recordId);
}
