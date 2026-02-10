import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const bool isPhysicalDevice = true;

  static const String compIpAddress = "192.168.1.6";

  static String get baseUrl => 'http://$compIpAddress:5050/';

  static String get mediaServerUrl {
    if (isPhysicalDevice) {
      return 'http://$compIpAddress:5050';
    }

    if (kIsWeb) {
      return 'http://localhost:5050/';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5050/';
    } else if (Platform.isIOS) {
      return 'http://localhost:5050/';
    } else {
      return 'http://localhost:5050/';
    }
  }

  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // -------------------------- AUTH -------------------------
  static const String user = 'api/auth/user';
  static const String userLogin = 'api/auth/login';
  static const String userRegister = 'api/auth/register';
  static const String userWhoAmI = 'api/auth/whoami';
  static const String userUploadPhoto = 'api/auth/update-profile';
  static String userPicture(String filename) =>
      '$mediaServerUrl/user_photos/$filename';
  // ------------------------ PROVIDER -----------------------
  static const String provider = 'api/provider';
  static const String providerLogin = 'login';
  static const String providerRegister = 'register';

  static const String providerGetAll = 'api/provider';
  static const String providerById = 'api/provider';
  static const String providerCreate = 'api/provider';
  static const String providerUpdate = 'api/provider';
  static const String providerDelete = 'api/provider';

  // ------------------------ PET ----------------------------
  static const String petGetAll = 'pet';
  static const String petById = 'pet';
  static const String petCreate = 'pet';
  static const String petUpdate = 'pet';
  static const String petDelete = 'pet';
}
