import '../../services/api/http_api_service.dart';
import '../../services/storage/hive_storage_service.dart';
import '../models/report_model.dart';
import '../models/recording_model.dart';

class ReportRepository {
  final HttpApiService _apiService;
  final HiveStorageService _storageService;

  ReportRepository({
    required HttpApiService apiService,
    required HiveStorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService;

  Future<ReportModel?> fetchReport(String filename) async {
    return await _apiService.fetchReport(filename);
  }

  Future<void> updateLocalRecordingWithReport(
    String id,
    ReportModel report,
  ) async {
    final recordings = await _storageService.getAllRecordings();

    for (int i = 0; i < recordings.length; i++) {
      if (recordings[i].id == id) {
        final updatedRecording = recordings[i].copyWith(
          emotion: report.emotion,
          startTime: report.startTime,
          endTime: report.endTime,
          speechRate: report.speechRate,
        );

        await _storageService.updateRecording(i, updatedRecording);
        break;
      }
    }
  }
}
