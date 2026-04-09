import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class CheckInState {
  final String qrData;
  final DateTime validFrom;
  final DateTime expiry;
  final bool isLoading;

  CheckInState({
    required this.qrData,
    required this.validFrom,
    required this.expiry,
    this.isLoading = false,
  });

  CheckInState copyWith({
    String? qrData,
    DateTime? validFrom,
    DateTime? expiry,
    bool? isLoading,
  }) {
    return CheckInState(
      qrData: qrData ?? this.qrData,
      validFrom: validFrom ?? this.validFrom,
      expiry: expiry ?? this.expiry,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final checkInProvider =
    StateNotifierProvider<CheckInNotifier, CheckInState>((ref) {
  return CheckInNotifier();
});

class CheckInNotifier extends StateNotifier<CheckInState> {
  CheckInNotifier()
      : super(
          CheckInState(
            qrData: '',
            validFrom: DateTime.now(),
            expiry: DateTime.now(),
          ),
        );

  void generateQR(
    String userId,
    String appointmentId, {
    DateTime? appointmentTime,
  }) {
    state = state.copyWith(isLoading: true);

    final now = DateTime.now();
    final validFrom =
        appointmentTime?.subtract(const Duration(hours: 2)) ?? now;
    final expiry = appointmentTime?.add(const Duration(minutes: 5)) ??
        now.add(const Duration(hours: 2));

    final payload = {
      'userId': userId,
      'appointmentId': appointmentId,
      'validFrom': validFrom.millisecondsSinceEpoch,
      'exp': expiry.millisecondsSinceEpoch,
      'iat': now.millisecondsSinceEpoch,
    };

    final jsonPayload = jsonEncode(payload);
    final hmac = Hmac(sha256, utf8.encode('smart_clinic_secret_key'));
    final signature = hmac.convert(utf8.encode(jsonPayload));

    final token = '$jsonPayload.${signature.toString()}';

    state = state.copyWith(
      qrData: base64Encode(utf8.encode(token)),
      validFrom: validFrom,
      expiry: expiry,
      isLoading: false,
    );
  }

  bool isWithinValidityWindow(DateTime scanTime) {
    return !scanTime.isBefore(state.validFrom) &&
        !scanTime.isAfter(state.expiry);
  }
}
