import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownExample extends StatelessWidget {
  final String rawData = """
마크다운 영역
""";

  // 데이터를 읽어오는 과정에서 . 뒤에 줄바꿈을 추가하는 함수
  String processMarkdown(String data) {
    return data.split('.').map((sentence) {
      // 각 문장을 처리하고, 마지막에 줄바꿈 추가
      return sentence.trim().isNotEmpty ? sentence.trim() + '.' : '';
    }).where((sentence) => sentence.isNotEmpty).join('\n\n'); // 줄바꿈 추가
  }

  @override
  Widget build(BuildContext context) {
    final String markdownData = processMarkdown(rawData); // 데이터 처리

    return Scaffold(
      appBar: AppBar(
        title: Text('Markdown Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Markdown(data: markdownData),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MarkdownExample(),
  ));
}
