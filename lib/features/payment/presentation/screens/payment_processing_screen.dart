import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/payment_controller.dart';
import 'package:smart_clinic_booking/features/payment/domain/entities/transaction_entity.dart';
import 'payment_result_screen.dart';

class PaymentProcessingScreen extends ConsumerStatefulWidget {
  final double amount;
  final PaymentMethod method;
  final String description;
  final String userId;

  const PaymentProcessingScreen({
    super.key,
    required this.amount,
    required this.method,
    required this.description,
    required this.userId,
  });

  @override
  ConsumerState<PaymentProcessingScreen> createState() => _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends ConsumerState<PaymentProcessingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _startPayment();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startPayment() async {
    final result = await ref.read(paymentControllerProvider.notifier).pay(
      userId: widget.userId,
      amount: widget.amount,
      method: widget.method,
      description: widget.description,
    );

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentResultScreen(
            status: result,
            amount: widget.amount,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _controller,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 4, style: BorderStyle.solid),
                ),
                child: const Icon(Icons.sync, color: AppColors.primary, size: 40),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "Đang xử lý thanh toán...",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              "Vui lòng không thoát ứng dụng",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
