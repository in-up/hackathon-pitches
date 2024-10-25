import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:pitches/components/files.dart';

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
        // title: Text('Pitches', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            // 햄버거 메뉴 버튼 클릭 시 처리
          },
        ),
        actions: [
          CircleAvatar(
            backgroundImage: NetworkImage('https://picsum.photos/200'),
          ),
          SizedBox(width: 10),
        ],
      ),
      backgroundColor: Theme.of(context).canvasColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(
              height: 100,
            ),
            SizedBox(
              height: 200,
              child: Center(
                  child: Column(
                children: [
                  BreathingButton(),
                ],
              )),
            ),
            Text(
              '버튼을 누르고\n스피치를 시작하세요',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            Container(
              height: 200, // 원하는 높이로 설정
              child: FileList(),
            ),
          ],
        ),
      ),
    );
  }
}
