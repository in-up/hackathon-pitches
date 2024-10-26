import 'dart:convert'; // JSON 디코딩을 위해 import
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;

class MarkdownExample extends StatefulWidget {
  final String id;
  final String description;
  final String emotion;

  MarkdownExample(
      {required this.id, required this.description, required this.emotion});

  @override
  _MarkdownExampleState createState() => _MarkdownExampleState();
}

class _MarkdownExampleState extends State<MarkdownExample> {
  String rawData = "응답이 없습니다.";
  bool isLoading = true; // 로딩 상태를 나타내는 변수

  @override
  void initState() {
    super.initState();
    _sendPostRequest(widget.description, widget.emotion);
  }

  Future<void> _sendPostRequest(String description, String emotion) async {
    final safeDescription = description.isNotEmpty ? description : '기본 설명';
    final safeEmotion = emotion.isNotEmpty ? emotion : '기본 감정';

    print("Sending POST request with description: $safeDescription");
    print("Sending POST request with emotion: $safeEmotion");

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://123.37.11.55:5000/gpt'),
    );

    // 요청 필드 추가
    request.fields['stt_script'] = safeDescription;
    request.fields['emotion_data'] = safeEmotion;

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await http.Response.fromStream(response);
        print('Response data: ${responseData.body}');

        final decodedResponse = jsonDecode(responseData.body);

        // 응답에서 'response' 필드 추출
        setState(() {
          rawData = decodedResponse['response'] ?? '응답이 없습니다.';
          isLoading = false; // 데이터 로딩 완료
        });
      } else {
        print('Failed to send POST request: ${response.statusCode}');
        setState(() {
          isLoading = false; // 에러 발생 시에도 로딩 완료
        });
      }
    } catch (e) {
      print('Error sending POST request: $e');
      setState(() {
        isLoading = false; // 예외 발생 시에도 로딩 완료
      });
    }
  }

  String processMarkdown(String data) {
    // 숫자.숫자나 숫자. 띄어쓰기를 대체
    String processedData = data.replaceAllMapped(
      RegExp(r'(\d+\.\d+|\d+\.\s)'),
          (match) => match.group(0)!.replaceAll('.', '[DOT]'),
    );

    // 점(.)을 기준으로 나눈 후, 이전에 대체한 [DOT]는 다시 점(.)으로 되돌리기
    return processedData.split('.').map((sentence) {
      String trimmedSentence = sentence.trim().replaceAll('[DOT]', '.');
      return trimmedSentence.isNotEmpty ? '$trimmedSentence.' : '';
    }).where((sentence) => sentence.isNotEmpty).join('\n\n');
  }


  @override
  Widget build(BuildContext context) {
    final String markdownData = processMarkdown(rawData);

    return Scaffold(
      appBar: AppBar(
        title: Text('나의 스피치 분석'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading // 로딩 상태에 따라 위젯 변경
            ? Center(
                child: CircularProgressIndicator(), // 로딩 인디케이터
              )
            : Markdown(
                data: markdownData,
                styleSheet: MarkdownStyleSheet(
                  h1: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF120642), height: 1.5),
                  h2: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF120642), height: 1.5),
                  h3: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF120642), height: 1.5),
                  horizontalRuleDecoration: BoxDecoration(
                    color: Colors.grey,
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
