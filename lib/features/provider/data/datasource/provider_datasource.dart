import 'package:petcare/features/provider/data/model/provider_hive_model.dart';

abstract interface class IProviderDatasource {
  Future<List<ProviderHiveModel>> getAllProviders();
  Future<ProviderHiveModel?> getProviderById(String providerId);
  Future<bool> createProvider(ProviderHiveModel model);
  Future<bool> updateProvider(ProviderHiveModel model);
  Future<bool> deleteProvider(String providerId);
}
