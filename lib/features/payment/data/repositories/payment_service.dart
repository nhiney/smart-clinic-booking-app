import 'dart:math';
import 'package:smart_clinic_booking/features/payment/domain/entities/transaction_entity.dart';

class PaymentService {
  final _random = Random();

  Future<PaymentStatus> simulatePayment() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    final roll = _random.nextDouble();

    if (roll < 0.7) {
      return PaymentStatus.success;
    } else if (roll < 0.9) {
      return PaymentStatus.failed;
    } else {
      return PaymentStatus.pending;
    }
  }

  String generateTransactionId() {
    return 'TXN${DateTime.now().millisecondsSinceEpoch}${_random.nextInt(1000)}';
  }

  String generatePaymentRequestId() {
    return 'PAYREQ${DateTime.now().millisecondsSinceEpoch}${_random.nextInt(1000)}';
  }
}
