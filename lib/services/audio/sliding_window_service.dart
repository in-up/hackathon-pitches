import 'dart:async';
import 'dart:typed_data';
import '../../core/constants/app_constants.dart';
import '../../domain/models/audio_chunk_model.dart';

class SlidingWindowService {
  final int chunkDurationMs;
  final int slideIntervalMs;

  List<Uint8List> _audioBuffer = [];
  int _sequenceNumber = 0;
  Timer? _slideTimer;
  StreamSubscription? _audioSubscription;

  final StreamController<AudioChunkModel> _chunkController =
      StreamController<AudioChunkModel>.broadcast();

  Stream<AudioChunkModel> get chunkStream => _chunkController.stream;

  SlidingWindowService({
    this.chunkDurationMs = AppConstants.chunkDurationMs,
    this.slideIntervalMs = AppConstants.slideIntervalMs,
  });

  void start(Stream<Uint8List> audioStream) {
    // 오디오 스트림으로부터 데이터 수집
    _audioSubscription = audioStream.listen((audioData) {
      _audioBuffer.add(audioData);
      print(
          '버퍼에 청크 추가: ${audioData.length} bytes, 총 버퍼 크기: ${_audioBuffer.length}');
    });

    // 슬라이딩 윈도우 타이머 시작 (1.5초마다)
    _slideTimer = Timer.periodic(
      Duration(milliseconds: slideIntervalMs),
      (_) => _processWindow(),
    );

    print('슬라이딩 윈도우 시작: ${slideIntervalMs}ms 간격');
  }

  void _processWindow() {
    if (_audioBuffer.isEmpty) {
      print('버퍼가 비어있음, 윈도우 처리 건너뜀');
      return;
    }

    // 버퍼에서 윈도우 크기만큼 데이터 추출 및 병합
    final windowData = _mergeBufferedChunks();

    if (windowData.isNotEmpty) {
      final chunk = AudioChunkModel(
        data: windowData,
        sequenceNumber: _sequenceNumber++,
        timestamp: DateTime.now(),
        durationMs: chunkDurationMs,
      );

      _chunkController.add(chunk);
      print(
          '윈도우 청크 생성: sequence=${chunk.sequenceNumber}, size=${windowData.length} bytes');

      _cleanupBuffer();
    }
  }

  Uint8List _mergeBufferedChunks() {
    if (_audioBuffer.isEmpty) return Uint8List(0);

    // 모든 버퍼된 청크를 병합
    final totalLength = _audioBuffer.fold<int>(
      0,
      (sum, chunk) => sum + chunk.length,
    );

    final merged = Uint8List(totalLength);
    int offset = 0;

    for (final chunk in _audioBuffer) {
      merged.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }

    return merged;
  }

  void _cleanupBuffer() {
    // 2초 윈도우, 0.5초마다 전송, 1.5초씩 중첩시키기

    if (_audioBuffer.length > 1) {
      // 첫번째 청크만 제거
      _audioBuffer.removeAt(0);
      print('오래된 청크 1개 제거, 남은 청크: ${_audioBuffer.length}');
    }
  }

  void stop() {
    _slideTimer?.cancel();
    _audioSubscription?.cancel();
    _audioBuffer.clear();
    _sequenceNumber = 0;
    print('슬라이딩 윈도우 중지');
  }

  void dispose() {
    stop();
    _chunkController.close();
  }
}
