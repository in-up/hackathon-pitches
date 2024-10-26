import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../app/detail.dart';
import '../app/markdown.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FileList(),
      routes: {
        '/markdown': (context) => MarkdownExample(),
      },
    );
  }
}

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

  void getFiles() async {
  var box = Hive.box('localdata');
  Map<dynamic, dynamic> boxMap = box.toMap();
  List<Map<String, dynamic>> loadedFiles = boxMap.entries.map((entry) {
    return {
      'title': entry.value['title'],
      'timestamp': entry.value['timestamp'],
      'favorite': entry.value['favorite'],
      'description': entry.value['description'],
      'id': entry.key, // Hive 박스의 키를 'id'로 사용
    };
  }).toList();

  setState(() {
    files = loadedFiles; // UI 업데이트
  });
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

  void _toggleFavorite(int index) async {
  var box = Hive.box('localdata');
  var fileId = files[index]['id'];
  var isFavorite = !files[index]['favorite'];

  await box.put(fileId, {
    'title': files[index]['title'],
    'timestamp': files[index]['timestamp'],
    'favorite': isFavorite,
    'description': files[index]['description'],
    'id': fileId,
  });

  getFiles();
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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_relativeTime(files[index]['timestamp'])),
                    IconButton(
                      icon: Icon(
                        files[index]['favorite'] ? Icons.star : Icons.star_border,
                        color: files[index]['favorite'] ? Colors.yellow : Colors.grey,
                      ),
                      onPressed: () => _toggleFavorite(index),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Detail(
                        title: files[index]['title'],
                        time: _relativeTime(files[index]['timestamp']),
                        description: files[index]['description'],
                        id: files[index]['id'],
                        favorite: files[index]['favorite'],
                      ),
                    ),
                  );
                },
              );
            },
          );
  }
}
