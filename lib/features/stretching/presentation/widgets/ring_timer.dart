import 'package:flutter/material.dart';

class RingTimer extends StatelessWidget {
  final Widget child;
  final double progress; // 0..1
  final double size;
  final double strokeWidth;

  const RingTimer({
    super.key,
    required this.child,
    required this.progress,
    this.size = 280,
    this.strokeWidth = 10,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);

    final innerSize = size - strokeWidth * 2 - 12;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 🔵 Circular timer ring
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: clamped,
              strokeWidth: strokeWidth,
            ),
          ),

          // 🟢 Circular cropped image
          ClipOval(
            child: SizedBox(
              width: innerSize,
              height: innerSize,
              child: FittedBox(
                fit: BoxFit.cover,
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}