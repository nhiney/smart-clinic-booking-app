import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/branded_app_bar.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/payment_controller.dart';
import 'package:smart_clinic_booking/features/payment/domain/entities/transaction_entity.dart';

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
      final auth = legacy_provider.Provider.of<AuthController>(context, listen: false);
      if (auth.currentUser != null) {
        ref.read(paymentControllerProvider.notifier).fetchTransactions(auth.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentControllerProvider);
    final filteredTransactions = _filterStatus == null 
      ? state.transactions 
      : state.transactions.where((t) => t.status == _filterStatus).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BrandedAppBar(title: "Lịch sử giao dịch"),
      body: Column(
        children: [
          _buildFilters(),
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
                          final auth = legacy_provider.Provider.of<AuthController>(context, listen: false);
                          await ref.read(paymentControllerProvider.notifier).fetchTransactions(auth.currentUser!.id);
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: filteredTransactions.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) => _buildTransactionCard(filteredTransactions[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _filterChip(null, "Tất cả"),
          _filterChip(PaymentStatus.success, "Thành công"),
          _filterChip(PaymentStatus.failed, "Thất bại"),
          _filterChip(PaymentStatus.refunded, "Hoàn tiền"),
        ],
      ),
    );
  }

  Widget _filterChip(PaymentStatus? status, String label) {
    final isSelected = _filterStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) => setState(() => _filterStatus = status),
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      ),
    );
  }

  Widget _buildTransactionCard(TransactionEntity transaction) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          _buildMethodIcon(transaction.method),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.description ?? "Thanh toán viện phí", style: AppTextStyles.bodyBold),
                Text(
                  "${transaction.createdAt.day}/${transaction.createdAt.month}/${transaction.createdAt.year}",
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${transaction.amount.toStringAsFixed(0)}đ",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              _buildStatusBadge(transaction.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMethodIcon(PaymentMethod method) {
    IconData iconData;
    Color color;
    switch (method) {
      case PaymentMethod.vnpay: iconData = Icons.account_balance; color = Colors.blue; break;
      case PaymentMethod.momo: iconData = Icons.wallet; color = Colors.pink; break;
      case PaymentMethod.stripe: iconData = Icons.credit_card; color = Colors.deepPurple; break;
    }
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Icon(iconData, color: color),
    );
  }

  Widget _buildStatusBadge(PaymentStatus status) {
    Color color;
    String label;
    switch (status) {
      case PaymentStatus.success: color = Colors.green; label = "Thành công"; break;
      case PaymentStatus.failed: color = Colors.red; label = "Thất bại"; break;
      case PaymentStatus.pending: color = Colors.orange; label = "Đang xử lý"; break;
      case PaymentStatus.refunded: color = Colors.blue; label = "Đã hoàn tiền"; break;
    }
    return Text(
      label,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
    );
  }
}
