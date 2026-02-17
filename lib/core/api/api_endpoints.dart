import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // configure base URL based on platform
  static const bool isPhysicalDevice =
      true; // Set to true for physical device testing, false for emulator/simulator
  static const String _ipAddress = '192.168.1.4';
  static const int _port = 5050;

  // Base URL configuration
  static String get _host {
    if (isPhysicalDevice) return _ipAddress;
    if (kIsWeb || Platform.isIOS) return 'localhost';
    if (Platform.isAndroid) return '10.0.2.2';
    return 'localhost';
  }

  static String get serverUrl => 'http://$_host:$_port/';
  static String get baseUrl => '${serverUrl}api/';
  static String get mediaUrl => '${serverUrl}media/';

  static String resolveMediaUrl(String path) {
    if (path.isEmpty) return mediaUrl;
    final normalized = path.startsWith('/') ? path.substring(1) : path;
    return '$mediaUrl$normalized';
  }

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // -------------------------- AUTH -------------------------
  static const String user = 'auth/user';
  static const String userLogin = 'auth/login';
  static const String userRegister = 'auth/register';
  static const String userWhoAmI = 'auth/whoami';
  static const String userUploadPhoto = 'auth/update-profile';
  static String userPicture(String filename) =>
      resolveMediaUrl('user_photos/$filename');
  // ------------------------ PROVIDER -----------------------
  static const String provider = 'provider';
  static const String providerLogin = 'login';
  static const String providerRegister = 'register';

  static const String providerGetAll = 'provider';
  static const String providerById = 'provider';
  static const String providerCreate = 'provider';
  static const String providerUpdate = 'provider';
  static const String providerDelete = 'provider';

  // ------------------ PROVIDER SERVICE --------------------
  static const String providerServiceApply = 'provider/provider-service/apply';
  static const String providerServiceMy = 'provider/provider-service/my';
  static const String providerServiceById = 'provider/provider-service';

  // ------------------------ PET ----------------------------
  static const String petGetAll = 'user/pet';
  static const String petById = 'user/pet';
  static const String petCreate = 'user/pet';
  static const String petUpdate = 'user/pet';
  static const String petDelete = 'user/pet';

  // ----------------------- BOOKING -------------------------
  static const String bookingCreate = 'booking';
  static const String bookingList = 'booking';
  static const String bookingById = 'booking';
  static const String bookingUpdate = 'booking';
  static const String bookingDelete = 'booking';
  static const String bookingByUser = 'booking/user';
  static const String providerBookings = 'provider/booking/my';
  static const String providerBookingStatus = 'provider/booking';

  // ----------------------- SERVICE -------------------------
  static const String serviceList = 'service';
  static const String serviceById = 'service';
  static const String serviceByProvider = 'service/provider';

  // ---------------------- INVENTORY ------------------------
  static const String products = 'product';
  static const String inventoryByProvider = 'product/provider';
  static const String inventoryCreate = 'provider/inventory';
  static const String inventoryUpdate = 'provider/inventory';
  static const String inventoryDelete = 'provider/inventory';
  static const String inventoryById = 'product';

  // ----------------------- ORDER ---------------------------
  static const String orderCreate = 'order';
  static const String orderMy = 'order/my';
  static const String orderById = 'order';
  static const String orderUpdate = 'order';
  static const String orderDelete = 'order';

  // -------------------- HEALTH RECORD ----------------------
  static const String healthRecord = 'health-record';
  static const String healthRecordByPet = 'health-record/pet';

  // ----------------------- MESSAGE -------------------------
  static const String messageList = 'message';
  static const String messageMy = 'message/my';
  static const String messageById = 'message';

  // ------------------------ POST ---------------------------
  static const String postAll = 'post';
  static const String postCreate = 'provider/post';
  static const String postMy = 'provider/post/my';
  static const String postById = 'provider/post';

  // ------------------------- CART --------------------------
  static const String cartGet = 'cart';
  static const String cartAdd = 'cart/add';
  static const String cartUpdateItem = 'cart/item';
  static const String cartRemoveItem = 'cart/item';
  static const String cartUpdate = 'cart';
  static const String cartClear = 'cart';
}
