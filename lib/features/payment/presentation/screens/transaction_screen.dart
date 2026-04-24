import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as legacy_provider;
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/widgets/branded_app_bar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/payment_controller.dart';
import 'package:smart_clinic_booking/features/payment/domain/entities/transaction_entity.dart';
import 'package:intl/intl.dart';

class TransactionScreen extends ConsumerStatefulWidget {
  const TransactionScreen({super.key});

  @override
  ConsumerState<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends ConsumerState<TransactionScreen> {
  PaymentStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshTransactions();
    });
  }

  void _refreshTransactions() {
    final auth =
        legacy_provider.Provider.of<AuthController>(context, listen: false);
    if (auth.currentUser != null) {
      ref
          .read(paymentControllerProvider.notifier)
          .fetchTransactions(auth.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentControllerProvider);
    final filteredTransactions = _filterStatus == null
        ? state.transactions
        : state.transactions.where((t) => t.status == _filterStatus).toList();

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const BrandedAppBar(title: "Lịch sử giao dịch"),
      body: Column(
        children: [
          _buildFilters(context),
          Expanded(
            child: state.isLoading
                ? const LoadingWidget(itemCount: 5)
                : filteredTransactions.isEmpty
                    ? const EmptyStateWidget(
                        title: "Không tìm thấy giao dịch nào.",
                        icon: Icons.history_outlined,
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          _refreshTransactions();
                        },
                        child: ListView.separated(
                          padding: EdgeInsets.all(context.spacing.l),
                          itemCount: filteredTransactions.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(height: context.spacing.m),
                          itemBuilder: (context, index) =>
                              _buildTransactionCard(
                                  context, filteredTransactions[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(vertical: context.spacing.s),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: context.spacing.m),
        children: [
          _filterChip(context, null, "Tất cả"),
          _filterChip(context, PaymentStatus.success, "Thành công"),
          _filterChip(context, PaymentStatus.pending, "Đang xử lý"),
          _filterChip(context, PaymentStatus.failed, "Thất bại"),
          _filterChip(context, PaymentStatus.refunded, "Hoàn tiền"),
        ],
      ),
    );
  }

  Widget _filterChip(
      BuildContext context, PaymentStatus? status, String label) {
    final isSelected = _filterStatus == status;
    return Padding(
      padding: EdgeInsets.only(right: context.spacing.s),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) => setState(() => _filterStatus = status),
        selectedColor: context.colors.primary.withOpacity(0.2),
        checkmarkColor: context.colors.primary,
        labelStyle: context.textStyles.bodySmall.copyWith(
          color: isSelected
              ? context.colors.primary
              : context.colors.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: context.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: context.radius.mRadius,
          side: BorderSide(
              color:
                  isSelected ? context.colors.primary : context.colors.divider),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(
      BuildContext context, TransactionEntity transaction) {
    final isSuccess = transaction.status == PaymentStatus.success;

    return GestureDetector(
      onTap: () => context.push('/transactions/detail', extra: transaction),
      child: AppCard(
        padding: EdgeInsets.all(context.spacing.m),
        child: Column(
          children: [
            Row(
              children: [
                _buildMethodIcon(context, transaction.method),
                SizedBox(width: context.spacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description ?? "Thanh toán viện phí",
                        style: context.textStyles.bodyBold
                            .copyWith(color: context.colors.textPrimary),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm')
                            .format(transaction.createdAt),
                        style: context.textStyles.caption
                            .copyWith(color: context.colors.textHint),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${transaction.amount.toStringAsFixed(0)}đ",
                      style: context.textStyles.bodyBold.copyWith(
                        color: context.colors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    _buildStatusBadge(context, transaction.status),
                  ],
                ),
              ],
            ),
            if (isSuccess) ...[
              Divider(height: context.spacing.l, color: context.colors.divider),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _handleRefund(transaction),
                    icon: const Icon(Icons.undo, size: 18),
                    label: const Text("Hoàn tiền"),
                    style: TextButton.styleFrom(
                      foregroundColor: context.colors.textSecondary,
                      padding:
                          EdgeInsets.symmetric(horizontal: context.spacing.m),
                    ),
                  ),
                  SizedBox(width: context.spacing.s),
                  OutlinedButton.icon(
                    onPressed: () {
                      if (transaction.invoiceId != null) {
                        context.push('/invoices/detail',
                            extra: {'invoiceId': transaction.invoiceId});
                      } else {
                        context.push('/invoices');
                      }
                    },
                    icon: const Icon(Icons.receipt_long, size: 18),
                    label: const Text("Hóa đơn"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.colors.primary,
                      side: BorderSide(color: context.colors.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: context.radius.sRadius),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMethodIcon(BuildContext context, PaymentMethod method) {
    IconData iconData;
    Color color;
    switch (method) {
      case PaymentMethod.vnpay:
        iconData = Icons.account_balance;
        color = Colors.blue;
        break;
      case PaymentMethod.momo:
        iconData = Icons.wallet;
        color = Colors.pink;
        break;
      case PaymentMethod.stripe:
        iconData = Icons.credit_card;
        color = Colors.deepPurple;
        break;
    }
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: context.radius.sRadius,
      ),
      child: Icon(iconData, color: color),
    );
  }

  Widget _buildStatusBadge(BuildContext context, PaymentStatus status) {
    Color color;
    String label;
    switch (status) {
      case PaymentStatus.success:
        color = AppColors.success;
        label = "Thành công";
        break;
      case PaymentStatus.failed:
        color = AppColors.error;
        label = "Thất bại";
        break;
      case PaymentStatus.pending:
        color = AppColors.warning;
        label = "Đang xử lý";
        break;
      case PaymentStatus.refunded:
        color = context.colors.textSecondary;
        label = "Đã hoàn tiền";
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: context.radius.xsRadius,
      ),
      child: Text(
        label,
        style: context.textStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Future<void> _handleRefund(TransactionEntity transaction) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận hoàn tiền"),
        content:
            const Text("Bạn có chắc chắn muốn hoàn trả giao dịch này không?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Hủy")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                Text("Xác nhận", style: TextStyle(color: context.colors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final auth =
          legacy_provider.Provider.of<AuthController>(context, listen: false);
      await ref
          .read(paymentControllerProvider.notifier)
          .refund(auth.currentUser!.id, transaction.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Yêu cầu hoàn tiền đã được xử lý.")),
        );
      }
    }
  }
}
