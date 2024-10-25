import 'package:flutter/material.dart';
import 'dart:async';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 5초 후에 /home으로 이동
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, '/home');
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(), // 로딩 인디케이터
            SizedBox(height: 20), // 간격
            Text(
              '스피치를 분석중입니다...',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
