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
    speech.listen(
      onResult: resultListener,
      listenFor: Duration(seconds: 99999), // 충분히 긴 시간 설정
      partialResults: true,
    );
  }

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  void stopListening() {
    if (speech.isListening) {
      speech.stop();
      Navigator.pushNamed(context, '/loading', arguments: lastWords);
    }
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
