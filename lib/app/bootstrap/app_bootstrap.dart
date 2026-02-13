import 'package:petcare/core/services/hive/hive_service.dart';
import 'package:petcare/core/services/notification/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppBootstrapResult {
  final SharedPreferences sharedPreferences;

  const AppBootstrapResult({required this.sharedPreferences});
}

class AppBootstrap {
  const AppBootstrap._();

  static Future<AppBootstrapResult> initialize() async {
    final hiveService = HiveService();
    await hiveService.init();
    await hiveService.openBoxes();

    final notificationService = NotificationService();
    await notificationService.init();

    final sharedPreferences = await SharedPreferences.getInstance();

    return AppBootstrapResult(sharedPreferences: sharedPreferences);
  }
}
