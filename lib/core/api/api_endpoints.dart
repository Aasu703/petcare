import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const bool isPhysicalDevice = false;

  static const String compIpAddress = "192.168.1.2";

  static String get baseUrl {
    if (isPhysicalDevice) {
      return 'http://$compIpAddress:5050/api/auth/';
    }

    if (kIsWeb) {
      return 'http://localhost:5050/api/auth/';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5050/api/auth/';
    } else if (Platform.isIOS) {
      return 'http://localhost:5050/api/auth/';
    } else {
      return 'http://localhost:5050/api/auth/';
    }
  }

  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // -------------------------- AUTH -------------------------
  static const String user = 'user';
  static const String userLogin = 'login';
  static const String userRegister = 'register';

  // ------------------------ PROVIDER -----------------------
  static const String provider = 'provider';
  static const String providerLogin = 'login';
  static const String providerRegister = 'register';

  static const String providerGetAll = '/providers';
  static const String providerById = '/providers';
  static const String providerCreate = '/providers';
  static const String providerUpdate = '/providers';
  static const String providerDelete = '/providers';

  // -------- ------------------------ PET -----------------------
  static const String pet = 'pet';
  static const String petGetAll = '/pets';
  static const String petById = '/pets';
  static const String petCreate = '/pets';
  static const String petUpdate = '/pets';
  static const String petDelete = '/pets';
}
