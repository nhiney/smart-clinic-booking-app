import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/widgets/branded_app_bar.dart';
import '../../../../core/extensions/context_extension.dart';
import 'package:smart_clinic_booking/features/payment/domain/entities/transaction_entity.dart';
import '../controllers/payment_controller.dart';
import 'package:provider/provider.dart' as legacy_provider;
import '../../../auth/presentation/controllers/auth_controller.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final TransactionEntity transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: BrandedAppBar(
        title: "Chi tiết giao dịch",
        showBackButton: true,
        actions: [
          IconButton(
            icon: Icon(Icons.copy_rounded, color: context.colors.primary),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: transaction.id));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Đã sao chép mã giao dịch")),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.spacing.l),
        child: Column(
          children: [
            _buildStatusCard(context, formatter),
            SizedBox(height: context.spacing.l),
            _buildDetailsCard(context),
            SizedBox(height: context.spacing.l),
            _buildTimelineCard(context),
            if (transaction.status == PaymentStatus.success) ...[
              SizedBox(height: context.spacing.l),
              _buildActionsCard(context, ref),
            ],
            SizedBox(height: context.spacing.m),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, NumberFormat formatter) {
    final color = _statusColor(context, transaction.status);
    final icon = _statusIcon(transaction.status);
    final label = _statusLabel(transaction.status);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.spacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.04)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: context.radius.lRadius,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(context.spacing.m),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: color),
          ),
          SizedBox(height: context.spacing.m),
          Text(
            formatter.format(transaction.amount),
            style: context.textStyles.heading1
                .copyWith(color: context.colors.textPrimary, fontSize: 32),
          ),
          SizedBox(height: context.spacing.xs),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: context.spacing.m, vertical: context.spacing.xs),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: context.radius.lRadius,
            ),
            child: Text(
              label,
              style: context.textStyles.bodySmall.copyWith(
                  color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    return _SectionCard(
      title: "Thông tin giao dịch",
      icon: Icons.receipt_long_outlined,
      children: [
        _DetailRow(
          label: "Mã giao dịch",
          value: transaction.id,
          monospace: true,
          maxLines: 2,
        ),
        _DetailRow(
          label: "Phương thức",
          value: _methodLabel(transaction.method),
          valueIcon: _methodIcon(transaction.method),
          valueIconColor: _methodColor(transaction.method),
        ),
        _DetailRow(
          label: "Mô tả",
          value: transaction.description ?? "Thanh toán dịch vụ y tế",
        ),
        if (transaction.invoiceId != null)
          _DetailRow(
            label: "Hóa đơn",
            value: "#${transaction.invoiceId!.substring(0, 8).toUpperCase()}",
            isLink: true,
            onTap: () => context.push('/invoices/detail',
                extra: {'invoiceId': transaction.invoiceId}),
          ),
        if (transaction.appointmentId != null)
          _DetailRow(
            label: "Lịch hẹn",
            value: "#${transaction.appointmentId!.substring(0, 8).toUpperCase()}",
          ),
        _DetailRow(
          label: "Mã yêu cầu",
          value: transaction.paymentRequestId,
          monospace: true,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildTimelineCard(BuildContext context) {
    return _SectionCard(
      title: "Thời gian",
      icon: Icons.schedule_rounded,
      children: [
        _DetailRow(
          label: "Tạo lúc",
          value: DateFormat('HH:mm:ss - dd/MM/yyyy').format(transaction.createdAt),
        ),
        if (transaction.updatedAt != null)
          _DetailRow(
            label: "Cập nhật",
            value: DateFormat('HH:mm:ss - dd/MM/yyyy').format(transaction.updatedAt!),
          ),
      ],
    );
  }

  Widget _buildActionsCard(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: context.radius.lRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: EdgeInsets.all(context.spacing.s),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: context.radius.sRadius,
              ),
              child: const Icon(Icons.undo_rounded, color: AppColors.error, size: 20),
            ),
            title: const Text("Yêu cầu hoàn tiền"),
            subtitle: Text(
              "Hủy giao dịch và hoàn lại số tiền",
              style: context.textStyles.caption
                  .copyWith(color: context.colors.textHint),
            ),
            trailing: Icon(Icons.chevron_right_rounded,
                color: context.colors.textHint),
            onTap: () => _handleRefund(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRefund(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận hoàn tiền"),
        content: const Text(
            "Bạn có chắc chắn muốn hoàn trả giao dịch này không?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Hủy")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text("Xác nhận",
                style: TextStyle(color: context.colors.error)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final auth = legacy_provider.Provider.of<AuthController>(context, listen: false);
      await ref
          .read(paymentControllerProvider.notifier)
          .refund(auth.currentUser!.id, transaction.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Yêu cầu hoàn tiền đã được xử lý.")),
        );
        context.pop();
      }
    }
  }

  Color _statusColor(BuildContext context, PaymentStatus status) {
    switch (status) {
      case PaymentStatus.success:
        return AppColors.success;
      case PaymentStatus.failed:
        return AppColors.error;
      case PaymentStatus.pending:
        return AppColors.warning;
      case PaymentStatus.refunded:
        return context.colors.textSecondary;
    }
  }

  IconData _statusIcon(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.success:
        return Icons.check_circle_rounded;
      case PaymentStatus.failed:
        return Icons.error_rounded;
      case PaymentStatus.pending:
        return Icons.access_time_filled_rounded;
      case PaymentStatus.refunded:
        return Icons.undo_rounded;
    }
  }

  String _statusLabel(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.success:
        return "Thành công";
      case PaymentStatus.failed:
        return "Thất bại";
      case PaymentStatus.pending:
        return "Đang xử lý";
      case PaymentStatus.refunded:
        return "Đã hoàn tiền";
    }
  }

  String _methodLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.vnpay:
        return "VNPay";
      case PaymentMethod.momo:
        return "MoMo";
      case PaymentMethod.stripe:
        return "Stripe (Visa/Mastercard)";
    }
  }

  IconData _methodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.vnpay:
        return Icons.account_balance;
      case PaymentMethod.momo:
        return Icons.wallet;
      case PaymentMethod.stripe:
        return Icons.credit_card;
    }
  }

  Color _methodColor(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.vnpay:
        return Colors.blue;
      case PaymentMethod.momo:
        return Colors.pink;
      case PaymentMethod.stripe:
        return Colors.deepPurple;
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: context.radius.lRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
                context.spacing.l, context.spacing.l, context.spacing.l, context.spacing.m),
            child: Row(
              children: [
                Icon(icon, color: context.colors.primary, size: 18),
                SizedBox(width: context.spacing.s),
                Text(
                  title.toUpperCase(),
                  style: context.textStyles.caption.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: context.colors.divider),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool monospace;
  final int maxLines;
  final bool isLink;
  final VoidCallback? onTap;
  final IconData? valueIcon;
  final Color? valueIconColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.monospace = false,
    this.maxLines = 1,
    this.isLink = false,
    this.onTap,
    this.valueIcon,
    this.valueIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: context.spacing.l, vertical: context.spacing.m),
        child: Row(
          crossAxisAlignment: maxLines > 1
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              child: Text(
                label,
                style: context.textStyles.bodySmall
                    .copyWith(color: context.colors.textHint),
              ),
            ),
            SizedBox(width: context.spacing.m),
            Expanded(
              child: Row(
                children: [
                  if (valueIcon != null) ...[
                    Icon(valueIcon, size: 16, color: valueIconColor),
                    SizedBox(width: context.spacing.xs),
                  ],
                  Expanded(
                    child: Text(
                      value,
                      style: context.textStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        fontFamily: monospace ? 'monospace' : null,
                        color: isLink ? context.colors.primary : context.colors.textPrimary,
                        decoration: isLink ? TextDecoration.underline : null,
                      ),
                      maxLines: maxLines,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isLink)
                    Icon(Icons.open_in_new_rounded,
                        size: 14, color: context.colors.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
