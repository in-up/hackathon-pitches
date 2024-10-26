import 'dart:typed_data';
import '../../services/api/http_api_service.dart';
import '../../services/storage/hive_storage_service.dart';
import '../models/recording_model.dart';
import '../../core/constants/app_constants.dart';

class RecordingRepository {
  final HttpApiService _apiService;
  final HiveStorageService _storageService;

  RecordingRepository({
    required HttpApiService apiService,
    required HiveStorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService;

  Future<String> uploadRecording(Uint8List audioBytes) async {
    return await _apiService.uploadAudioFile(
      audioBytes,
      AppConstants.recordingFileName,
    );
  }

  Future<void> saveRecordingLocally(
    Uint8List audioBytes,
    String serverResponse,
    String transcription,
  ) async {
    String title = serverResponse.split('/').last.split('.').first;
    String description = transcription.isNotEmpty
        ? transcription
        : AppConstants.noContentMessage;

    DateTime now = DateTime.now();

    final recording = RecordingModel(
      id: title,
      title: title,
      timestamp: now.toIso8601String(),
      webmFile: audioBytes,
      description: description,
      favorite: false,
    );

    await _storageService.saveRecording(recording);
  }

  Future<List<RecordingModel>> getAllRecordings() async {
    return await _storageService.getAllRecordings();
  }

  Future<RecordingModel?> getRecordingById(String id) async {
    return await _storageService.getRecordingById(id);
  }
}
