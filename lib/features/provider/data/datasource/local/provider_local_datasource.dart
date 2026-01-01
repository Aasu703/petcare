import 'package:petcare/core/services/hive/hive_service.dart';
import 'package:petcare/features/provider/data/datasource/provider_datasource.dart';
import 'package:petcare/features/provider/data/model/provider_hive_model.dart';

class ProviderLocalDatasource implements IProviderDatasource {
  final HiveService _hiveService;

  ProviderLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<bool> createProvider(ProviderHiveModel entity) async {
    try {
      await _hiveService.createProvider(entity);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteProvider(String providerId) {
    // TODO: implement deleteProvider
    throw UnimplementedError();
  }

  @override
  Future<List<ProviderHiveModel>> getAllProviders() async {
    try {
      return _hiveService.getAllProvider();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<ProviderHiveModel?> getProviderById(String providerId) {
    // TODO: implement getProviderById
    throw UnimplementedError();
  }

  @override
  Future<bool> updateProvider(ProviderHiveModel entity) {
    // TODO: implement updateProvider
    throw UnimplementedError();
  }
}
