import 'dart:convert'; // For jsonDecode
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:flutter/material.dart';
import 'package:pitches/app/markdown.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Detail(id: 'recording_1729921550', title: '스피치', time: '1일 전'),
      routes: {
        '/markdown': (context) =>
            MarkdownExample(id: '', description: '', emotion: ''),
        // 라우트 추가
      },
    );
  }
}

class Detail extends StatefulWidget {
  final String? id;
  final String? title; // 제목
  final String? time; // 시간
  final String? description; // Description field to be filled
  final bool? favorite;

  Detail({
    this.id,
    this.title,
    this.time,
    this.description,
    this.favorite,
  });

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  String? report; // To hold the fetched description
  String id = 'reporting';
  String description = '안녕하세요.';
  String emotion = 'EMO_UNKNOWN'; // Default emotion
  String startTime = '0초';
  String endTime = '16초';
  String speed = '적당함';

  bool isLoading = true; // To track loading state

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  Future<void> printHiveData() async {
    var box = await Hive.openBox('localdata');
    for (int i = 0; i < box.length; i++) {
      var data = box.getAt(i);
      print('데이터 $i:');
      print('  제목: ${data['title']}');
      print('  타임스탬프: ${data['timestamp']}');
      print('  웹엠 파일 크기: ${data['webmFile']?.length ?? 0} bytes'); // Null 체크 추가
      print('  설명: ${data['description']}');
      print('  즐겨찾기: ${data['favorite']}');
      print('  감정: ${data['emotion']}');
      print('  종료 시간: ${data['end_time']}');
      print('  말하기 속도: ${data['speech_rate']}');
      print('  시작 시간: ${data['start_time']}');
    }
  }

  Future<void> _fetchReport() async {
    final response = await http.get(
        Uri.parse('http://123.37.11.55:5000/report?filename=${widget.id}'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        final reportData = data[0];

        // Prepare the data to be saved in Hive
        final Map<String, dynamic> report = {
          'id': widget.id,
          'title': widget.title,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'webmFile': 'path/to/webm/file',
          'description': reportData['description'] ?? '설명이 없습니다.',
          'favorite': widget.favorite,
          'emotion': reportData['emotion'],
          'end_time': reportData['end_time'],
          'speech_rate': reportData['speech_rate'],
          'start_time': reportData['start_time'],
        };

        final box = Hive.box('localdata');

        setState(() {
          this.report = reportData['description'] ?? '설명이 없습니다.';
          id = widget.id ?? 'reporting';
          emotion = reportData['emotion'] ?? 'EMO_UNKNOWN';
          startTime = reportData['start_time'].toString();
          speed = reportData['speech_rate'].toString();
          endTime = reportData['end_time'].toString();
          description = widget.description ?? '안녕하세요.';
          isLoading = false;
        });
      }
      printHiveData();
    } else {
      print('Failed to load report: ${response.statusCode}.');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? '상세 정보'),
        leading: IconButton(
          icon: Text('<-', style: TextStyle(fontSize: 24, color: Colors.black)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF1E0E62).withOpacity(0.1),
                offset: Offset(0, -4),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            children: [
              // Grid section for start time, end time, emotion, speech rate
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildInfoCard("시작 시간", startTime ?? '정보 없음'),
                  _buildInfoCard("종료 시간", endTime ?? '정보 없음'),
                  _buildInfoCard("감정", emotion),
                  _buildInfoCard("말하기 속도", speed),
                ],
              ),

              SizedBox(height: 20),

              // Title and time section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.title ?? '제목 없음',
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('오늘',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
              SizedBox(height: 20),

              // Description container
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      child: Text(
                        description ?? '설명이 없습니다.',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF1E0E62).withOpacity(0.1),
                      offset: Offset(0, -4),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MarkdownExample(
                          id: id,
                          description: description,
                          emotion: emotion,
                        ),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "분석하기",
                      style: TextStyle(fontSize: 15, color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1E0E62).withOpacity(0.1),
            offset: Offset(0, 2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}