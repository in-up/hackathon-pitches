import 'dart:async';
import 'dart:convert'; // JSON 처리를 위해 추가
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../components/halo.dart'; // BreathingButton의 경로 확인

class NowRecordScreen extends StatefulWidget {
  @override
  _NowRecordScreenState createState() => _NowRecordScreenState();
}

class _NowRecordScreenState extends State<NowRecordScreen> {
  final SpeechToText speech = SpeechToText();
  html.MediaRecorder? _mediaRecorder;
  List<html.Blob> _recordedChunks = [];
  bool isRecording = false;

  bool _hasSpeech = false;
  String lastWords = '';
  Color borderColor = Colors.green; // 초기 borderColor
  int lastLength = 0; // 마지막 문자열 길이
  late Timer colorChangeTimer; // 색상 변경 타이머

  @override
  void initState() {
    super.initState();
    initSpeechState();
  }

  Future<void> initSpeechState() async {
    var hasSpeech = await speech.initialize();
    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });

    if (_hasSpeech) {
      startListening();
    }
  }

  void startListening() async {
    lastWords = '';
    lastLength = 0;

    speech.listen(
      onResult: resultListener,
      listenFor: Duration(seconds: 99999),
      partialResults: true,
    );

    final mediaDevices = html.window.navigator.mediaDevices;

    if (mediaDevices != null) {
      final stream = await mediaDevices.getUserMedia({'audio': true});
      _mediaRecorder = html.MediaRecorder(stream);

      _mediaRecorder?.addEventListener('dataavailable', (html.Event event) async {
        final blobEvent = event as html.BlobEvent;
        final blob = blobEvent.data;

        if (blob != null && blob.size > 0) {
          _recordedChunks.add(blob);
          print('녹음된 Blob 크기: ${blob.size} bytes'); // Blob 크기 확인

          // Blob을 ArrayBuffer로 읽기
          final reader = html.FileReader();
          reader.readAsArrayBuffer(blob);

          reader.onLoadEnd.listen((event) async {
            final bytes = reader.result as Uint8List;

            // saveToHive 메소드 호출
            // mp3Bytes와 jsonResponse는 어떻게 제공할지 결정해야 합니다.
            await saveToHive(bytes, '{"title": "녹음 제목"}'); // JSON 응답 예시
          });
        }
      });

      _mediaRecorder?.addEventListener('stop', (html.Event event) async {
        final blob = html.Blob(_recordedChunks);
        print('녹음 완료: $blob');
        print('녹음 파일 크기: ${blob.size} bytes');

        // Blob을 ArrayBuffer로 읽기
        final reader = html.FileReader();
        reader.readAsArrayBuffer(blob);

        reader.onLoadEnd.listen((event) async {
          final bytes = reader.result as Uint8List;

          // 서버로 업로드 요청 보내기
          if (bytes.isNotEmpty) {
            final formData = http.MultipartRequest(
              'POST',
              Uri.parse('http://123.37.11.55:5000/fileupload'),
            );
            formData.files.add(http.MultipartFile.fromBytes(
              'file',
              bytes,
              filename: 'recording.wav',
            ));

            try {
              final response = await formData.send();
              final responseBody = await http.Response.fromStream(response);
              if (response.statusCode == 200) {
                print('파일 업로드 성공');
                print('서버 응답: ${responseBody.body}');
              } else {
                print('파일 업로드 실패: ${response.statusCode}');
                print('서버 응답: ${responseBody.body}');
              }
            } catch (e) {
              print('업로드 중 오류 발생: $e');
            }
          } else {
            print('전송할 바이트 배열이 비어 있습니다.');
          }
          Navigator.pushNamed(context, '/loading', arguments: lastWords);
        });
      });

      try {
        print("녹음을 시작합니다...");
        _mediaRecorder?.start();
        setState(() {
          isRecording = true;
        });
        print("녹음이 시작되었습니다.");
      } catch (e) {
        print("녹음 시작 중 오류 발생: ${e.toString()}");
      }

      colorChangeTimer = Timer.periodic(Duration(seconds: 3), (timer) {
        if (lastWords.length > lastLength) {
          lastLength = lastWords.length;
          borderColor = Colors.red;
        } else {
          borderColor = Colors.green;
        }
        setState(() {});
      });
    } else {
      print("mediaDevices가 null입니다. 이 브라우저는 getUserMedia를 지원하지 않을 수 있습니다.");
    }
  }

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  // Hive에 mp3 파일과 JSON 응답 저장
  Future<void> saveToHive(Uint8List mp3Bytes, String jsonResponse) async {
    // 'localdata'라는 이름의 박스를 엽니다.
    var box = await Hive.openBox('localdata');

    // 현재 시간을 가져와서 타임스탬프를 생성합니다.
    DateTime now = DateTime.now();
    String timestamp = now.toIso8601String(); // ISO 8601 형식으로 변환

    // JSON 파싱하여 제목을 가져옵니다.
    String title;
    try {
      final Map<String, dynamic> jsonMap = json.decode(jsonResponse);
      title = jsonMap['title'] ?? '제목 없음'; // 제목이 없으면 기본값 설정
    } catch (e) {
      title = '제목 없음'; // JSON 파싱 실패 시 기본 제목
    }

    // 데이터를 리스트 형태로 저장합니다.
    await box.add({
      'title': title,        // JSON 제목
      'timestamp': timestamp,// 현재 시간
      'json': jsonResponse,  // JSON 응답
      'wav': mp3Bytes,       // 음성 파일
    });

    
  }
  Future<void> loadFromHive() async {
    // 'localdata'라는 이름의 박스를 엽니다.
    var box = await Hive.openBox('localdata');

    // 저장된 데이터 불러오기
    String? title = box.get('title');
    String? timestamp = box.get('timestamp');
    String? jsonResponse = box.get('json');
    Uint8List? mp3Bytes = box.get('wav');

    // 데이터를 확인합니다.
    if (title != null) {
      print("제목: $title");
    } else {
      print("제목이 저장되어 있지 않습니다.");
    }

    if (timestamp != null) {
      print("타임스탬프: $timestamp");
    } else {
      print("타임스탬프가 저장되어 있지 않습니다.");
    }

    if (jsonResponse != null) {
      print("JSON 응답: $jsonResponse");
    } else {
      print("JSON 응답이 저장되어 있지 않습니다.");
    }

    if (mp3Bytes != null) {
      print("mp3 파일 크기: ${mp3Bytes.length} bytes");
    } else {
      print("mp3 파일이 저장되어 있지 않습니다.");
    }
  }

  
  void stopListening() async {
    print('stopListening 호출됨');
    if (speech.isListening) {
      speech.stop();
      _mediaRecorder?.stop();
      colorChangeTimer.cancel();
      setState(() {
        isRecording = false;
      });
      print('녹음이 중지되었습니다.');
      await loadFromHive();
      // Blob 생성 전에 _recordedChunks의 상태를 확인합니다.
      if (_recordedChunks.isNotEmpty) {
        final blob = html.Blob(_recordedChunks);
        print('녹음된 Blob 크기: ${blob.size} bytes'); // 확인용 로그 추가

        // Blob을 ArrayBuffer로 읽기
        final reader = html.FileReader();
        reader.readAsArrayBuffer(blob);
        
        reader.onLoadEnd.listen((event) async {
          final bytes = reader.result as Uint8List;
          // bytes를 여기서 처리
        });
        
      } else {
        print('녹음된 데이터가 없습니다. Blob 크기: 0 bytes');
      }
    } else {
      print('speech.isListening이 false입니다.');
    }
  }


  @override
  void dispose() {
    colorChangeTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          CircleAvatar(
            backgroundImage: NetworkImage('https://picsum.photos/200'),
          ),
          SizedBox(width: 10),
        ],
      ),
      backgroundColor: Theme.of(context).canvasColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 100),
            SizedBox(
              height: 200,
              child: Center(
                child: BreathingButton(
                  onPressed: stopListening, // 버튼을 누르면 녹음 종료
                  borderColor: borderColor, // borderColor 적용
                ),
              ),
            ),
            if (lastWords.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  lastWords,
                  style: TextStyle(fontSize: 24),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
