abstract interface class IPetDataSource {
  Future<void> addPet(Map<String, dynamic> petData);
  Future<List<Map<String, dynamic>>> getPets();
}

abstract interface class IPetRemoteDataSource {
  Future<void> savePet(Map<String, dynamic> petData);
  Future<List<Map<String, dynamic>>> getPets();
}
