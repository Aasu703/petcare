import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/providers/shared_prefs_provider.dart';
import 'package:petcare/features/services/data/models/service_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class IServiceCacheDataSource {
  Future<void> saveServices(List<ServiceModel> services);
  Future<List<ServiceModel>> getCachedServices();
  Future<bool> hasFreshCache({Duration maxAge});
  Future<void> clear();
}

final serviceCacheDatasourceProvider = Provider<IServiceCacheDataSource>((ref) {
  return ServiceCacheDataSource(sharedPreferences: ref.read(sharedPrefsProvider));
});

class ServiceCacheDataSource implements IServiceCacheDataSource {
  static const _servicesKey = 'cached_services';
  static const _lastUpdatedKey = 'cached_services_last_updated';

  final SharedPreferences _sharedPreferences;

  ServiceCacheDataSource({required SharedPreferences sharedPreferences})
    : _sharedPreferences = sharedPreferences;

  @override
  Future<void> saveServices(List<ServiceModel> services) async {
    final jsonList = services.map((service) => service.toJson()).toList();
    await _sharedPreferences.setString(_servicesKey, jsonEncode(jsonList));
    await _sharedPreferences.setString(
      _lastUpdatedKey,
      DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<List<ServiceModel>> getCachedServices() async {
    final raw = _sharedPreferences.getString(_servicesKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];

    return decoded
        .whereType<Map>()
        .map((item) => item.map((k, v) => MapEntry(k.toString(), v)))
        .map(ServiceModel.fromJson)
        .toList();
  }

  @override
  Future<bool> hasFreshCache({
    Duration maxAge = const Duration(minutes: 15),
  }) async {
    final raw = _sharedPreferences.getString(_lastUpdatedKey);
    if (raw == null || raw.isEmpty) return false;

    final cachedAt = DateTime.tryParse(raw);
    if (cachedAt == null) return false;

    return DateTime.now().difference(cachedAt) <= maxAge;
  }

  @override
  Future<void> clear() async {
    await _sharedPreferences.remove(_servicesKey);
    await _sharedPreferences.remove(_lastUpdatedKey);
  }
}
