import 'package:petcare/features/provider/data/model/provider_hive_model.dart';
import 'package:petcare/features/provider/data/model/provider_api_model.dart';

abstract interface class IProviderDatasource {
  Future<List<ProviderHiveModel>> getAllProviders();
  Future<ProviderHiveModel?> getProviderById(String providerId);
  Future<bool> createProvider(ProviderHiveModel model);
  Future<bool> updateProvider(ProviderHiveModel model);
  Future<bool> deleteProvider(String providerId);
}

abstract interface class IProviderRemoteDataSource {
  Future<List<ProviderApiModel>> getAllProviders();
  Future<ProviderApiModel?> getProviderById(String providerId);
  Future<ProviderApiModel> createProvider(ProviderApiModel provider);
  Future<bool> updateProvider(ProviderApiModel provider);
  Future<bool> deleteProvider(String providerId);
}
