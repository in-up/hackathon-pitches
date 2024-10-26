import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../domain/models/report_model.dart';

class HttpApiService {
  final http.Client _client;

  HttpApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<String> uploadAudioFile(Uint8List audioBytes, String filename) async {
    try {
      final formData = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConstants.fileUploadUrl),
      );

      formData.files.add(http.MultipartFile.fromBytes(
        'file',
        audioBytes,
        filename: filename,
      ));

      final response = await formData.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        print('파일 업로드 성공: ${responseBody.body}');
        return responseBody.body;
      } else {
        throw Exception('파일 업로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('업로드 중 오류 발생: $e');
      rethrow;
    }
  }

  Future<ReportModel?> fetchReport(String filename) async {
    try {
      final response = await _client.get(
        Uri.parse(ApiConstants.getReportUrl(filename)),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return ReportModel.fromJson(data[0]);
        }
      } else {
        throw Exception('리포트 로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('리포트 가져오기 오류: $e');
      rethrow;
    }
    return null;
  }

  void dispose() {
    _client.close();
  }
}
