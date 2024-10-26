import 'dart:typed_data';

class AudioChunkModel {
  final Uint8List data;
  final int sequenceNumber;
  final DateTime timestamp;
  final int durationMs;

  AudioChunkModel({
    required this.data,
    required this.sequenceNumber,
    required this.timestamp,
    required this.durationMs,
  });

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'sequence': sequenceNumber,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'duration': durationMs,
    };
  }
}
