import 'dart:async';

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

  void startListening() {
    lastWords = '';
    lastLength = 0;
    speech.listen(
      onResult: resultListener,
      listenFor: Duration(seconds: 99999),
      partialResults: true,
    );

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
  }

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  void stopListening() {
    if (speech.isListening) {
      speech.stop();
      colorChangeTimer.cancel(); // 타이머 종료
      Navigator.pushNamed(context, '/loading', arguments: lastWords);
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
