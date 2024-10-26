import 'package:flutter/material.dart';
import 'package:pitches/app/markdown.dart';

import '../app/detail.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FileList(), // FileList를 시작 페이지로 설정
      routes: {
        '/markdown': (context) => MarkdownExample(), // 라우트 추가
        // '/detail' 라우트는 FileList에서 처리하므로 여기서는 필요 없음
      },
    );
  }
}

class FileList extends StatefulWidget {
  @override
  _FileListState createState() => _FileListState();
}

class _FileListState extends State<FileList> {
  final List<Map<String, String>> files = [
    {'title': '파일 1', 'time': '1일 전'},
    {'title': '파일 2', 'time': '3일 전'},
    {'title': '파일 3', 'time': '5일 전'},
    {'title': '파일 4', 'time': '7일 전'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: files.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(Icons.description_outlined, color: Colors.black),
          title: Text(files[index]['title']!), 
          trailing: Text(files[index]['time']!),
          onTap: () {
            // ListTile 클릭 시 detail 페이지로 이동
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Detail(
                  title: files[index]['title'], // title 전달
                  time: files[index]['time'],   // time 전달
                ),
              ),
            );
          },
        );
      },
    );
  }
}