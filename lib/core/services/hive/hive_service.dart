import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:petcare/core/constants/hive_table_constant.dart';
import 'package:petcare/features/provider/data/model/provider_hive_model.dart';

class HiveService {
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
  }

  // Open Boxes
  Future<void> openBoxes() async {
    await Hive.openBox<ProviderHiveModel>(HiveTableConstant.providerTable);
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
}
