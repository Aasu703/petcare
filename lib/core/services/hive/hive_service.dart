import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:petcare/core/constants/hive_table_constant.dart';
import 'package:petcare/features/auth/data/models/auth_hive_model.dart';
import 'package:petcare/features/provider/data/model/provider_hive_model.dart';

class HiveService {
  HiveService._internal();

  static final HiveService _instance = HiveService._internal();

  factory HiveService() => _instance;

  // init
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstant.db}';
    Hive.init(path);
    _registerAdapter();
  }

  // Register Adapters
  void _registerAdapter() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.providerTypeId)) {
      Hive.registerAdapter(ProviderHiveModelAdapter());
    }

    // Register
    if (!Hive.isAdapterRegistered(HiveTableConstant.userTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
  }

  // Open Boxes
  Future<void> openBoxes() async {
    await Hive.openBox<ProviderHiveModel>(HiveTableConstant.providerTable);
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.userTable);
  }

  // Close Boxes
  Future<void> close() async {
    await Hive.close();
  }

  //__________________________________- Queries Provider quieres ______________________________

  Box<ProviderHiveModel> get _providerBox =>
      Hive.box<ProviderHiveModel>(HiveTableConstant.providerTable);

  // create
  Future<ProviderHiveModel> createProvider(ProviderHiveModel model) async {
    await _providerBox.put(model.providerId, model);
    return model;
  }

  // get

  List<ProviderHiveModel> getAllProvider() {
    return _providerBox.values.toList();
  }

  // update

  Future<void> updateProvider(ProviderHiveModel model) async {
    await _providerBox.put(model.providerId, model);
  }

  // delete

  // _____________________________________- Queries Auth ____________________________________________

  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.userTable);

  Future<AuthHiveModel> createUser(AuthHiveModel model) async {
    await _authBox.put(model.userId, model);
    return model;
  }

  Future<AuthHiveModel?> loginUser(String email, String password) async {
    try {
      final user = _authBox.values.where(
        (user) => user.email == email && user.password == password,
      );
      return user.first;
    } catch (e) {
      return null;
    }
  }

  Future<void> logoutUser(String userId) async {
    await _authBox.delete(userId);
  }

  Future<AuthHiveModel?> getCurrentUser(String userId) async {
    return _authBox.get(userId);
  }
}
