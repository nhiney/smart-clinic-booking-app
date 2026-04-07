import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  
  bool _isSpeechInitialized = false;

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

    // TTS Config
    await _tts.setLanguage("vi-VN");
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
    
    // iOS specific TTS setup
    await _tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, 
      [
        IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
      ],
      IosTextToSpeechAudioMode.defaultMode
    );

    return _isSpeechInitialized;
  }

  Future<void> startListening({
    required Function(String text) onResult,
    required Function(bool isListening) onListeningChange,
    required Function(String error) onError,
  }) async {
    if (!_isSpeechInitialized) {
      bool initialized = await init();
      if (!initialized) {
        onError("Không thể khởi tạo micro");
        return;
      }
    }

    if (_isSpeechInitialized) {
      await _speech.listen(
        onResult: (val) {
          if (val.recognizedWords.isNotEmpty) {
            onResult(val.recognizedWords);
          }
        },
        localeId: 'vi_VN',
        onSoundLevelChange: (level) => {}, // Can be used for mic animation
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      );
      onListeningChange(true);
    }
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
  }
}
