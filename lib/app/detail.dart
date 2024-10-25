import "package:flutter/material.dart";

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Detail());
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
            '☰', // 메뉴 이모지 (햄버거 아이콘)
            style: TextStyle(fontSize: 24),
          ),
          onPressed: () {
            // 메뉴 버튼 클릭 시 수행할 동작
          },
        ),
      ),
      body: SingleChildScrollView( // 스크롤 가능하게 만듦
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20), // 상하좌우 패딩
              margin: EdgeInsets.symmetric(horizontal: 50, vertical: 30), // 마진 추가
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255), // 배경색
                borderRadius: BorderRadius.circular(15), // 둥근 모서리
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26, // 그림자 색
                    blurRadius: 8, // 흐림 반경
                    offset: Offset(0, 4), // 그림자의 위치
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // 좌우 간격 조정
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // 좌측 정렬
                    children: [
                      Text(
                        "총점",
                        style: TextStyle(fontSize: 18, color: Colors.black), // 글자 크기 줄임
                      ),
                      SizedBox(height: 1), // 총점과 96.5 사이 간격
                      Text(
                        "96.5",
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black), // 글자 크기 늘림
                      ),
                    ],
                  ),
                  Flexible( // Flexible로 감싸서 가변적인 크기 지원
                    child: Container(
                      margin: EdgeInsets.only(left: 20), // 막대의 마진
                      height: 20, // 막대의 높이
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.horizontal(left: Radius.circular(10)), // 좌측 둥글게
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
                                borderRadius: BorderRadius.horizontal(right: Radius.circular(10)), // 우측 둥글게
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
            Container(
              padding: EdgeInsets.all(20), // 상하좌우 패딩
              margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10), // 마진 추가
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255), // 배경색
                borderRadius: BorderRadius.circular(15), // 둥근 모서리
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26, // 그림자 색
                    blurRadius: 8, // 흐림 반경
                    offset: Offset(0, 4), // 그림자의 위치
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20, // 프로필 아이콘 크기
                        backgroundColor: Colors.grey, // 배경색
                        child: Icon(Icons.person, color: Colors.white), // 프로필 아이콘
                      ),
                      SizedBox(width: 10), // 아이콘과 사용자명 사이 간격
                      Text(
                        '사용자명', // 사용자명
                        style: TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                  SizedBox(height: 20), // 위젯 간 간격
                  Container(
                    width: double.infinity, // 부모의 너비에 맞추기
                    padding: EdgeInsets.all(20), // 상하좌우 패딩
                    color: Colors.grey[300], // 회색 배경색
                    child: Text(
                      "게임은 즐기기 위해서 만들어진다. 애초에 놀이에서 출발해서 다른 의미 또한 가지게 되므로 본질은 재미에 있다. 그렇다면 인생은 어떤가. 인생은 분명 재미있기 위해 만들어지지는 않았을 것이다. 그리고 인생이라는게 애초에 만들어진 것인가 또한 의문이다.",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
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
