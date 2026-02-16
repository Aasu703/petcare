import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/api/api_client.dart';
import 'package:petcare/core/api/api_endpoints.dart';
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

final healthRecordRemoteDatasourceProvider =
    Provider<IHealthRecordRemoteDataSource>(
      (ref) =>
          HealthRecordRemoteDataSource(apiClient: ref.read(apiClientProvider)),
    );

class HealthRecordRemoteDataSource implements IHealthRecordRemoteDataSource {
  final ApiClient _apiClient;

  HealthRecordRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<HealthRecordModel>> getByPetId(String petId) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.healthRecordByPet}/$petId',
    );
    final data = response.data;
    List<dynamic> list = [];
    if (data is Map<String, dynamic>) {
      list = data['data'] ?? data['records'] ?? [];
    } else if (data is List) {
      list = data;
    }
    return list
        .map((item) => HealthRecordModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<HealthRecordModel> createRecord(HealthRecordModel record) async {
    final response = await _apiClient.post(
      ApiEndpoints.healthRecord,
      data: record.toJson(),
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final inner = data['data'] ?? data;
      if (inner is Map<String, dynamic>) {
        return HealthRecordModel.fromJson(inner);
      }
    }
    return record;
  }

  @override
  Future<HealthRecordModel> updateRecord(
    String recordId,
    HealthRecordModel record,
  ) async {
    final response = await _apiClient.put(
      '${ApiEndpoints.healthRecord}/$recordId',
      data: record.toJson(),
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final inner = data['data'] ?? data;
      if (inner is Map<String, dynamic>) {
        return HealthRecordModel.fromJson(inner);
      }
    }
    return record;
  }

  @override
  Future<bool> deleteRecord(String recordId) async {
    final response = await _apiClient.delete(
      '${ApiEndpoints.healthRecord}/$recordId',
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data['success'] == true;
    }
    return false;
  }
}
