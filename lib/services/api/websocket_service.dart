import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/models/audio_chunk_model.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  bool _isConnected = false;

  final StreamController<Map<String, dynamic>> _responseController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get responseStream => _responseController.stream;
  bool get isConnected => _isConnected;

  Future<void> connect() async {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse(ApiConstants.wsStreamUrl),
      );

      _isConnected = true;
      print('WebSocket 연결 성공');

      // 서버로부터의 응답 수신
      _channel!.stream.listen(
        (data) {
          try {
            final response = jsonDecode(data);
            _responseController.add(response);
            print('서버 응답: $response');
          } catch (e) {
            print('응답 파싱 오류: $e');
          }
        },
        onError: (error) {
          print('WebSocket 오류: $error');
          _isConnected = false;
        },
        onDone: () {
          print('WebSocket 연결 종료');
          _isConnected = false;
        },
      );
    } catch (e) {
      print('WebSocket 연결 실패: $e');
      _isConnected = false;
      rethrow;
    }
  }

  void sendAudioChunk(AudioChunkModel chunk) {
    if (!_isConnected || _channel == null) {
      throw Exception('WebSocket이 연결되지 않음');
    }

    try {
      // Base64로 인코딩하여 전송
      final message = {
        'sequence': chunk.sequenceNumber,
        'timestamp': chunk.timestamp.millisecondsSinceEpoch,
        'duration': chunk.durationMs,
        'audio_data': base64Encode(chunk.data),
      };

      _channel!.sink.add(jsonEncode(message));
      print('청크 전송: sequence=${chunk.sequenceNumber}, size=${chunk.data.length}');
    } catch (e) {
      print('청크 전송 오류: $e');
      rethrow;
    }
  }

  void close() {
    _channel?.sink.close();
    _responseController.close();
    _isConnected = false;
    print('WebSocket 연결 종료');
  }

  void dispose() {
    close();
  }
}
