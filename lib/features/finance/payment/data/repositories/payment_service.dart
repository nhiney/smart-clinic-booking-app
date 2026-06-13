import 'package:smart_clinic_booking/features/finance/payment/domain/entities/transaction_entity.dart';

// Sandbox payment processor — all methods are deterministic (no randomness).
// Replace this class with a real gateway (VNPay, MoMo) when credentials are available.
class PaymentService {
  /// Validates amount and simulates gateway round-trip (always succeeds in sandbox).
  Future<PaymentStatus> processPayment(double amount, PaymentMethod method) async {
    if (amount <= 0) return PaymentStatus.failed;

    // Realistic network round-trip per gateway
    final delay = switch (method) {
      PaymentMethod.momo   => const Duration(milliseconds: 1800),
      PaymentMethod.vnpay  => const Duration(milliseconds: 2200),
      PaymentMethod.stripe => const Duration(milliseconds: 1500),
    };
    await Future.delayed(delay);
    return PaymentStatus.success;
  }

  String generateTransactionId() =>
      'TXN${DateTime.now().millisecondsSinceEpoch}';

  String generatePaymentRequestId() =>
      'PAYREQ${DateTime.now().millisecondsSinceEpoch}';
}
