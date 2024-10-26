import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

class AudioRecordingService {
  html.MediaRecorder? _mediaRecorder;
  List<html.Blob> _recordedChunks = [];
  bool _isRecording = false;

  final StreamController<Uint8List> _audioChunkController = StreamController<Uint8List>.broadcast();
  final StreamController<Uint8List> _recordingCompleteController = StreamController<Uint8List>();

  Stream<Uint8List> get audioChunkStream => _audioChunkController.stream;
  Stream<Uint8List> get recordingCompleteStream => _recordingCompleteController.stream;
  bool get isRecording => _isRecording;

  Future<void> startRecording({int? timeslice}) async {
    final mediaDevices = html.window.navigator.mediaDevices;

    if (mediaDevices == null) {
      throw Exception('이 브라우저는 getUserMedia를 지원하지 않습니다.');
    }

    final stream = await mediaDevices.getUserMedia({'audio': true});
    _mediaRecorder = html.MediaRecorder(stream);
    _recordedChunks.clear();

    _mediaRecorder?.addEventListener('dataavailable', (html.Event event) async {
      final blobEvent = event as html.BlobEvent;
      final blob = blobEvent.data;

      if (blob != null && blob.size > 0) {
        _recordedChunks.add(blob);
        print('녹음된 Blob 크기: ${blob.size} bytes');

        // Convert blob to Uint8List and emit
        final reader = html.FileReader();
        reader.readAsArrayBuffer(blob);

        reader.onLoadEnd.listen((event) async {
          final bytes = reader.result as Uint8List;
          _audioChunkController.add(bytes);
        });
      }
    });

    _mediaRecorder?.addEventListener('stop', (html.Event event) async {
      final blob = html.Blob(_recordedChunks);
      print('녹음 완료: ${blob.size} bytes');

      final reader = html.FileReader();
      reader.readAsArrayBuffer(blob);

      reader.onLoadEnd.listen((event) async {
        final bytes = reader.result as Uint8List;
        _recordingCompleteController.add(bytes);
      });
    });

    try {
      if (timeslice != null) {
        _mediaRecorder?.start(timeslice);
      } else {
        _mediaRecorder?.start();
      }
      _isRecording = true;
      print('녹음이 시작되었습니다.');
    } catch (e) {
      print('녹음 시작 중 오류 발생: ${e.toString()}');
      rethrow;
    }
  }

  void stopRecording() {
    if (_mediaRecorder != null && _isRecording) {
      _mediaRecorder?.stop();
      _isRecording = false;
      print('녹음이 중지되었습니다.');
    }
  }

  void dispose() {
    _audioChunkController.close();
    _recordingCompleteController.close();
    _mediaRecorder = null;
    _recordedChunks.clear();
  }
}
