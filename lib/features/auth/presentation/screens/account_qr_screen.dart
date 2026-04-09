import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
import 'dart:typed_data';
import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:smart_clinic_booking/core/extensions/context_extension.dart';
import 'package:smart_clinic_booking/core/widgets/app_button.dart';
import 'package:smart_clinic_booking/core/widgets/branded_app_bar.dart';

class AccountQrScreen extends StatelessWidget {
  final String token;
  final String expiresAt;

  const AccountQrScreen({
    super.key,
    required this.token,
    required this.expiresAt,
  });

  String _tr(BuildContext context, String vi, String en, String ja, String ko, String zh) {
    final lang = Localizations.localeOf(context).languageCode;
    switch (lang) {
      case 'en':
        return en;
      case 'ja':
        return ja;
      case 'ko':
        return ko;
      case 'zh':
        return zh;
      default:
        return vi;
    }
  }

  Future<void> _saveQrToGallery(BuildContext context, GlobalKey boundaryKey) async {
    try {
      PermissionStatus permissionStatus;
      if (Platform.isIOS) {
        permissionStatus = await Permission.photosAddOnly.request();
      } else {
        permissionStatus = await Permission.storage.request();
      }

      if (!permissionStatus.isGranted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _tr(
                  context,
                  'Bạn đã từ chối quyền lưu ảnh.',
                  'You denied permission to save images.',
                  '画像保存の権限が拒否されました。',
                  '이미지 저장 권한이 거부되었습니다.',
                  '您已拒绝保存图片权限。',
                ),
              ),
            ),
          );
        }
        return;
      }

      final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _tr(
                  context,
                  'Không thể tạo ảnh QR. Vui lòng thử lại.',
                  'Cannot create QR image. Please try again.',
                  'QR画像を作成できません。再試行してください。',
                  'QR 이미지를 생성할 수 없습니다. 다시 시도하세요.',
                  '无法生成二维码图片，请重试。',
                ),
              ),
            ),
          );
        }
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final bytes = byteData?.buffer.asUint8List();
      if (bytes == null) throw Exception('QR image bytes is null');

      final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(bytes),
        quality: 100,
        name: 'icare_qr_${DateTime.now().millisecondsSinceEpoch}',
      );
      final resultMap = Map<String, dynamic>.from(result as Map);
      final isSuccess = (resultMap['isSuccess'] == true) || (resultMap['filePath'] != null);
      if (!context.mounted) return;
      if (!isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _tr(
                context,
                'Lưu mã QR thất bại.',
                'Failed to save QR code.',
                'QRコードの保存に失敗しました。',
                'QR 코드 저장에 실패했습니다.',
                '保存二维码失败。',
              ),
            ),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _tr(
              context,
              'Đã lưu mã QR về máy thành công.',
              'QR code saved successfully.',
              'QRコードを保存しました。',
              'QR 코드가 저장되었습니다.',
              '二维码保存成功。',
            ),
          ),
        ),
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _tr(
                context,
                'Có lỗi khi lưu ảnh QR.',
                'Error while saving QR image.',
                'QR画像の保存中にエラーが発生しました。',
                'QR 이미지 저장 중 오류가 발생했습니다.',
                '保存二维码图片时发生错误。',
              ),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final payload = 'icare://qr-login?token=$token';
    final qrBoundaryKey = GlobalKey();
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const BrandedAppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFE3F2FD),
              const Color(0xFFF8FAFC),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.spacing.l),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _tr(
                    context,
                    'Mã QR của bạn đã sẵn sàng!',
                    'Your QR code is ready!',
                    'QRコードの準備ができました！',
                    'QR 코드가 준비되었습니다!',
                    '您的二维码已准备就绪！',
                  ),
                  style: context.textStyles.heading3.copyWith(
                    color: context.colors.primaryDark,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  _tr(
                    context,
                    'Lưu mã QR này để đăng nhập nhanh chóng mà không cần mật khẩu.',
                    'Save this QR code for quick login without password.',
                    'このQRコードを保存すると、次回パスワードなしで素早くログインできます。',
                    '이 QR 코드를 저장하면 다음에 비밀번호 없이 빠르게 로그인할 수 있습니다.',
                    '保存此二维码可在下次无需密码快速登录。',
                  ),
                  style: context.textStyles.body.copyWith(color: context.colors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // QR Card
                Container(
                  padding: EdgeInsets.all(context.spacing.l),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: context.radius.xlRadius,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      RepaintBoundary(
                        key: qrBoundaryKey,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: context.radius.mRadius,
                          ),
                          child: QrImageView(
                            data: payload,
                            size: 240,
                            version: QrVersions.auto,
                            eyeStyle: QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: const Color(0xFF0D47A1), // Explicit Navy Blue
                            ),
                            dataModuleStyle: QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.circle,
                              color: const Color(0xFF1565C0), // Explicit Primary Blue
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'ICARE SECURE QR',
                        style: context.textStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: Colors.blueGrey.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                AppButton(
                  text: _tr(context, 'Lưu', 'Save', '保存', '저장', '保存'),
                  onPressed: () => _saveQrToGallery(context, qrBoundaryKey),
                  backgroundColor: const Color(0xFF0D47A1), // Navy Blue
                  prefixIcon: const Icon(Icons.download_rounded, color: Colors.white),
                ),
                const SizedBox(height: 16),
                AppButton(
                  text: _tr(
                    context,
                    'Tiếp tục',
                    'Continue',
                    '続行',
                    '계속',
                    '继续',
                  ),
                  onPressed: () => context.go('/login'),
                  backgroundColor: context.colors.primary,
                  prefixIcon: const Icon(Icons.login_rounded, color: Colors.white),
                ),
                const SizedBox(height: 32),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: context.colors.error.withOpacity(0.05),
                    borderRadius: context.radius.mRadius,
                    border: Border.all(color: context.colors.error.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: context.colors.error, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _tr(
                            context,
                            'Không chia sẻ mã QR này với bất kỳ ai để bảo vệ tài khoản.',
                            'Do not share this QR code with anyone to protect your account.',
                            'アカウント保護のため、このQRコードを他人と共有しないでください。',
                            '계정 보호를 위해 이 QR 코드를 다른 사람과 공유하지 마세요.',
                            '请勿与任何人分享此二维码，以保护您的账户。',
                          ),
                          style: context.textStyles.bodySmall.copyWith(
                            color: context.colors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
