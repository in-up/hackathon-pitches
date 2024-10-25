import 'package:flutter/material.dart';

class BreathingButton extends StatefulWidget {
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

    // ElasticTween을 사용하여 애니메이션 적용
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
    print('Button pressed!');
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
              border: Border.all(color: Colors.black, width: 25),
            ),
          );
        },
      ),
    );
  }
}
