import 'package:petcare/features/provider_service/data/models/provider_service_model.dart';

abstract interface class IProviderServiceRemoteDataSource {
  Future<ProviderServiceModel> applyForService(
    ProviderServiceModel model, {
    String? medicalLicensePath,
    String? certificationPath,
    List<String> facilityImagePaths,
    String? businessRegistrationPath,
  });
  Future<List<ProviderServiceModel>> getMyServices();
  Future<ProviderServiceModel?> getServiceById(String serviceId);
}
