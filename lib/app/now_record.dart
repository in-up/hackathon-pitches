import 'package:flutter/material.dart';
import '../components/halo.dart'; // BreathingButton의 경로 확인

class NowRecordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            SizedBox(height: 100),
            SizedBox(
              height: 200,
              child: Center(
                child: BreathingButton(
                  isFromNowRecord: true, // 현재 화면에서 호출되므로 true로 설정
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
