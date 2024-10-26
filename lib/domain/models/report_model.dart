class ReportModel {
  final String description;
  final String emotion;
  final dynamic startTime;
  final dynamic endTime;
  final dynamic speechRate;

  ReportModel({
    required this.description,
    required this.emotion,
    required this.startTime,
    required this.endTime,
    required this.speechRate,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      description: json['description'] ?? '설명이 없습니다.',
      emotion: json['emotion'] ?? 'EMO_UNKNOWN',
      startTime: json['start_time'] ?? 0,
      endTime: json['end_time'] ?? 0,
      speechRate: json['speech_rate'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'emotion': emotion,
      'start_time': startTime,
      'end_time': endTime,
      'speech_rate': speechRate,
    };
  }
}
