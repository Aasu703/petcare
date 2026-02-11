import 'dart:io';

class ApiEndpoints {
  ApiEndpoints._();

  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5050/';
    } else {
      return 'http://localhost:5050/';
    }
  }

  static String get mediaServerUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5050/';
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

  // ----------------------- BOOKING -------------------------
  static const String bookingCreate = 'api/booking';
  static const String bookingList = 'api/booking';
  static const String bookingById = 'api/booking';
  static const String bookingUpdate = 'api/booking';
  static const String bookingDelete = 'api/booking';
  static const String bookingByUser = 'api/booking/user';
  static const String providerBookings = 'api/provider/booking/my';
  static const String providerBookingStatus = 'api/provider/booking';

  // ---------------------- INVENTORY ------------------------
  static const String inventoryByProvider = 'api/provider/inventory';
  static const String inventoryCreate = 'api/provider/inventory';
  static const String inventoryUpdate = 'api/provider/inventory';
  static const String inventoryDelete = 'api/provider/inventory';
  static const String inventoryById = 'api/provider/inventory';

  // ----------------------- ORDER ---------------------------
  static const String orderCreate = 'api/order';
  static const String orderMy = 'api/order/my';
  static const String orderById = 'api/order';
  static const String orderUpdate = 'api/order';
  static const String orderDelete = 'api/order';
}
