import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
import 'dart:typed_data';
import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:smart_clinic_booking/core/extensions/context_extension.dart';
import 'package:smart_clinic_booking/core/widgets/app_button.dart';
import 'package:smart_clinic_booking/core/widgets/branded_app_bar.dart';

class AccountQrScreen extends StatefulWidget {
  final String token;
  final String expiresAt;

  const AccountQrScreen({
    super.key,
    required this.token,
    required this.expiresAt,
  });

  @override
  State<AccountQrScreen> createState() => _AccountQrScreenState();
}

class _AccountQrScreenState extends State<AccountQrScreen> {
  final GlobalKey _qrBoundaryKey = GlobalKey();


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

  Future<void> _saveQrToGallery(BuildContext context) async {
    try {
      PermissionStatus status;
      
      if (Platform.isIOS) {
        status = await Permission.photosAddOnly.request();
      } else {
        // Android logic
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        final sdkInt = androidInfo.version.sdkInt;

        if (sdkInt >= 33) {
          status = await Permission.photos.request();
        } else {
          status = await Permission.storage.request();
        }
      }

      if (status.isPermanentlyDenied) {
        if (context.mounted) {
          _showSettingsDialog(context);
        }
        return;
      }

      if (!status.isGranted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _tr(
                  context,
                  'Bạn cần cấp quyền truy cập ảnh để lưu mã QR.',
                  'You need to grant photo access to save the QR code.',
                  'QRコードを保存するには写真へのアクセス権限が必要です。',
                  'QR 코드를 저장하려면 사진 접근 권한이 필요합니다.',
                  '您需要授予照片访问权限才能保存二维码。',
                ),
              ),
              action: SnackBarAction(
                label: _tr(context, 'Cài đặt', 'Settings', '設定', '설정', '设置'),
                onPressed: () => openAppSettings(),
              ),
            ),
          );
        }
        return;
      }

      final boundary = _qrBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
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
      
      if (byteData == null) {
        throw Exception('Could not convert QR boundary to byte data');
      }

      // CRITICAL FIX: Use offset and length to get the exact bytes for the image
      final bytes = byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      );

      debugPrint('[AUTH] Attempting to save QR image. Bytes length: ${bytes.length}');

      final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(bytes),
        quality: 100,
        name: 'icare_qr_${DateTime.now().millisecondsSinceEpoch}',
      );

      debugPrint('[AUTH] Gallery saver result: $result');

      bool isSuccess = false;
      if (result != null) {
        if (result is Map) {
          isSuccess = (result['isSuccess'] == true) || (result['filePath'] != null);
        } else if (result is String && result.isNotEmpty) {
          // Some versions/platforms return the path directly upon success
          isSuccess = true;
        }
      }

      if (!context.mounted) return;
      
      if (!isSuccess) {
        debugPrint('[AUTH] Gallery saving failed. Detailed result: $result');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _tr(
                context,
                'Lưu mã QR thất bại. Vui lòng thử lại sau.',
                'Failed to save QR code. Please try again later.',
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

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_tr(context, 'Cần quyền truy cập', 'Permission Required', '権限が必要です', '권한이 필요합니다', '需要权限')),
        content: Text(_tr(
          context,
          'Bạn đã từ chối quyền truy cập ảnh. Vui lòng mở Cài đặt để cấp quyền thủ công.',
          'You have denied photo access. Please open Settings to grant permission manually.',
          '写真へのアクセス権限が拒否されています。手動で許可するには設定を開いてください。',
          '사진 접근 권한이 거부되었습니다. 수동으로 허용하려면 설정을 열어주세요.',
          '您已拒绝照片访问权限。请打开设置以手动授予权限。',
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_tr(context, 'Hủy', 'Cancel', 'キャンセル', '취소', '取消')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text(_tr(context, 'Mở Cài đặt', 'Open Settings', '設定を開く', '설정 열기', '打开设置')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final payload = 'icare://qr-login?token=${widget.token}';
    
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
                        key: _qrBoundaryKey,
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
                  text: _tr(context, 'Lưu mã QR về điện thoại', 'Save QR to gallery', 'QRを保存', 'QR 저장', '保存二维码'),
                  onPressed: () => _saveQrToGallery(context),
                  backgroundColor: Colors.white,
                  textColor: const Color(0xFF0D47A1),
                  borderSide: const BorderSide(color: Color(0xFF0D47A1)),
                  prefixIcon: const Icon(Icons.download_rounded, color: Color(0xFF0D47A1)),
                ),
                const SizedBox(height: 16),
                AppButton(
                  text: _tr(
                    context,
                    'Tiếp tục đăng nhập',
                    'Continue to login',
                    'ログインへ進む',
                    '로그인으로 계속',
                    '继续登录',
                  ),
                  onPressed: () => context.go('/login'),
                  backgroundColor: context.colors.primary,
                  prefixIcon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
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
