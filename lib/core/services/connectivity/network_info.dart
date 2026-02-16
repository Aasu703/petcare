import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class INetworkInfo {
  Future<bool> get isConnected;
}

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfo(Connectivity());
});

class NetworkInfo implements INetworkInfo {
  final Connectivity _connectivity;

  NetworkInfo(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    if (result.contains(ConnectivityResult.none)) {
      print('🌐 NETWORK: No connectivity detected by Connectivity plugin');
      return false;
    }

    // Perform actual internet connectivity check
    print(
      '🌐 NETWORK: Basic connectivity detected, checking actual internet access...',
    );
    return await _hasInternetConnection();
  }

  Future<bool> _hasInternetConnection() async {
    try {
      print(
        '🌐 NETWORK: Testing internet connection by looking up google.com...',
      );
      final result = await InternetAddress.lookup('google.com').timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('🌐 NETWORK: Internet lookup timed out');
          return [];
        },
      );

      final hasConnection =
          result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      print('🌐 NETWORK: Internet connection check result: $hasConnection');
      return hasConnection;
    } catch (e) {
      print('🌐 NETWORK: Internet connection check failed: $e');
      return false;
    }
  }
}
