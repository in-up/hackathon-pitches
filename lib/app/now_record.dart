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
import '../services/audio/audio_chunk_manager.dart';
import '../services/api/websocket_service.dart';
import '../services/audio/sliding_window_service.dart';

class NowRecordScreen extends StatefulWidget {
  @override
  _NowRecordScreenState createState() => _NowRecordScreenState();
}

class _NowRecordScreenState extends State<NowRecordScreen> {
  // 서비스
  late final AudioRecordingService _audioService;
  late final SpeechRecognitionService _speechService;
  late final RecordingRepository _recordingRepository;
  late final AudioChunkManager _chunkManager;

  // UI 상태
  bool _isRecording = false;
  String _lastWords = '';
  Color _borderColor = ColorConstants.statusNormal;
  String _liveComment = '';
  String _serverFeedback = '';
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
    _chunkManager = AudioChunkManager(
      wsService: WebSocketService(),
      slidingWindowService: SlidingWindowService(),
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
      // WebSocket 연결
      await _chunkManager.initialize();

      // 500ms timeslice
      await _audioService.startRecording(timeslice: 500);
      _chunkManager.startStreaming(_audioService.audioChunkStream);

      // 결과 수신
      _chunkManager.responseStream.listen((response) {
        print('실시간 분석 결과: $response');
        _handleServerResponse(response);
      });

      // 녹음 완료 리스너 (전체 파일 저장용)
      _audioService.recordingCompleteStream.listen(_handleRecordingComplete);

      setState(() => _isRecording = true);

      // 로컬 분석 타이머
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

  void _handleServerResponse(Map<String, dynamic> response) {
    try {
      String feedback = '';

      // 감정 분석 결과
      if (response.containsKey('emotion')) {
        final emotion = response['emotion'];
        feedback += _getEmotionFeedback(emotion);
      }

      // 발음/유창성
      if (response.containsKey('fluency_score')) {
        final score = response['fluency_score'];
        if (score is num && score < 0.5) {
          feedback += '\n${MessageConstants.fluencyLow}';
        }
      }

      // 서버에서 직접 피드백 메시지를 보내는 경우
      if (response.containsKey('feedback')) {
        feedback = response['feedback'].toString();
      }

      // 속도 분석
      if (response.containsKey('speech_rate')) {
        final rate = response['speech_rate'];
        if (rate == 'TOO_FAST') {
          feedback += '\n${MessageConstants.rateTooFast}';
        } else if (rate == 'TOO_SLOW') {
          feedback += '\n${MessageConstants.rateTooSlow}';
        }
      }

      setState(() {
        _serverFeedback = feedback.trim();
      });
    } catch (e) {
      print('서버 응답 처리 오류: $e');
    }
  }

  String _getEmotionFeedback(String emotion) {
    // 서버 응답 형식: <|EMOTION|>
    final cleanEmotion = emotion.replaceAll(RegExp(r'<\||>'), '').toUpperCase();

    switch (cleanEmotion) {
      case 'HAPPY':
        return MessageConstants.emotionHappy;
      case 'SAD':
        return MessageConstants.emotionSad;
      case 'ANGRY':
        return MessageConstants.emotionAngry;
      case 'NEUTRAL':
        return MessageConstants.emotionNeutral;
      case 'FEARFUL':
        return MessageConstants.emotionFearful;
      case 'DISGUSTED':
        return MessageConstants.emotionDisgusted;
      case 'SURPRISED':
        return MessageConstants.emotionSurprised;
      case 'EMO_UNKNOWN':
      default:
        return '';
    }
  }

  Future<void> _handleRecordingComplete(Uint8List audioBytes) async {
    try {
      final serverResponse =
          await _recordingRepository.uploadRecording(audioBytes);

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
    _chunkManager.stopStreaming();
    _colorChangeTimer.cancel();
    setState(() => _isRecording = false);
    print(MessageConstants.recordingStoppedMessage);
  }

  @override
  void dispose() {
    _audioService.dispose();
    _speechService.dispose();
    _chunkManager.dispose();
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 로컬 스피치 속도 분석 결과
                  if (_liveComment.isNotEmpty)
                    Text(
                      _liveComment,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _borderColor,
                        fontSize: 20,
                      ),
                    ),
                  // 서버 실시간 분석 결과
                  if (_serverFeedback.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _serverFeedback,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: ColorConstants.statusGood,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
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
