import 'dart:async';
import 'dart:typed_data';
import '../../domain/models/audio_chunk_model.dart';
import '../api/websocket_service.dart';
import 'sliding_window_service.dart';

class AudioChunkManager {
  final WebSocketService _wsService;
  final SlidingWindowService _slidingWindowService;

  StreamSubscription? _chunkSubscription;

  AudioChunkManager({
    required WebSocketService wsService,
    required SlidingWindowService slidingWindowService,
  })  : _wsService = wsService,
        _slidingWindowService = slidingWindowService;

  Future<void> initialize() async {
    await _wsService.connect();
    print('AudioChunkManager 초기화 완료');
  }

  void startStreaming(Stream<Uint8List> audioStream) {
    print('실시간 스트리밍 시작');

    // 슬라이딩 윈도우 시작
    _slidingWindowService.start(audioStream);

    // 청크를 WebSocket으로 전송
    _chunkSubscription = _slidingWindowService.chunkStream.listen(
      (chunk) {
        try {
          _wsService.sendAudioChunk(chunk);
        } catch (e) {
          print('청크 전송 실패: $e');
        }
      },
      onError: (error) {
        print('스트리밍 오류: $error');
      },
    );
  }

  Stream<Map<String, dynamic>> get responseStream => _wsService.responseStream;

  void stopStreaming() {
    print('실시간 스트리밍 중지');
    _chunkSubscription?.cancel();
    _slidingWindowService.stop();
  }

  void dispose() {
    stopStreaming();
    _wsService.dispose();
    _slidingWindowService.dispose();
    print('AudioChunkManager dispose 완료');
  }
}
