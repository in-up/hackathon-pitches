import 'dart:async';
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

      _mediaRecorder?.addEventListener('dataavailable', (html.Event event) {
        final blobEvent = event as html.BlobEvent;
        final blob = blobEvent.data;

        if (blob != null && blob.size > 0) {
          _recordedChunks.add(blob);
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
        // 현재 lastWords의 길이를 가져옵니다.
        int currentLength = lastWords.length;

        // 길이 차이를 계산합니다.
        int difference = currentLength - lastLength;

        // 기준에 따라 색상을 변경합니다.
        if (difference > 17) {
          borderColor = Colors.red; // 글자 차이가 17글자 초과일 때 빨간색
        } else {
          borderColor = Colors.green; // 그렇지 않으면 초록색
        }

        // 마지막 길이를 현재 길이로 업데이트합니다.
        lastLength = currentLength;

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
    var box = await Hive.openBox('localdata');

    // mp3 파일 저장
    await box.put('mp3File', mp3Bytes);

    // JSON 응답 저장
    await box.put('jsonResponse', jsonResponse);
    print("mp3 파일과 JSON 응답이 성공적으로 저장되었습니다.");
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

      final blob = html.Blob(_recordedChunks);
      print('녹음된 Blob 크기: ${blob.size} bytes'); // 확인용 로그 추가
      final reader = html.FileReader();
      reader.readAsArrayBuffer(blob);

      reader.onLoadEnd.listen((event) async {
        final bytes = reader.result as Uint8List;
      });
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
