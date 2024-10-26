import 'package:flutter/material.dart';
import '../app/now_record.dart'; // 필요에 따라 임포트
import '../app/home.dart'; // HomeScreen 경로 확인

class BreathingButton extends StatefulWidget {
  final Color borderColor; // 버튼의 테두리 색상
  final VoidCallback? onPressed; // 클릭 시 호출될 콜백
  final double? size; // 버튼의 크기

  BreathingButton({
    this.borderColor = const Color(0xFF1E0E62),
    this.onPressed,
    this.size, // 크기 매개변수 추가
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

    double startSize = widget.size ?? 120.0;
    double endSize = widget.size != null ? 150.0 : startSize + 30;

    _animation = Tween<double>(begin: startSize, end: endSize).animate(
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
