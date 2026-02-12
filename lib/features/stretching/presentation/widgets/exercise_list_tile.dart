import 'package:flutter/material.dart';
import '../../domain/exercise.dart';

class ExerciseListTile extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onToggle;

  const ExerciseListTile({
    super.key,
    required this.exercise,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          exercise.assetPath,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
        ),
      ),
      title: Center(
        child: Text(
          exercise.name,
          textAlign: TextAlign.left,
        ),
      ),
      trailing: Checkbox(
        value: exercise.included,
        onChanged: (_) => onToggle(),
      ),
    );
  }
}