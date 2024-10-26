import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart'; // 날짜 포맷을 위한 패키지 추가
import 'package:pitches/app/filelist.dart';
import '../app/detail.dart';
import '../app/markdown.dart';

class FileList extends StatefulWidget {
  @override
  _FileListState createState() => _FileListState();
}

class _FileListState extends State<FileList> {
  List<Map<String, dynamic>> files = [];

  @override
  void initState() {
    super.initState();
    getFiles();
  }

  void getFiles() {
    var box = Hive.box('localdata');
    files = box.values.map((file) {
      return {
        'title': file['title'],
        'timestamp': file['timestamp'],
        'favorite': file['favorite'],
        'description' : file['description'],
        'id' : file['id']
      };
    }).toList();

    setState(() {}); // UI 업데이트
  }

  String _relativeTime(String timestamp) {
    final DateTime time = DateTime.parse(timestamp);
    final Duration difference = DateTime.now().difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금';
    }
  }

  @override
  Widget build(BuildContext context) {
    return files.isEmpty
        ? Center(child: Text('저장된 파일이 없습니다'))
        : ListView.builder(
      itemCount: files.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(Icons.description_outlined, color: Colors.black),
          title: Text(files[index]['title']),
          trailing: Text(_relativeTime(files[index]['timestamp'])),
          onTap: () {
            // ListTile 클릭 시 detail 페이지로 이동
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Detail(
                  title: files[index]['title'], // title 전달
                  time: files[index]['timestamp'],
                  description: files[index]['description'],
                  id: files[index]['id'],
                  favorite: files[index]['favorite']
                ),
              ),
            );
          },
        );
      },
    );
  }
}
