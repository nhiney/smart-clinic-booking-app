import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkListener extends ChangeNotifier {
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  late StreamSubscription<List<ConnectivityResult>> _subscription;

  NetworkListener() {
    _init();
  }

  void _init() async {
    final connectivity = Connectivity();
    
    // Kiểm tra trạng thái ban đầu
    final results = await connectivity.checkConnectivity();
    _updateStatus(results);

    // Lắng nghe thay đổi
    _subscription = connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    // Nếu có bất kỳ kết nối nào khác 'none' thì coi là Online
    final hasConnection = results.any((result) => result != ConnectivityResult.none);
    
    if (_isOnline != hasConnection) {
      _isOnline = hasConnection;
      notifyListeners();
      debugPrint('[NETWORK] Trạng thái mạng: ${_isOnline ? 'ONLINE' : 'OFFLINE'}');
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
