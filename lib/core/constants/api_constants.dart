import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // Base URLs
  static String get baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('API_BASE_URL이 .env 파일에 설정되지 않았습니다.');
    }
    return url;
  }

  static String get wsBaseUrl {
    final url = dotenv.env['WS_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('WS_BASE_URL이 .env 파일에 설정되지 않았습니다.');
    }
    return url;
  }

  // HTTP Endpoints
  static const String fileUploadEndpoint = '/fileupload';
  static const String reportEndpoint = '/report';

  // WebSocket Endpoints
  static const String wsStreamEndpoint = '/stream';

  // 전체 URL 생성 헬퍼
  static String get fileUploadUrl => '$baseUrl$fileUploadEndpoint';
  static String getReportUrl(String filename) =>
      '$baseUrl$reportEndpoint?filename=$filename';
  static String get wsStreamUrl => '$wsBaseUrl$wsStreamEndpoint';
}
