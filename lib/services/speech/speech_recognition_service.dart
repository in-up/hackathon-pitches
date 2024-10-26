import 'dart:async';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../core/constants/app_constants.dart';

class SpeechRecognitionService {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;

  final StreamController<String> _transcriptionController = StreamController<String>.broadcast();

  Stream<String> get transcriptionStream => _transcriptionController.stream;
  bool get isInitialized => _isInitialized;

  Future<bool> initialize() async {
    _isInitialized = await _speech.initialize();
    return _isInitialized;
  }

  void startListening() {
    if (!_isInitialized) {
      throw Exception('Speech recognition not initialized');
    }

    _speech.listen(
      onResult: _resultListener,
      listenFor: Duration(seconds: AppConstants.maxRecordingDuration),
      partialResults: true,
    );
  }

  void _resultListener(SpeechRecognitionResult result) {
    _transcriptionController.add(result.recognizedWords);
  }

  void stopListening() {
    if (_speech.isListening) {
      _speech.stop();
    }
  }

  void dispose() {
    _transcriptionController.close();
    _speech.stop();
  }
}
