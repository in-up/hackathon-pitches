import 'package:hive/hive.dart';
import '../../domain/models/recording_model.dart';

class HiveStorageService {
  static const String _boxName = 'localdata';

  Box get _box => Hive.box(_boxName);

  Future<void> saveRecording(RecordingModel recording) async {
    await _box.add(recording.toMap());
    print('데이터가 Hive에 추가되었습니다: ${recording.title}');
  }

  Future<List<RecordingModel>> getAllRecordings() async {
    List<RecordingModel> recordings = [];
    for (int i = 0; i < _box.length; i++) {
      var data = _box.getAt(i);
      if (data != null) {
        recordings.add(RecordingModel.fromMap(Map<String, dynamic>.from(data)));
      }
    }
    return recordings;
  }

  Future<RecordingModel?> getRecordingById(String id) async {
    for (int i = 0; i < _box.length; i++) {
      var data = _box.getAt(i);
      if (data != null && data['id'] == id) {
        return RecordingModel.fromMap(Map<String, dynamic>.from(data));
      }
    }
    return null;
  }

  Future<void> updateRecording(int index, RecordingModel recording) async {
    await _box.putAt(index, recording.toMap());
  }

  Future<void> deleteRecording(int index) async {
    await _box.deleteAt(index);
  }

  Future<void> printAllData() async {
    for (int i = 0; i < _box.length; i++) {
      var data = _box.getAt(i);
      print('데이터 $i:');
      print('  제목: ${data['title']}');
      print('  타임스탬프: ${data['timestamp']}');
      print('  웹엠 파일 크기: ${data['webmFile']?.length ?? 0} bytes');
      print('  설명: ${data['description']}');
      print('  즐겨찾기: ${data['favorite']}');
      print('  감정: ${data['emotion']}');
    }
  }
}
