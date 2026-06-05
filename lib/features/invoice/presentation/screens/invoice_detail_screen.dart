import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/widgets/branded_app_bar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../controllers/invoice_controller.dart';
import '../../domain/entities/invoice_entity.dart';

class InvoiceDetailScreen extends ConsumerStatefulWidget {
  final String invoiceId;
  final InvoiceEntity? invoice;

  const InvoiceDetailScreen({
    super.key,
    required this.invoiceId,
    this.invoice,
  });

  @override
  ConsumerState<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends ConsumerState<InvoiceDetailScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.invoice == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(invoiceControllerProvider.notifier).fetchInvoiceDetail(widget.invoiceId);
      });
    }
  }

  InvoiceEntity? get _invoice {
    if (widget.invoice != null) return widget.invoice;
    return ref.watch(invoiceControllerProvider).selectedInvoice;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(invoiceControllerProvider);
    final invoice = _invoice;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const BrandedAppBar(
        title: "Chi tiết hóa đơn",
        showBackButton: true,
      ),
      body: state.isLoading && invoice == null
          ? const LoadingWidget(itemCount: 3)
          : invoice == null
              ? Center(
                  child: Text(
                    "Không tìm thấy hóa đơn",
                    style: context.textStyles.body
                        .copyWith(color: context.colors.textSecondary),
                  ),
                )
              : _buildContent(context, invoice),
    );
  }

  Widget _buildContent(BuildContext context, InvoiceEntity invoice) {
    final isPending = invoice.status.toLowerCase() == 'pending';
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return SingleChildScrollView(
      padding: EdgeInsets.all(context.spacing.l),
      child: Column(
        children: [
          _buildInvoiceHeader(context, invoice),
          SizedBox(height: context.spacing.l),
          _buildServicesCard(context, invoice, formatter),
          SizedBox(height: context.spacing.l),
          _buildSummaryCard(context, invoice, formatter),
          if (invoice.paymentId.isNotEmpty) ...[
            SizedBox(height: context.spacing.l),
            _buildPaymentInfoCard(context, invoice),
          ],
          SizedBox(height: context.spacing.xl),
          if (isPending)
            AppButton(
              text: "Thanh toán ngay",
              prefixIcon: const Icon(Icons.payment_rounded, color: Colors.white),
              onPressed: () {
                context.push('/payment', extra: {
                  'amount': invoice.total,
                  'description': 'Thanh toán hóa đơn #${invoice.id.substring(0, 8).toUpperCase()}',
                  'invoiceId': invoice.id,
                });
              },
            )
          else
            AppButton(
              text: "Tải hóa đơn PDF",
              prefixIcon: const Icon(Icons.download_rounded, color: Colors.white),
              backgroundColor: const Color(0xFF2E7D32),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Tính năng tải PDF đang phát triển")),
                );
              },
            ),
          SizedBox(height: context.spacing.m),
        ],
      ),
    );
  }

  Widget _buildInvoiceHeader(BuildContext context, InvoiceEntity invoice) {
    final isPaid = invoice.status.toLowerCase() == 'paid';
    final isPending = invoice.status.toLowerCase() == 'pending';

    Color statusColor;
    String statusLabel;
    IconData statusIcon;
    if (isPaid) {
      statusColor = AppColors.success;
      statusLabel = "Đã thanh toán";
      statusIcon = Icons.check_circle_rounded;
    } else if (isPending) {
      statusColor = AppColors.warning;
      statusLabel = "Chờ thanh toán";
      statusIcon = Icons.access_time_rounded;
    } else {
      statusColor = AppColors.error;
      statusLabel = "Đã hủy";
      statusIcon = Icons.cancel_rounded;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.spacing.l),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacity(0.15),
            statusColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: context.radius.lRadius,
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(statusIcon, size: 48, color: statusColor),
          SizedBox(height: context.spacing.s),
          Text(
            statusLabel,
            style: context.textStyles.bodyBold.copyWith(color: statusColor, fontSize: 16),
          ),
          SizedBox(height: context.spacing.xs),
          Text(
            "Hóa đơn #${invoice.id.substring(0, 8).toUpperCase()}",
            style: context.textStyles.caption.copyWith(color: context.colors.textHint),
          ),
          SizedBox(height: context.spacing.xs),
          Text(
            DateFormat('HH:mm - dd/MM/yyyy').format(invoice.createdAt),
            style: context.textStyles.caption.copyWith(color: context.colors.textHint),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesCard(BuildContext context, InvoiceEntity invoice,
      NumberFormat formatter) {
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
                Icon(Icons.medical_services_outlined,
                    color: context.colors.primary, size: 20),
                SizedBox(width: context.spacing.s),
                Text(
                  "DỊCH VỤ SỬ DỤNG",
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
          ...invoice.services.asMap().entries.map((entry) {
            final service = entry.value;
            final isLast = entry.key == invoice.services.length - 1;
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(context.spacing.l),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(service.name, style: context.textStyles.bodyBold),
                            if (service.quantity > 1)
                              Text(
                                "x${service.quantity} · ${formatter.format(service.price)}/lần",
                                style: context.textStyles.caption
                                    .copyWith(color: context.colors.textHint),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        formatter.format(service.total),
                        style: context.textStyles.bodyBold
                            .copyWith(color: context.colors.textPrimary),
                      ),
                    ],
                  ),
                ),
                if (!isLast) Divider(height: 1, color: context.colors.divider.withOpacity(0.5)),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, InvoiceEntity invoice,
      NumberFormat formatter) {
    return Container(
      padding: EdgeInsets.all(context.spacing.l),
      decoration: BoxDecoration(
        color: context.colors.primary.withOpacity(0.06),
        borderRadius: context.radius.lRadius,
        border: Border.all(color: context.colors.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tổng thanh toán",
                style: context.textStyles.bodyBold,
              ),
              Text(
                "${invoice.services.length} dịch vụ",
                style: context.textStyles.caption
                    .copyWith(color: context.colors.textHint),
              ),
            ],
          ),
          Text(
            formatter.format(invoice.total),
            style: context.textStyles.heading2
                .copyWith(color: context.colors.primary, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoCard(BuildContext context, InvoiceEntity invoice) {
    return Container(
      padding: EdgeInsets.all(context.spacing.m),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: context.radius.lRadius,
        border: Border.all(color: context.colors.divider),
      ),
      child: Row(
        children: [
          Icon(Icons.link_rounded, color: context.colors.textHint, size: 18),
          SizedBox(width: context.spacing.s),
          Expanded(
            child: Text(
              "Mã giao dịch: ${invoice.paymentId}",
              style: context.textStyles.caption
                  .copyWith(color: context.colors.textHint),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
