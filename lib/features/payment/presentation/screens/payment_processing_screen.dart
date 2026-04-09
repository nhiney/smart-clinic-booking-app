import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/extensions/context_extension.dart';
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
  ConsumerState<PaymentProcessingScreen> createState() =>
      _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState
    extends ConsumerState<PaymentProcessingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
    _startPayment();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startPayment() async {
    // 2s simulation delay (already in PaymentService.simulatePayment)
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
      backgroundColor: context.colors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _controller,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: context.colors.primary, width: 2),
                ),
                child: Center(
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.primary.withOpacity(0.1),
                    ),
                    child: Icon(Icons.sync,
                        color: context.colors.primary, size: 40),
                  ),
                ),
              ),
            ),
            SizedBox(height: context.spacing.xxl),
            Text(
              "Đang xử lý thanh toán...",
              style: context.textStyles.heading3
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: context.spacing.m),
            Text(
              "Vui lòng không thoát ứng dụng",
              style: context.textStyles.bodySmall
                  .copyWith(color: context.colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
