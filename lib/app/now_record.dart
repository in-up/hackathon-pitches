import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../components/halo.dart';
import '../services/audio/audio_recording_service.dart';
import '../services/speech/speech_recognition_service.dart';
import '../domain/repositories/recording_repository.dart';
import '../services/api/http_api_service.dart';
import '../services/storage/hive_storage_service.dart';
import '../domain/models/speech_analysis_model.dart';
import '../core/constants/color_constants.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/message_constants.dart';

class NowRecordScreen extends StatefulWidget {
  @override
  _NowRecordScreenState createState() => _NowRecordScreenState();
}

class _NowRecordScreenState extends State<NowRecordScreen> {
  // 서비스 의존성
  late final AudioRecordingService _audioService;
  late final SpeechRecognitionService _speechService;
  late final RecordingRepository _recordingRepository;

  // UI 상태
  bool _isRecording = false;
  String _lastWords = '';
  Color _borderColor = ColorConstants.statusNormal;
  String _liveComment = '';
  int _lastLength = 0;
  late Timer _colorChangeTimer;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _initializeSpeech();
  }

  void _initializeServices() {
    _audioService = AudioRecordingService();
    _speechService = SpeechRecognitionService();
    _recordingRepository = RecordingRepository(
      apiService: HttpApiService(),
      storageService: HiveStorageService(),
    );
  }

  Future<void> _initializeSpeech() async {
    final initialized = await _speechService.initialize();
    if (!mounted) return;

    if (initialized) {
      _startRecording();
    }
  }

  Future<void> _startRecording() async {
    _lastWords = '';
    _lastLength = 0;

    // 음성 인식 시작
    _speechService.startListening();
    _speechService.transcriptionStream.listen((text) {
      setState(() => _lastWords = text);
    });

    // 오디오 녹음 시작
    try {
      await _audioService.startRecording();

      // 녹음 완료 리스너
      _audioService.recordingCompleteStream.listen(_handleRecordingComplete);

      setState(() => _isRecording = true);

      // 실시간 분석 타이머 시작
      _startAnalysisTimer();

      print(MessageConstants.recordingStartedMessage);
    } catch (e) {
      print('${MessageConstants.recordingFailedMessage}: $e');
    }
  }

  void _startAnalysisTimer() {
    _colorChangeTimer = Timer.periodic(
      Duration(seconds: AppConstants.timerIntervalSeconds),
      (_) => _analyzeSpeedAndUpdateUI(),
    );
  }

  void _analyzeSpeedAndUpdateUI() {
    int currentLength = _lastWords.length;
    int difference = currentLength - _lastLength;

    final analysis = SpeechAnalysisModel.analyze(difference);

    setState(() {
      _borderColor = analysis.borderColor;
      _liveComment = analysis.comment;
      _lastLength = currentLength;
    });
  }

  Future<void> _handleRecordingComplete(Uint8List audioBytes) async {
    try {
      final serverResponse = await _recordingRepository.uploadRecording(audioBytes);

      await _recordingRepository.saveRecordingLocally(
        audioBytes,
        serverResponse,
        _lastWords,
      );

      print(MessageConstants.uploadSuccessMessage);

      Navigator.pushNamed(context, '/loading', arguments: _lastWords);
    } catch (e) {
      print('${MessageConstants.uploadFailedMessage}: $e');
    }
  }

  void _stopRecording() {
    print('stopListening 호출됨');
    _speechService.stopListening();
    _audioService.stopRecording();
    _colorChangeTimer.cancel();
    setState(() => _isRecording = false);
    print(MessageConstants.recordingStoppedMessage);
  }

  @override
  void dispose() {
    _audioService.dispose();
    _speechService.dispose();
    _colorChangeTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          ' 실시간 분석',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ),
      backgroundColor: Theme.of(context).canvasColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 100),
            SizedBox(
              height: 200,
              child: Center(
                child: BreathingButton(
                  onPressed: _stopRecording, // 버튼을 누르면 녹음 종료
                  borderColor: _borderColor, // borderColor 적용
                  size: 180.0,
                ),
              ),
            ),
            SizedBox(
              height: 100,
              child: Center(
                  child: Text(
                _liveComment,
                style:
                    TextStyle(fontWeight: FontWeight.w700, color: _borderColor, fontSize: 20),
              )),
            ),
            if (_lastWords.isNotEmpty)
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    height: 200,
                    child: Text(
                      _lastWords,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.25,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
