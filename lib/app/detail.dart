import 'package:flutter/material.dart';
import 'package:pitches/app/markdown.dart';
import '../domain/repositories/report_repository.dart';
import '../domain/models/report_model.dart';
import '../services/api/http_api_service.dart';
import '../services/storage/hive_storage_service.dart';
import '../core/constants/color_constants.dart';
import '../core/constants/message_constants.dart';

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
  late final ReportRepository _reportRepository;
  ReportModel? _report;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _reportRepository = ReportRepository(
      apiService: HttpApiService(),
      storageService: HiveStorageService(),
    );
    _fetchReport();
  }

  Future<void> _fetchReport() async {
    if (widget.id == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final report = await _reportRepository.fetchReport(widget.id!);

      if (report != null) {
        await _reportRepository.updateLocalRecordingWithReport(
          widget.id!,
          report,
        );

        setState(() {
          _report = report;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('${MessageConstants.reportLoadFailedMessage}: $e');
      setState(() => _isLoading = false);
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
      body: _isLoading
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
                color: ColorConstants.shadowColor,
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
                  _buildInfoCard("시작 시간", _report?.startTime.toString() ?? '정보 없음'),
                  _buildInfoCard("종료 시간", _report?.endTime.toString() ?? '정보 없음'),
                  _buildInfoCard("감정", _report?.emotion ?? 'EMO_UNKNOWN'),
                  _buildInfoCard("말하기 속도", _report?.speechRate.toString() ?? '정보 없음'),
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
                        widget.description ?? _report?.description ?? '설명이 없습니다.',
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
                      color: ColorConstants.shadowColor,
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
                          id: widget.id ?? 'reporting',
                          description: widget.description ?? _report?.description ?? '설명이 없습니다.',
                          emotion: _report?.emotion ?? 'EMO_UNKNOWN',
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
            color: ColorConstants.shadowColor,
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