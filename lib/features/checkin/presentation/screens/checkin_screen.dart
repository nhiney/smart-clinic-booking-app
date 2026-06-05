import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart' as legacy_provider;
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/theme/typography/app_text_styles.dart';
import '../../../../core/widgets/branded_app_bar.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/checkin_controller.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  final String appointmentId;

  const CheckInScreen({
    super.key,
    required this.appointmentId,
  });

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth =
          legacy_provider.Provider.of<AuthController>(context, listen: false);
      if (auth.currentUser != null) {
        ref
            .read(checkInProvider.notifier)
            .generateQR(auth.currentUser!.id, widget.appointmentId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkInProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BrandedAppBar(title: "Check-in QR"),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10))
                  ],
                ),
                child: state.isLoading
                    ? const SizedBox(
                        width: 200,
                        height: 200,
                        child: CircularProgressIndicator())
                    : QrImageView(
                        data: state.qrData,
                        version: QrVersions.auto,
                        size: 250.0,
                        eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.circle,
                            color: AppColors.primary),
                        dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.circle,
                            color: AppColors.primary),
                      ),
              ),
              const SizedBox(height: 40),
              Text("Quét mã QR tại quầy", style: AppTextStyles.subtitle),
              const SizedBox(height: 8),
              Text(
                "QR hop le tu ${_formatDateTime(state.validFrom)} den ${_formatDateTime(state.expiry)}",
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 40),
              _buildHelperCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelperCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.security, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "Mã QR được mã hóa và ký tên để bảo mật tuyệt đối cho thông tin của bạn.",
              style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$hour:$minute $day/$month';
  }
}
