import 'dart:math';
import 'package:smart_clinic_booking/features/payment/domain/entities/transaction_entity.dart';

class PaymentService {
  final _random = Random();

  Future<PaymentStatus> processPayment(PaymentMethod method, double amount) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate 80% success rate
    final isSuccess = _random.nextDouble() < 0.8;
    
    if (isSuccess) {
      return PaymentStatus.success;
    } else {
      return PaymentStatus.failed;
    }
  }

  String generateTransactionId() {
    return 'TXN${DateTime.now().millisecondsSinceEpoch}${_random.nextInt(1000)}';
  }
}
