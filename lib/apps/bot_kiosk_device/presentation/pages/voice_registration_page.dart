import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:smart_clinic_booking/apps/bot_kiosk_device/domain/entities/slot_entity.dart';
import 'package:smart_clinic_booking/apps/bot_kiosk_device/presentation/state/kiosk_controller.dart';
import 'package:smart_clinic_booking/apps/bot_kiosk_device/presentation/state/kiosk_state.dart';
import 'package:smart_clinic_booking/apps/bot_kiosk_device/presentation/widgets/kiosk_large_button.dart';

class VoiceRegistrationPage extends ConsumerStatefulWidget {
  final SlotEntity selectedSlot;

  const VoiceRegistrationPage({super.key, required this.selectedSlot});

  @override
  ConsumerState<VoiceRegistrationPage> createState() => _VoiceRegistrationPageState();
}

class _VoiceRegistrationPageState extends ConsumerState<VoiceRegistrationPage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _currentField = 'name';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _speech.stop();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _listen() async {
    try {
      if (!_isListening) {
        bool available = await _speech.initialize(
          onStatus: (val) => debugPrint('onStatus: $val'),
          onError: (val) => debugPrint('onError: $val'),
        );
        if (available) {
          setState(() => _isListening = true);
          _speech.listen(
            onResult: (val) => setState(() {
              if (_currentField == 'name') {
                _nameController.text = val.recognizedWords;
              } else {
                _phoneController.text = val.recognizedWords.replaceAll(RegExp(r'\D'), '');
              }
            }),
          );
        }
      } else {
        setState(() => _isListening = false);
        _speech.stop();
      }
    } catch (e) {
      debugPrint('Lỗi Voice: $e');
      setState(() => _isListening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe trạng thái đặt khám để quay lại hoặc hiện thông báo
    ref.listen<KioskState>(kioskControllerProvider, (previous, next) {
      if (next is KioskBookingSuccess) {
        Navigator.of(context).pop(); // Đóng trang đăng ký khi thành công
      }
    });

    final state = ref.watch(kioskControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('NHẬP THÔNG TIN', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        toolbarHeight: 100,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              children: [
                const Text(
                  'Bấm vào nút Micro và Đọc to Họ tên của bạn',
                  style: TextStyle(fontSize: 28, color: Colors.blueGrey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                TextField(
                  controller: _nameController,
                  onTap: () => setState(() => _currentField = 'name'),
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'HỌ VÀ TÊN',
                    labelStyle: const TextStyle(fontSize: 24),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                    suffixIcon: _currentField == 'name' ? const Icon(Icons.record_voice_over, color: Colors.red, size: 40) : null,
                  ),
                ),
                const SizedBox(height: 30),

                TextField(
                  controller: _phoneController,
                  onTap: () => setState(() => _currentField = 'phone'),
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'SỐ ĐIỆN THOẠI',
                    labelStyle: const TextStyle(fontSize: 24),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                    suffixIcon: _currentField == 'phone' ? const Icon(Icons.record_voice_over, color: Colors.red, size: 40) : null,
                  ),
                ),
                
                const SizedBox(height: 50),

                GestureDetector(
                  onTap: _listen,
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: _isListening ? Colors.red : Colors.blue,
                      shape: BoxShape.circle,
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20, spreadRadius: 5)],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 60),

                KioskLargeButton(
                  label: state is KioskLoading ? 'ĐANG XỬ LÝ...' : 'TIẾP TỤC',
                  color: state is KioskLoading ? Colors.grey : Colors.green,
                  onPressed: state is KioskLoading 
                    ? () {} 
                    : () {
                      if (_nameController.text.isNotEmpty && _phoneController.text.isNotEmpty) {
                        ref.read(kioskControllerProvider.notifier).confirmBooking(
                          widget.selectedSlot.id,
                          _nameController.text,
                          _phoneController.text,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin'))
                        );
                      }
                    },
                ),
              ],
            ),
          ),
          if (state is KioskLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator(strokeWidth: 8)),
            ),
        ],
      ),
    );
  }
}
