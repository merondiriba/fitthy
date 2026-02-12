import 'package:flutter/material.dart';

class ProgressHeader extends StatelessWidget {
  final int elapsedSeconds;
  final int totalSeconds;

  const ProgressHeader({
    super.key,
    required this.elapsedSeconds,
    required this.totalSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final value = totalSeconds == 0 ? 0.0 : (elapsedSeconds / totalSeconds).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(value: value),
        const SizedBox(height: 6),
        Text(
          _format(elapsedSeconds) + " / " + _format(totalSeconds),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _format(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }
}