import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const bool isPhysicalDevice = false;

  static const String compIpAddress = "192.168.1.2";

  static String get serverUrl => 'http://$compIpAddress:5050';

  static String get mediaServerUrl {
    if (isPhysicalDevice) {
      return 'http://$compIpAddress:5050';
    }

    if (kIsWeb) {
      return 'http://localhost:5050';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5050';
    } else if (Platform.isIOS) {
      return 'http://localhost:5050';
    } else {
      return 'http://localhost:5050';
    }
  }

  static String get baseUrl {
    if (isPhysicalDevice) {
      return 'http://$compIpAddress:5050/api/';
    }

    if (kIsWeb) {
      return 'http://localhost:5050/api/';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5050/api/';
    } else if (Platform.isIOS) {
      return 'http://localhost:5050/api/';
    } else {
      return 'http://localhost:5050/api/';
    }
  }

  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // -------------------------- AUTH -------------------------
  static const String user = 'auth/user';
  static const String userLogin = 'auth/login';
  static const String userRegister = 'auth/register';
  static const String userWhoAmI = 'auth/whoami';
  static const String userUploadPhoto = 'auth/update-profile';
  static String userPicture(String filename) =>
      '$mediaServerUrl/user_photos/$filename';
  // ------------------------ PROVIDER -----------------------
  static const String provider = 'provider';
  static const String providerLogin = 'login';
  static const String providerRegister = 'register';

  static const String providerGetAll = '/providers';
  static const String providerById = '/providers';
  static const String providerCreate = '/providers';
  static const String providerUpdate = '/providers';
  static const String providerDelete = '/providers';

  // ------------------------ PET ----------------------------
  static const String petGetAll = 'pet';
  static const String petById = 'pet';
  static const String petCreate = 'pet';
  static const String petUpdate = 'pet';
  static const String petDelete = 'pet';
}
