import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../components/files.dart';
import '../components/halo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var mybox = Hive.box('localdata');
  List<Map<String, dynamic>> mydata = [];

  var myText = TextEditingController();

  @override
  void initState() {
    super.initState();
    getItem();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    getItem();
  }

  void addItem(Map<String, dynamic> data) async {
    await mybox.add(data);
    print(mybox.values);
    getItem();
  }

  void deleteItem(int index) {
    mybox.delete(mydata[index]['key']);
    getItem();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('삭제되었습니다'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void getItem() {
    setState(() {
      mydata = mybox.keys.map((e) {
        var res = mybox.get(e);
        return {'key': e, 'title': res['title']};
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Navigator.pushNamed(context, '/menu');
            },
          ),
          SizedBox(width: 10),
        ],
        title: Text(' Pitches.ai', style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, fontWeight: FontWeight.w900),),
      ),
      backgroundColor: Theme.of(context).canvasColor,
      body: SingleChildScrollView( // Scrollable하게 만들기
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 50),
            SizedBox(
              height: 250,
              child: Center(
                child: Center(
                  child: BreathingButton(borderColor: Color(0xFF1E0E62), onPressed: (){Navigator.pushNamed(context, '/record');},),
                ),
              ),
            ),
            Text(
              '버튼을 누르고\n스피치를 시작하세요',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 100,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white, // 배경색 설정
                borderRadius: BorderRadius.circular(20), // 둥근 테두리
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF1E0E62).withOpacity(0.1), // 그림자 색상
                    offset: Offset(0, -4), // 위쪽 방향으로 이동
                    blurRadius: 20, // 흐림 정도
                    spreadRadius: 4, // 그림자의 넓이
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: SizedBox(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            child: Text(
                              '최근 스피치',
                              textAlign: TextAlign.left,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: SizedBox(
                          height: 200,
                          child: FileList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 100,
            )
          ],
        ),
      ),
    );
  }
}
