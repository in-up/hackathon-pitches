import 'package:flutter/material.dart';
import '../components/files.dart';

class FileScreen extends StatefulWidget {
  @override
  _FileScreenState createState() => _FileScreenState();
}

class _FileScreenState extends State<FileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('파일 목록'),
      ),
      body: FileList(),
    );
  }
}
