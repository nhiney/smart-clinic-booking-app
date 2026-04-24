import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as legacy_provider;
import '../../../../core/widgets/branded_app_bar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import 'package:smart_clinic_booking/features/payment/domain/entities/transaction_entity.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final double amount;
  final String description;
  final String? invoiceId;
  final String? appointmentId;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.description,
    this.invoiceId,
    this.appointmentId,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  PaymentMethod _selectedMethod = PaymentMethod.vnpay;

  @override
  Widget build(BuildContext context) {
    final authController =
        legacy_provider.Provider.of<AuthController>(context, listen: false);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const BrandedAppBar(
        title: "Thanh toán",
        showBackButton: true,
      ),
      body: Column(
        children: [
          _buildAmountCard(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(context.spacing.l),
              children: [
                Text("Chọn phương thức thanh toán",
                    style: context.textStyles.subtitle
                        .copyWith(fontWeight: FontWeight.bold)),
                SizedBox(height: context.spacing.m),
                _buildMethodTile(
                  PaymentMethod.vnpay,
                  "VNPay",
                  Icons.account_balance_wallet_outlined,
                  context.colors.primary.withOpacity(0.1),
                ),
                _buildMethodTile(
                  PaymentMethod.momo,
                  "MoMo",
                  Icons.phone_android_outlined,
                  Colors.pink.withOpacity(0.1),
                ),
                _buildMethodTile(
                  PaymentMethod.stripe,
                  "Stripe (Visa/Mastercard)",
                  Icons.credit_card_outlined,
                  Colors.deepPurple.withOpacity(0.1),
                ),
              ],
            ),
          ),
          _buildPayButton(authController),
        ],
      ),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.spacing.xxl),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius:
            BorderRadius.vertical(bottom: context.radius.xlRadius.bottomLeft),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text("Tổng thanh toán",
              style: context.textStyles.body
                  .copyWith(color: context.colors.textSecondary)),
          SizedBox(height: context.spacing.s),
          Text(
            "${widget.amount.toStringAsFixed(0)}đ",
            style: context.textStyles.heading1
                .copyWith(color: context.colors.primary, fontSize: 36),
          ),
          SizedBox(height: context.spacing.s),
          Text(widget.description, style: context.textStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildMethodTile(
      PaymentMethod method, String title, IconData icon, Color bgColor) {
    final isSelected = _selectedMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: Container(
        margin: EdgeInsets.only(bottom: context.spacing.m),
        padding: EdgeInsets.all(context.spacing.m),
        decoration: BoxDecoration(
          color: isSelected ? bgColor : context.colors.surface,
          borderRadius: context.radius.mRadius,
          border: Border.all(
            color: isSelected ? context.colors.primary : context.colors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? context.colors.surface
                    : context.colors.background,
                borderRadius: context.radius.sRadius,
              ),
              child: Icon(icon,
                  color: isSelected
                      ? context.colors.primary
                      : context.colors.textHint),
            ),
            SizedBox(width: context.spacing.m),
            Expanded(child: Text(title, style: context.textStyles.bodyBold)),
            if (isSelected)
              Icon(Icons.check_circle, color: context.colors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildPayButton(AuthController auth) {
    return Container(
      padding: EdgeInsets.all(context.spacing.l),
      decoration: BoxDecoration(
        color: context.colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: AppButton(
          text: "Thanh toán ngay",
          onPressed: () {
            context.push('/payment/processing', extra: {
              'amount': widget.amount,
              'method': _selectedMethod,
              'description': widget.description,
              'userId': auth.currentUser!.id,
              'invoiceId': widget.invoiceId,
              'appointmentId': widget.appointmentId,
            });
          },
        ),
      ),
    );
  }
}
