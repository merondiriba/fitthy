import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/session_controller.dart';
import '../widgets/exercise_list_tile.dart';

class ExercisesSettingsScreen extends ConsumerWidget {
  const ExercisesSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sessionControllerProvider);
    final ctrl = ref.read(sessionControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Exercises & Settings"),
      ),
      body: Column(
        children: [
          // ⏱ Global timers config
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _TimerConfigTile(
                  label: "Stretch Duration",
                  seconds: state.exerciseSeconds,
                  onMinus: () => ctrl.setExerciseSeconds(state.exerciseSeconds - 5),
                  onPlus: () => ctrl.setExerciseSeconds(state.exerciseSeconds + 5),
                ),
                const SizedBox(height: 12),
                _TimerConfigTile(
                  label: "Rest Duration",
                  seconds: state.restSeconds,
                  onMinus: () => ctrl.setRestSeconds(state.restSeconds - 5),
                  onPlus: () => ctrl.setRestSeconds(state.restSeconds + 5),
                ),
                const SizedBox(height: 12),
                _TotalTimeInfo(
                  totalSeconds: state.totalPlannedSeconds,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: ReorderableListView.builder(
              itemCount: state.exercises.length,
              onReorder: (oldIndex, newIndex) {
                ctrl.reorderExercises(oldIndex, newIndex);
              },
              buildDefaultDragHandles: true,
              itemBuilder: (context, index) {
                final exercise = state.exercises[index];

                return Container(
                  key: ValueKey(exercise.id), // 🔥 REQUIRED for reorder
                  child: Column(
                    children: [
                      ExerciseListTile(
                        exercise: exercise,
                        onToggle: () => ctrl.toggleInclude(exercise.id),
                      ),
                      const Divider(height: 1),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerConfigTile extends StatelessWidget {
  final String label;
  final int seconds;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _TimerConfigTile({
    required this.label,
    required this.seconds,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "$label: ${seconds}s",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: onMinus,
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: onPlus,
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalTimeInfo extends StatelessWidget {
  final int totalSeconds;

  const _TotalTimeInfo({required this.totalSeconds});

  @override
  Widget build(BuildContext context) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Total Session Time"),
        Text(
          "${minutes}m ${seconds}s",
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}