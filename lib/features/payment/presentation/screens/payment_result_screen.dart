import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:smart_clinic_booking/features/payment/domain/entities/transaction_entity.dart';

class PaymentResultScreen extends StatelessWidget {
  final PaymentStatus status;
  final double amount;

  const PaymentResultScreen({
    super.key,
    required this.status,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = status == PaymentStatus.success;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                size: 100,
                color: isSuccess ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 24),
              Text(
                isSuccess ? "Thanh toán thành công!" : "Thanh toán thất bại",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                isSuccess 
                  ? "Giao dịch trị giá ${amount.toStringAsFixed(0)}đ đã được xử lý thành công."
                  : "Có lỗi xảy ra trong quá trình xử lý. Vui lòng thử lại sau.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSuccess ? Colors.green : AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Về trang chủ", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              if (!isSuccess) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Thử lại", style: TextStyle(color: AppColors.primary)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
