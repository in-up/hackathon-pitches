import 'dart:typed_data';

class RecordingModel {
  final String id;
  final String title;
  final String timestamp;
  final Uint8List? webmFile;
  final String description;
  final bool favorite;
  final String emotion;
  final dynamic endTime;
  final dynamic speechRate;
  final dynamic startTime;
  final String transcript;

  RecordingModel({
    required this.id,
    required this.title,
    required this.timestamp,
    this.webmFile,
    required this.description,
    this.favorite = false,
    this.emotion = '',
    this.endTime = 0,
    this.speechRate = 0,
    this.startTime = 0,
    this.transcript = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'timestamp': timestamp,
      'webmFile': webmFile,
      'description': description,
      'favorite': favorite,
      'emotion': emotion,
      'end_time': endTime,
      'speech_rate': speechRate,
      'start_time': startTime,
      'transcript': transcript,
    };
  }

  factory RecordingModel.fromMap(Map<String, dynamic> map) {
    return RecordingModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      timestamp: map['timestamp'] ?? '',
      webmFile: map['webmFile'],
      description: map['description'] ?? '',
      favorite: map['favorite'] ?? false,
      emotion: map['emotion'] ?? '',
      endTime: map['end_time'] ?? 0,
      speechRate: map['speech_rate'] ?? 0,
      startTime: map['start_time'] ?? 0,
      transcript: map['transcript'] ?? '',
    );
  }

  RecordingModel copyWith({
    String? id,
    String? title,
    String? timestamp,
    Uint8List? webmFile,
    String? description,
    bool? favorite,
    String? emotion,
    dynamic endTime,
    dynamic speechRate,
    dynamic startTime,
    String? transcript,
  }) {
    return RecordingModel(
      id: id ?? this.id,
      title: title ?? this.title,
      timestamp: timestamp ?? this.timestamp,
      webmFile: webmFile ?? this.webmFile,
      description: description ?? this.description,
      favorite: favorite ?? this.favorite,
      emotion: emotion ?? this.emotion,
      endTime: endTime ?? this.endTime,
      speechRate: speechRate ?? this.speechRate,
      startTime: startTime ?? this.startTime,
      transcript: transcript ?? this.transcript,
    );
  }
}
