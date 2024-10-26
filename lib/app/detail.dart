import 'package:flutter/material.dart';
import 'package:pitches/app/markdown.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Detail(id:'recording_id', title: '스피치', time: '1일 전'),
      routes: {
        '/markdown': (context) => MarkdownExample(), // 라우트 추가
      },
    );
  }
}

class Detail extends StatefulWidget {
  final String? id;
  final String? title; // 제목
  final String? time; // 시간
  final String? description;
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? '상세 정보'), // title을 widget으로 접근
        leading: IconButton(
          icon: Text(
            '<-', // 뒤로가기 이모지로 변경
            style: TextStyle(fontSize: 24, color: Colors.black),
          ),
          onPressed: () {
            Navigator.pop(context); // 이전 페이지로 돌아가기
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // title과 time을 포함하는 부분
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // 좌우 정렬
                children: [
                  Text(
                    widget.title ?? '제목 없음', // title을 넣음
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.time ?? '', // time을 오른쪽에 배치
                    style: TextStyle(fontSize: 16, color: Colors.grey), // 스타일 조정
                  ),
                ],
              ),
              SizedBox(height: 20), // 간격 조정

              // 첫 번째 컨테이너
              Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "총점",
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                        SizedBox(height: 1),
                        Text(
                          "96.5",
                          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ],
                    ),
                    Flexible(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.7, // 화면 너비의 80%로 설정
                        height: 10, // 높이를 줄여서 막대를 더 얇게
                        decoration: BoxDecoration(
                          color: Colors.transparent, // 투명하게 설정
                          borderRadius: BorderRadius.circular(5), // 둥글게 만들기
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(5),
                                    bottomLeft: Radius.circular(5),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                color: Colors.orange,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                color: Colors.yellow,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                color: Colors.green,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                color: Colors.blue,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.purple,
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(5),
                                    bottomRight: Radius.circular(5),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),


                  ],
                ),
              ),
              // 두 번째 컨테이너
              Container(
                padding: EdgeInsets.all(20), // 패딩 설정
                margin: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.pink[100], // 연한 핑크색
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity, // 가로 길이를 최대화
                      child: Text(
                        widget.description ?? '',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30), // 간격 조정
              Container(
                margin: EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/markdown'); // 라우트 이동
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "분석하기",
                    style: TextStyle(fontSize: 15, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),

        ),
      ),
    );
  }
} 