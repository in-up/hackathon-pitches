import 'package:flutter/material.dart';

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
          leading: Icon(Icons.description), // 문서 모양 아이콘
          title: Text(files[index]['title']!), // 파일 제목
          trailing: Text(files[index]['time']!), // 시간
        );
      },
    );
  }
}