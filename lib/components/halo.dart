import 'package:flutter/material.dart';
import '../app/now_record.dart'; // 필요에 따라 임포트
import '../app/home.dart'; // HomeScreen 경로 확인

class BreathingButton extends StatefulWidget {
  final Color borderColor; // 버튼의 테두리 색상
  final VoidCallback? onPressed; // 클릭 시 호출될 콜백

  BreathingButton({
    this.borderColor = const Color(0xFF1E0E62),
    this.onPressed,
  });

  @override
  _BreathingButtonState createState() => _BreathingButtonState();
}

class _BreathingButtonState extends State<BreathingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.onPressed != null) {
          widget.onPressed!();
        }
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            width: _animation.value,
            height: _animation.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: widget.borderColor, width: 30),
            ),
          );
        },
      ),
    );
  }
}
