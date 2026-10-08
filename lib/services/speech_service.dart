import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isAvailable = false;
  bool _isListening = false;

  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;

  Future<bool> initSpeech() async {
    try {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        debugPrint('Permissão de microfone negada');
        return false;
      }

      _isAvailable = await _speech.initialize(
        onStatus: (status) {
          debugPrint('Status Speech: $status');
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
          }
        },
        onError: (errorNotification) {
          debugPrint('Erro Speech: ${errorNotification.errorMsg}');
          _isListening = false;
        },
      );
      return _isAvailable;
    } catch (e) {
      debugPrint('Exceção ao inicializar SpeechToText: $e');
      _isAvailable = false;
      return false;
    }
  }

  Future<void> startListening({
    required Function(String recognizedWords) onResult,
    required VoidCallback onDone,
  }) async {
    if (!_isAvailable) {
      final ready = await initSpeech();
      if (!ready) return;
    }

    _isListening = true;
    await _speech.listen(
      localeId: 'pt_BR',
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      onResult: (result) {
        onResult(result.recognizedWords);
        if (result.finalResult) {
          onDone();
        }
      },
    );
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }
}
