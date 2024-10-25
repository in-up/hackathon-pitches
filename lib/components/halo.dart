import 'package:flutter/material.dart';
import '../app/now_record.dart';
import '../app/home.dart'; // HomeScreen 경로 확인

class BreathingButton extends StatefulWidget {
  final Color borderColor; // 버튼의 테두리 색상
  final Color pressedColor; // 버튼이 눌렸을 때 색상
  final bool isFromNowRecord; // 현재 화면에서 호출된 것인지 여부

  BreathingButton({
    this.borderColor = Colors.black,
    this.pressedColor = Colors.red,
    this.isFromNowRecord = false,
  });

  @override
  _BreathingButtonState createState() => _BreathingButtonState();
}

class _BreathingButtonState extends State<BreathingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isPressed = false; // 버튼이 눌렸는지 여부

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 120.0, end: 150.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.ease,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPressed() {
    setState(() {
      _isPressed = !_isPressed; // 버튼 눌림 상태 토글
    });
    print('Button pressed!');

    if (widget.isFromNowRecord) {
      // 현재 화면에서 호출되면 HomeScreen으로 돌아가기
      Navigator.of(context).pop(); // 이전 화면으로 돌아가기
    } else {
      // HomeScreen에서 호출되면 NowRecordScreen으로 이동
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NowRecordScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onPressed,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            width: _animation.value,
            height: _animation.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _isPressed ? widget.pressedColor : widget.borderColor, width: 25),
            ),
          );
        },
      ),
    );
  }
}
