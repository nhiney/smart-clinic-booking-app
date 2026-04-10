import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:smart_clinic_booking/core/extensions/context_extension.dart';
import 'package:smart_clinic_booking/core/widgets/branded_app_bar.dart';

import 'package:image_picker/image_picker.dart';
import '../controllers/auth_controller.dart';
import '../navigation/role_navigation.dart';
import '../utils/auth_error_localizer.dart';

class QrLoginScannerScreen extends StatefulWidget {
  const QrLoginScannerScreen({super.key});

  @override
  State<QrLoginScannerScreen> createState() => _QrLoginScannerScreenState();
}

class _QrLoginScannerScreenState extends State<QrLoginScannerScreen> {
  bool _isHandlingScan = false;
  final MobileScannerController _scannerController = MobileScannerController();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _manualController = TextEditingController();

  String _tr(String vi, String en, String ja, String ko, String zh) {
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

  String _extractToken(String raw) {
    final uri = Uri.tryParse(raw);
    if (uri != null) {
      final tokenFromQuery = uri.queryParameters['token'];
      if (tokenFromQuery != null && tokenFromQuery.isNotEmpty) return tokenFromQuery;
    }
    return raw.trim();
  }

  Future<void> _processToken(String token) async {
    if (_isHandlingScan) return;
    setState(() => _isHandlingScan = true);
    
    final authController = context.read<AuthController>();
    final success = await authController.signInWithQrToken(token);
    
    if (!mounted) return;

    if (success) {
      navigateByRole(context, authController.currentUser?.role ?? 'patient');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          localizeAuthError(context, authController.errorMessage, fallback:
              _tr(
                'Mã QR không hợp lệ hoặc đã hết hạn.',
                'QR code is invalid or expired.',
                'QRコードが無効か期限切れです。',
                'QR 코드가 유효하지 않거나 만료되었습니다.',
                '二维码无效或已过期。',
              )),
        ),
        backgroundColor: context.colors.error,
      ),
    );
    setState(() => _isHandlingScan = false);
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    final raw = capture.barcodes.isEmpty ? null : capture.barcodes.first.rawValue;
    if (raw == null || raw.trim().isEmpty) return;
    final token = _extractToken(raw);
    await _processToken(token);
  }

  Future<void> _pickAndScanImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final BarcodeCapture? capture = await _scannerController.analyzeImage(image.path);
      if (capture == null || capture.barcodes.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _tr(
                'Không tìm thấy mã QR trong ảnh này.',
                'No QR code found in this image.',
                'この画像にQRコードが見つかりません。',
                '이 이미지에서 QR 코드를 찾을 수 없습니다.',
                '在此图片中未找到二维码。',
              ),
            ),
          ),
        );
        return;
      }

      final String? raw = capture.barcodes.first.rawValue;
      if (raw == null || raw.trim().isEmpty) return;
      
      final token = _extractToken(raw);
      await _processToken(token);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _tr(
              'Lỗi khi quét ảnh: $e',
              'Error scanning image: $e',
              '画像のスキャン中にエラー: $e',
              '이미지 스캔 오류: $e',
              '扫描图片出错: $e',
            ),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _manualController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandedAppBar(title: 'Đăng nhập bằng QR'),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),
          // Scanner Overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Text(
                  _tr(
                    'Đưa mã QR vào khung camera\nhoặc chọn ảnh từ điện thoại',
                    'Place QR code inside camera frame\nor choose an image from gallery',
                    'QRコードをカメラ枠に合わせるか\nギャラリーから画像を選択してください',
                    'QR 코드를 카메라 프레임에 맞추거나\n갤러리에서 이미지를 선택하세요',
                    '将二维码放入取景框内\n或从相册中选择图片',
                  ),
                  style: context.textStyles.body.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _manualController,
                          decoration: InputDecoration(
                            hintText: _tr(
                              'Dán token QR tại đây',
                              'Paste QR token here',
                              'ここにQRトークンを貼り付け',
                              '여기에 QR 토큰 붙여넣기',
                              '在此粘贴二维码令牌',
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final token = _extractToken(_manualController.text);
                          if (token.isEmpty) return;
                          await _processToken(token);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          _tr('Nhập', 'Submit', '送信', '확인', '提交'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickAndScanImage,
                      icon: const Icon(Icons.photo_library_rounded),
                      label: Text(
                        _tr(
                          'Chọn từ thư viện',
                          'Choose from gallery',
                          'ギャラリーから選択',
                          '갤러리에서 선택',
                          '从相册选择',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.9),
                        foregroundColor: context.colors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isHandlingScan)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
