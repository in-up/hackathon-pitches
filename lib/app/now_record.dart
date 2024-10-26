import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

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

    // 음성 인식이 초기화된 후 시작
    if (_hasSpeech) {
      startListening();
    }
  }

  void startListening() async {
    lastWords = '';
    lastLength = 0;

    // 음성 인식 시작
    speech.listen(
      onResult: resultListener,
      listenFor: Duration(seconds: 99999),
      partialResults: true,
    );

    // 웹에서 마이크 권한 요청 및 녹음 시작
    final mediaDevices = html.window.navigator.mediaDevices;

    if (mediaDevices != null) {
      final stream = await mediaDevices.getUserMedia({'audio': true});
      _mediaRecorder = html.MediaRecorder(stream);

      // 데이터 사용 가능 이벤트 리스너 추가
      _mediaRecorder?.addEventListener('dataavailable', (html.Event event) {
        final blobEvent = event as html.BlobEvent; // Event를 BlobEvent로 캐스팅
        final blob = blobEvent.data; // Blob? 타입

        // blob이 null이 아닐 경우에만 size를 확인하고 chunks에 추가
        if (blob != null && blob.size > 0) {
          _recordedChunks.add(blob);
        }
      });

      // 녹음 중지 이벤트 리스너 추가
      _mediaRecorder?.addEventListener('stop', (html.Event event) {
        final blob = html.Blob(_recordedChunks);
        
        // Blob URL 생성: 녹음이 완료되면 html.Url.createObjectUrlFromBlob(blob)을 통해 Blob URL을 생성합니다.
        final url = html.Url.createObjectUrlFromBlob(blob);
        print('녹음 완료: $url');
        print('녹음 파일 크기: ${blob.size} bytes'); // 파일 크기 출력

        // 다운로드 링크 생성: URL을 사용하여 다운로드 링크를 생성할 수 있습니다.
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'recording.wav') // 다운로드할 파일 이름 설정
          ..click(); // 다운로드 시작

        // Blob URL 해제: 메모리에서 Blob URL을 해제하여 메모리 관리를 수행합니다.
        html.Url.revokeObjectUrl(url);
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

      // 3초마다 borderColor 업데이트
      colorChangeTimer = Timer.periodic(Duration(seconds: 3), (timer) {
        if (lastWords.length > lastLength) {
          lastLength = lastWords.length;
          borderColor = Colors.red; // 증가했으면 빨간색
        } else {
          borderColor = Colors.green; // 변화가 없으면 초록색
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

  void stopListening() async {
    print('stopListening 호출됨'); // 디버깅 로그 추가
    if (speech.isListening) {
      speech.stop();
      _mediaRecorder?.stop();
      colorChangeTimer.cancel();
      setState(() {
        isRecording = false;
      });
      print('녹음이 중지되었습니다.');
    } else {
      print('speech.isListening이 false입니다.'); // 상태 확인
    }
  }

  @override
  void dispose() {
    colorChangeTimer.cancel(); // 화면 종료 시 타이머 정리
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
            // 음성 인식 결과를 표시할 수 있는 Text 위젯 추가
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
