import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/services/connectivity/network_info.dart';
import 'package:petcare/core/services/hive/hive_service.dart';

final hiveServiceProvider = Provider<HiveService>((ref) => HiveService());

final iNetworkInfoProvider = Provider<INetworkInfo>(
  (ref) => ref.read(networkInfoProvider),
);
