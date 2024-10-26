class AppConstants {
  // Recording Settings
  static const int timerIntervalSeconds = 3;
  static const int maxRecordingDuration = 99999; // seconds

  // Speech Analysis Thresholds
  static const int fastSpeechThreshold = 23;
  static const int normalSpeechThreshold = 2;

  // Audio Settings (2단계)
  static const int chunkDurationMs = 2000;  // 2초
  static const int overlapDurationMs = 500;  // 0.5초 중첩
  static const int slideIntervalMs = 1500;   // 1.5초마다 전송

  // Default Values
  static const String defaultEmotion = 'EMO_UNKNOWN';
  static const String defaultTime = '0초';
  static const String defaultDescription = '안녕하세요.';
  static const String noContentMessage = '내용이 없는 스피치입니다.';
  static const String noDescriptionMessage = '설명이 없습니다.';

  // File Settings
  static const String recordingFileExtension = '.webm';
  static const String recordingFileName = 'recording.webm';
}
