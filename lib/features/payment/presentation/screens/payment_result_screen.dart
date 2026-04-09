import 'package:flutter/material.dart';
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/widgets/app_button.dart';
import 'package:smart_clinic_booking/features/payment/domain/entities/transaction_entity.dart';
import 'package:go_router/go_router.dart';

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
    final isPending = status == PaymentStatus.pending;

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(context.spacing.l),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatusIcon(context, status),
              SizedBox(height: context.spacing.xl),
              Text(
                _getStatusTitle(status),
                style: context.textStyles.heading2
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: context.spacing.m),
              Text(
                _getStatusMessage(status, amount),
                textAlign: TextAlign.center,
                style: context.textStyles.body
                    .copyWith(color: context.colors.textSecondary),
              ),
              SizedBox(height: context.spacing.xxl),
              AppButton(
                text: "Về trang chủ",
                onPressed: () => context.go('/home'),
                backgroundColor: isSuccess
                    ? AppColors.success
                    : (isPending ? AppColors.warning : context.colors.primary),
              ),
              if (!isSuccess && !isPending) ...[
                SizedBox(height: context.spacing.m),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Thử lại",
                    style: context.textStyles.bodyBold
                        .copyWith(color: context.colors.primary),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context, PaymentStatus status) {
    IconData icon;
    Color color;
    switch (status) {
      case PaymentStatus.success:
        icon = Icons.check_circle_rounded;
        color = AppColors.success;
        break;
      case PaymentStatus.failed:
        icon = Icons.error_rounded;
        color = AppColors.error;
        break;
      case PaymentStatus.pending:
        icon = Icons.access_time_filled_rounded;
        color = AppColors.warning;
        break;
      case PaymentStatus.refunded:
        icon = Icons.undo_rounded;
        color = context.colors.textSecondary;
        break;
    }

    return Container(
      padding: EdgeInsets.all(context.spacing.l),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 80, color: color),
    );
  }

  String _getStatusTitle(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.success:
        return "Thanh toán thành công!";
      case PaymentStatus.failed:
        return "Thanh toán thất bại";
      case PaymentStatus.pending:
        return "Giao dịch đang chờ";
      case PaymentStatus.refunded:
        return "Đã hoàn tiền";
    }
  }

  String _getStatusMessage(PaymentStatus status, double amount) {
    switch (status) {
      case PaymentStatus.success:
        return "Giao dịch trị giá ${amount.toStringAsFixed(0)}đ đã được xử lý thành công.";
      case PaymentStatus.failed:
        return "Có lỗi xảy ra trong quá trình xử lý. Vui lòng kiểm tra lại số dư hoặc thử phương thức khác.";
      case PaymentStatus.pending:
        return "Giao dịch đang được xử lý bởi hệ thống ngân hàng. Vui lòng kiểm tra lịch sử giao dịch sau ít phút.";
      case PaymentStatus.refunded:
        return "Giao dịch đã được hoàn trả thành công.";
    }
  }
}
