import 'package:flutter/material.dart';
import 'package:pitches/app/markdown.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Detail(),
      routes: {
        '/markdown': (context) => MarkdownExample(), // 라우트 추가
      },
    );
  }
}

class Detail extends StatefulWidget {
  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SSAFY 면접 준비"),
        leading: IconButton(
          icon: Text(
            '☰',
            style: TextStyle(fontSize: 24),
          ),
          onPressed: () {
            // 메뉴 버튼 클릭 시 수행할 동작
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 첫 번째 컨테이너
            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.symmetric(horizontal: 50, vertical: 30),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
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
                      margin: EdgeInsets.only(left: 20),
                      height: 20,
                      child: Row(
                        children: [
                          Expanded(child: Container(color: Colors.red)),
                          Expanded(child: Container(color: Colors.orange)),
                          Expanded(child: Container(color: Colors.yellow)),
                          Expanded(child: Container(color: Colors.green)),
                          Expanded(child: Container(color: Colors.blue)),
                          Expanded(child: Container(color: Colors.purple)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 두 번째 컨테이너
            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "게임은 즐기기 위해서 만들어진다.",
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
    );
  }
}


void main() {
  runApp(MyApp());
}
