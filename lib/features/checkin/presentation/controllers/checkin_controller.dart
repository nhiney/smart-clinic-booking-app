import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class CheckInState {
  final String qrData;
  final DateTime expiry;
  final bool isLoading;

  CheckInState({
    required this.qrData,
    required this.expiry,
    this.isLoading = false,
  });

  CheckInState copyWith({
    String? qrData,
    DateTime? expiry,
    bool? isLoading,
  }) {
    return CheckInState(
      qrData: qrData ?? this.qrData,
      expiry: expiry ?? this.expiry,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final checkInProvider = StateNotifierProvider<CheckInNotifier, CheckInState>((ref) {
  return CheckInNotifier();
});

class CheckInNotifier extends StateNotifier<CheckInState> {
  CheckInNotifier() : super(CheckInState(qrData: '', expiry: DateTime.now()));

  void generateQR(String userId, String appointmentId) {
    state = state.copyWith(isLoading: true);
    
    final now = DateTime.now();
    final expiry = now.add(const Duration(minutes: 5)); // 5 mins expiry
    
    // Create a signed token (mock)
    final payload = {
      'userId': userId,
      'appointmentId': appointmentId,
      'exp': expiry.millisecondsSinceEpoch,
    };
    
    final jsonPayload = jsonEncode(payload);
    final hmac = Hmac(sha256, utf8.encode('smart_clinic_secret_key'));
    final signature = hmac.convert(utf8.encode(jsonPayload));
    
    final token = '$jsonPayload.${signature.toString()}';
    
    state = state.copyWith(
      qrData: base64Encode(utf8.encode(token)),
      expiry: expiry,
      isLoading: false,
    );
  }
}
