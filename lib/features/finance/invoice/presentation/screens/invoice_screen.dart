import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:smart_clinic_booking/core/theme/colors/app_colors.dart';
import 'package:smart_clinic_booking/core/widgets/branded_app_bar.dart';
import 'package:smart_clinic_booking/core/widgets/app_card.dart';
import 'package:smart_clinic_booking/core/extensions/context_extension.dart';
import 'package:smart_clinic_booking/shared/widgets/loading_widget.dart';
import 'package:smart_clinic_booking/shared/widgets/empty_state_widget.dart';
import 'package:smart_clinic_booking/features/identity/auth/presentation/controllers/auth_controller.dart';
import '../controllers/invoice_controller.dart';
import '../../domain/entities/invoice_entity.dart';
import '../utils/invoice_pdf.dart';
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
      appBar: const BrandedAppBar(
        title: "Hóa đơn của tôi",
        showBackButton: true,
      ),
      body: state.isLoading
          ? const LoadingWidget(itemCount: 5)
          : RefreshIndicator(
              onRefresh: () async { _refreshInvoices(); },
              child: ListView.separated(
                padding: EdgeInsets.all(context.spacing.l),
                itemCount: _displayInvoices(state.invoices).length,
                separatorBuilder: (_, __) => SizedBox(height: context.spacing.m),
                itemBuilder: (context, index) => _buildInvoiceCard(context, _displayInvoices(state.invoices)[index]),
              ),
            ),
    );
  }

  static final List<InvoiceEntity> _mockInvoices = [
    InvoiceEntity(
      id: '23052026045100000001',
      userId: 'demo',
      services: const [
        InvoiceItem(name: 'Phí khám tim mạch chuyên sâu', price: 350000),
        InvoiceItem(name: 'Điện tâm đồ ECG', price: 150000),
        InvoiceItem(name: 'Siêu âm tim 2D', price: 280000),
        InvoiceItem(name: 'Xét nghiệm máu tổng quát', price: 180000),
      ],
      total: 960000,
      paymentId: 'VNPAY-2305-0451',
      status: 'pending',
      createdAt: DateTime(2026, 5, 23, 10, 42),
    ),
    InvoiceEntity(
      id: '12042026030200000002',
      userId: 'demo',
      services: const [
        InvoiceItem(name: 'Phí khám nội tổng quát', price: 200000),
        InvoiceItem(name: 'Xét nghiệm đường huyết', price: 80000),
      ],
      total: 280000,
      paymentId: 'VNPAY-1204-0302',
      status: 'paid',
      createdAt: DateTime(2026, 4, 12, 14, 20),
    ),
  ];

  List<InvoiceEntity> _displayInvoices(List<InvoiceEntity> real) =>
      real.isEmpty ? _mockInvoices : real;

  Widget _buildInvoiceCard(BuildContext context, InvoiceEntity invoice) {
    final bool isPending = invoice.status.toLowerCase() == 'pending';
    
    return Container(
      margin: EdgeInsets.only(bottom: context.spacing.m),
      child: AppCard(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(bottom: BorderSide(color: context.colors.divider.withValues(alpha: 0.5))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Hóa đơn #${invoice.id.substring(0, 8).toUpperCase()}",
                    style: context.textStyles.bodyBold.copyWith(color: context.colors.primary),
                  ),
                  _buildStatusBadge(context, invoice.status),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(invoice.createdAt),
                    style: context.textStyles.bodySmall.copyWith(color: context.colors.textHint),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "DỊCH VỤ SỬ DỤNG",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 12),
                  ...invoice.services.map((service) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(service.name, style: context.textStyles.bodySmall)),
                        Text(
                          NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(service.total), 
                          style: context.textStyles.bodySmall.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Tổng thanh toán", style: context.textStyles.bodyBold),
                        Text(
                          NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(invoice.total),
                          style: context.textStyles.heading3.copyWith(color: context.colors.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push(
                            '/invoices/detail',
                            extra: {'invoiceId': invoice.id, 'invoice': invoice},
                          ),
                          icon: const Icon(Icons.description_outlined, size: 18),
                          label: const Text("Chi tiết"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.colors.textSecondary,
                            side: BorderSide(color: context.colors.divider),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isPending
                              ? () => context.push('/payment', extra: {
                                    'amount': invoice.total,
                                    'description': 'Thanh toán hóa đơn #${invoice.id.substring(0, 8).toUpperCase()}',
                                    'invoiceId': invoice.id,
                                  })
                              : () async {
                                  try {
                                    await InvoicePdf.shareInvoice(invoice);
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Không tạo được PDF: $e')),
                                      );
                                    }
                                  }
                                },
                          icon: Icon(isPending ? Icons.payment_rounded : Icons.download_rounded, size: 18),
                          label: Text(isPending ? "Thanh toán" : "Tải về"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isPending ? context.colors.primary : const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _showInvoiceDetail(BuildContext context, InvoiceEntity invoice) {
    final fmt = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          const Text('Chi tiết hóa đơn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Mã: #${invoice.id.substring(0, 8).toUpperCase()}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(height: 16),
          const Divider(),
          ...invoice.services.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                if (item.quantity > 1) Text('× ${item.quantity}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ])),
              Text(fmt.format(item.total), style: const TextStyle(fontWeight: FontWeight.w700)),
            ]),
          )),
          const Divider(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Tổng cộng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(fmt.format(invoice.total),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary)),
          ]),
          const SizedBox(height: 8),
          Text('Ngày tạo: ${dateFmt.format(invoice.createdAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ]),
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
        color: color.withValues(alpha: 0.1),
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
