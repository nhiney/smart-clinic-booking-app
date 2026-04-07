import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/theme/typography/app_text_styles.dart';
import '../../../../core/widgets/branded_app_bar.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/payment_controller.dart';
import 'package:smart_clinic_booking/features/payment/domain/entities/transaction_entity.dart';
import 'payment_processing_screen.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final double amount;
  final String description;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.description,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  PaymentMethod _selectedMethod = PaymentMethod.vnpay;

  @override
  Widget build(BuildContext context) {
    final authController = legacy_provider.Provider.of<AuthController>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BrandedAppBar(title: "Thanh toán"),
      body: Column(
        children: [
          _buildAmountCard(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text("Chọn phương thức thanh toán", style: AppTextStyles.subtitle),
                const SizedBox(height: 16),
                _buildMethodTile(
                  PaymentMethod.vnpay,
                  "VNPay",
                  "assets/icons/vnpay.png",
                  Colors.blue[50]!,
                ),
                _buildMethodTile(
                  PaymentMethod.momo,
                  "MoMo",
                  "assets/icons/momo.png",
                  Colors.pink[50]!,
                ),
                _buildMethodTile(
                  PaymentMethod.stripe,
                  "Stripe (Visa/Mastercard)",
                  "assets/icons/stripe.png",
                  Colors.deepPurple[50]!,
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
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Text("Tổng thanh toán", style: AppTextStyles.body),
          const SizedBox(height: 8),
          Text(
            "${widget.amount.toStringAsFixed(0)}đ",
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(widget.description, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildMethodTile(PaymentMethod method, String title, String iconPath, Color bgColor) {
    final isSelected = _selectedMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? bgColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.grey[200]!, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.payment, color: AppColors.primary), // Placeholder for real icon
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: AppTextStyles.bodyBold)),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildPayButton(AuthController auth) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentProcessingScreen(
                  amount: widget.amount,
                  method: _selectedMethod,
                  description: widget.description,
                  userId: auth.currentUser!.id,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text("Thanh toán ngay", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
