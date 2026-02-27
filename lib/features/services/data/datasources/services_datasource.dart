import 'package:petcare/features/services/data/models/service_model.dart';

abstract interface class IServiceCacheDataSource {
  Future<void> saveServices(List<ServiceModel> services);
  Future<List<ServiceModel>> getCachedServices();
  Future<bool> hasFreshCache({Duration maxAge});
  Future<void> clear();
}

abstract interface class IServiceRemoteDataSource {
  Future<List<ServiceModel>> getServices({int page, int limit});
  Future<ServiceModel?> getServiceById(String serviceId);
  Future<List<ServiceModel>> getServicesByProvider(
    String providerId, {
    int page,
    int limit,
  });
}
