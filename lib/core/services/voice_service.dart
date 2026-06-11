import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isSpeechInitialized = false;
  String _localeId = 'vi_VN';

  final _soundLevelController = StreamController<double>.broadcast();
  Stream<double> get soundLevelStream => _soundLevelController.stream;

  bool get isListening => _speech.isListening;

  Future<bool> init() async {
    if (_isSpeechInitialized) return true;

    try {
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        debugPrint('VoiceService: microphone permission denied');
        return false;
      }

      _isSpeechInitialized = await _speech.initialize(
        onError: (e) => debugPrint('VoiceService STT error: $e'),
        onStatus: (s) => debugPrint('VoiceService STT status: $s'),
      );

      if (!_isSpeechInitialized) {
        debugPrint('VoiceService: STT init failed');
        return false;
      }

      // Pick Vietnamese locale if available, otherwise use device default.
      final locales = await _speech.locales();
      final vi = locales.where((l) => l.localeId.startsWith('vi')).firstOrNull;
      if (vi != null) {
        _localeId = vi.localeId;
        debugPrint('VoiceService: vi locale found → $_localeId');
      } else {
        // No vi locale — fall back to device default (no localeId arg).
        _localeId = '';
        debugPrint('VoiceService: vi locale NOT available, using device default');
      }

      // TTS setup (non-fatal).
      try {
        await _tts.setLanguage('vi-VN');
        await _tts.setPitch(1.0);
        await _tts.setSpeechRate(0.5);
        await _tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          ],
          IosTextToSpeechAudioMode.defaultMode,
        );
      } catch (e) {
        debugPrint('VoiceService: TTS setup warning (non-fatal): $e');
      }
    } catch (e) {
      debugPrint('VoiceService: init error: $e');
      return false;
    }

    return _isSpeechInitialized;
  }

  Future<void> startListening({
    required Function(String text) onResult,
    required Function(bool isListening) onListeningChange,
    required Function(String error) onError,
  }) async {
    if (!_isSpeechInitialized) {
      final ok = await init();
      if (!ok) {
        onError('Không thể khởi tạo micro. Vui lòng cấp quyền micro trong Cài đặt.');
        return;
      }
    }

    // Stop any previous session before starting a new one.
    if (_speech.isListening) {
      await _speech.stop();
      await Future.delayed(const Duration(milliseconds: 150));
    }

    onListeningChange(true);

    await _speech.listen(
      onResult: (val) {
        if (val.recognizedWords.isNotEmpty) {
          onResult(val.recognizedWords);
        }
        if (val.finalResult) {
          onListeningChange(false);
        }
      },
      localeId: _localeId.isEmpty ? null : _localeId,
      pauseFor: const Duration(seconds: 2),
      onSoundLevelChange: (level) {
        final normalized = ((level + 2) / 12).clamp(0.0, 1.0);
        if (!_soundLevelController.isClosed) {
          _soundLevelController.add(normalized);
        }
      },
      listenOptions: stt.SpeechListenOptions(
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
        partialResults: true,
      ),
    );

    // Verify listening actually started.
    if (!_speech.isListening) {
      debugPrint('VoiceService: listen() returned but isListening=false');
      onListeningChange(false);
      onError('Không thể bắt đầu ghi âm. Thử lại hoặc kiểm tra quyền micro.');
    }
  }

  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      await _tts.speak(text);
    }
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  void dispose() {
    _speech.stop();
    _tts.stop();
    _soundLevelController.close();
  }
}
