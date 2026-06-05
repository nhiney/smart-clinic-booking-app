import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isSpeechInitialized = false;

  // Stream for sound level (0.0 – 1.0) so UI can animate mic button.
  final _soundLevelController = StreamController<double>.broadcast();
  Stream<double> get soundLevelStream => _soundLevelController.stream;

  Future<bool> init() async {
    if (_isSpeechInitialized) return true;

    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      debugPrint('Microphone permission not granted');
      return false;
    }

    _isSpeechInitialized = await _speech.initialize(
      onError: (val) => debugPrint('STT Error: $val'),
      onStatus: (val) => debugPrint('STT Status: $val'),
    );

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
        onError('Không thể khởi tạo micro');
        return;
      }
    }

    await _speech.listen(
      onResult: (val) {
        if (val.recognizedWords.isNotEmpty) {
          onResult(val.recognizedWords);
        }
        // STT done (final result) → notify caller
        if (val.finalResult) {
          onListeningChange(false);
        }
      },
      localeId: 'vi_VN',
      onSoundLevelChange: (level) {
        // Normalize roughly to 0–1 (level range is typically -2 to 10 dB)
        final normalized = ((level + 2) / 12).clamp(0.0, 1.0);
        if (!_soundLevelController.isClosed) {
          _soundLevelController.add(normalized);
        }
      },
      listenOptions: stt.SpeechListenOptions(
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      ),
    );

    onListeningChange(true);
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }

  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      debugPrint('AI Speaking: $text');
      await _tts.speak(text);
    }
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  bool get isListening => _speech.isListening;

  void dispose() {
    _speech.stop();
    _tts.stop();
    _soundLevelController.close();
  }
}
