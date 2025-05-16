import 'package:flutter/material.dart';

class AnimatedSendButton extends StatelessWidget {
  final VoidCallback onPressed;
  final TextEditingController controller;

  const AnimatedSendButton({
    required this.onPressed,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: IconButton(
        icon: Icon(Icons.send),
        color: Colors.blue,      // 원하는 색상으로 지정
        onPressed: () {
          if (controller.text.trim().isNotEmpty) {
            onPressed();
          }
        },
      ),
    );
  }
}
