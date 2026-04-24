import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extension.dart';
import '../controllers/payment_controller.dart';
import 'package:smart_clinic_booking/features/payment/domain/entities/transaction_entity.dart';
import 'payment_result_screen.dart';

class PaymentProcessingScreen extends ConsumerStatefulWidget {
  final double amount;
  final PaymentMethod method;
  final String description;
  final String userId;
  final String? invoiceId;
  final String? appointmentId;

  const PaymentProcessingScreen({
    super.key,
    required this.amount,
    required this.method,
    required this.description,
    required this.userId,
    this.invoiceId,
    this.appointmentId,
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
    final result = await ref.read(paymentControllerProvider.notifier).pay(
          userId: widget.userId,
          amount: widget.amount,
          method: widget.method,
          description: widget.description,
          invoiceId: widget.invoiceId,
          appointmentId: widget.appointmentId,
        );

    if (mounted) {
      final currentTx = ref.read(paymentControllerProvider).currentTransaction;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentResultScreen(
            status: result,
            amount: widget.amount,
            transactionId: currentTx?.id,
            invoiceId: widget.invoiceId,
          ),
        ),
      );
    }
  }

  String _getMethodLabel() {
    switch (widget.method) {
      case PaymentMethod.vnpay:
        return 'VNPay';
      case PaymentMethod.momo:
        return 'MoMo';
      case PaymentMethod.stripe:
        return 'Stripe';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(context.spacing.xl),
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
                    border: Border.all(color: context.colors.primary, width: 3),
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
                "Qua ${_getMethodLabel()} · ${widget.amount.toStringAsFixed(0)}đ",
                style: context.textStyles.body
                    .copyWith(color: context.colors.primary, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: context.spacing.s),
              Text(
                "Vui lòng không thoát ứng dụng",
                style: context.textStyles.bodySmall
                    .copyWith(color: context.colors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
