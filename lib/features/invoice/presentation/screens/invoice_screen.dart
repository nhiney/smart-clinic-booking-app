import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/theme/typography/app_text_styles.dart';
import '../../../../core/widgets/branded_app_bar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/invoice_controller.dart';
import '../../domain/entities/invoice_entity.dart';
import 'package:intl/intl.dart';

class InvoiceScreen extends ConsumerStatefulWidget {
  const InvoiceScreen({super.key});

  @override
  ConsumerState<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends ConsumerState<InvoiceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshInvoices();
    });
  }

  void _refreshInvoices() {
    final auth = legacy_provider.Provider.of<AuthController>(context, listen: false);
    if (auth.currentUser != null) {
      ref.read(invoiceControllerProvider.notifier).fetchInvoices(auth.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(invoiceControllerProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const BrandedAppBar(title: "Hóa đơn của tôi"),
      body: state.isLoading
          ? const LoadingWidget(itemCount: 5)
          : state.invoices.isEmpty
              ? const EmptyStateWidget(
                  title: "Không có hóa đơn nào.",
                  icon: Icons.receipt_outlined,
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    _refreshInvoices();
                  },
                  child: ListView.separated(
                    padding: EdgeInsets.all(context.spacing.l),
                    itemCount: state.invoices.length,
                    separatorBuilder: (_, __) => SizedBox(height: context.spacing.m),
                    itemBuilder: (context, index) => _buildInvoiceCard(context, state.invoices[index]),
                  ),
                ),
    );
  }

  Widget _buildInvoiceCard(BuildContext context, InvoiceEntity invoice) {
    return AppCard(
      padding: EdgeInsets.all(context.spacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Mã HĐ: ${invoice.id.substring(0, 8).toUpperCase()}",
                style: context.textStyles.bodyBold.copyWith(color: context.colors.primary),
              ),
              _buildStatusBadge(context, invoice.status),
            ],
          ),
          SizedBox(height: context.spacing.s),
          Text(
            DateFormat('dd/MM/yyyy HH:mm').format(invoice.createdAt),
            style: context.textStyles.caption.copyWith(color: context.colors.textHint),
          ),
          Divider(height: context.spacing.l, color: context.colors.divider),
          ...invoice.services.map((service) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(service.name, style: context.textStyles.bodySmall),
                Text(
                  "${service.total.toStringAsFixed(0)}đ", 
                  style: context.textStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )),
          Divider(height: context.spacing.l, color: context.colors.divider),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Tổng cộng", style: context.textStyles.bodyBold),
              Text(
                "${invoice.total.toStringAsFixed(0)}đ",
                style: context.textStyles.heading3.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing.m),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Download PDF logic
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: context.colors.primary),
                    shape: RoundedRectangleBorder(borderRadius: context.radius.sRadius),
                  ),
                  child: Text("Tải PDF", style: TextStyle(color: context.colors.primary)),
                ),
              ),
              SizedBox(width: context.spacing.m),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Detail view
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    shape: RoundedRectangleBorder(borderRadius: context.radius.sRadius),
                  ),
                  child: const Text("Chi tiết", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    Color color = AppColors.success;
    String label = "Đã thanh toán";
    
    if (status.toLowerCase() == 'pending') {
      color = AppColors.warning;
      label = "Chờ thanh toán";
    } else if (status.toLowerCase() == 'cancelled') {
      color = AppColors.error;
      label = "Đã hủy";
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
}
