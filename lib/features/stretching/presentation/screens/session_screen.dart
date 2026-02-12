import 'package:fitthy/features/stretching/presentation/screens/exercises_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/session_controller.dart';
import '../../domain/session_phase.dart';
import '../widgets/ring_timer.dart';
import '../widgets/progress_header.dart';

class SessionScreen extends ConsumerWidget {
  const SessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sessionControllerProvider);
    final ctrl = ref.read(sessionControllerProvider.notifier);

    final current = ctrl.currentExercise;
    final duration = state.phase == SessionPhase.exercise ? state.exerciseSeconds : state.restSeconds;
    final progress = duration == 0 ? 1.0 : (state.remainingSeconds / duration).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Stretching"),
        actions: [
          IconButton(
            onPressed: () => ctrl.reset(),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExercisesSettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ProgressHeader(
              elapsedSeconds: state.elapsedSeconds,
              totalSeconds: state.totalPlannedSeconds,
            ),
            const SizedBox(height: 16),

            Text(
              state.phase == SessionPhase.exercise
                  ? "Stretch"
                  : state.phase == SessionPhase.rest
                  ? "Rest"
                  : "Finished",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            if (current == null)
              const Expanded(
                child: Center(child: Text("No exercises included. Enable at least one.")),
              )
            else
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RingTimer(
                      progress: progress, // shrinking ring
                      child: Image.asset(current.assetPath, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 14),
                    Text(current.name, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 10),
                    Text(
                      "${state.remainingSeconds}s",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: current == null ? null : () => ctrl.prev(),
                  icon: const Icon(Icons.skip_previous),
                  iconSize: 36,
                ),
                IconButton(
                  onPressed: current == null
                      ? null
                      : () => state.isRunning ? ctrl.pause() : ctrl.start(),
                  icon: Icon(state.isRunning ? Icons.pause_circle : Icons.play_circle),
                  iconSize: 52,
                ),
                IconButton(
                  onPressed: current == null ? null : () => ctrl.next(countAsSkip: true),
                  icon: const Icon(Icons.skip_next),
                  iconSize: 36,
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Config timers
            // Row(
            //   children: [
            //     Expanded(
            //       child: _TimerStepper(
            //         label: "Stretch",
            //         seconds: state.exerciseSeconds,
            //         onMinus: () => ctrl.setExerciseSeconds(state.exerciseSeconds - 5),
            //         onPlus: () => ctrl.setExerciseSeconds(state.exerciseSeconds + 5),
            //       ),
            //     ),
            //     const SizedBox(width: 12),
            //     Expanded(
            //       child: _TimerStepper(
            //         label: "Rest",
            //         seconds: state.restSeconds,
            //         onMinus: () => ctrl.setRestSeconds(state.restSeconds - 5),
            //         onPlus: () => ctrl.setRestSeconds(state.restSeconds + 5),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}

class _TimerStepper extends StatelessWidget {
  final String label;
  final int seconds;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _TimerStepper({
    required this.label,
    required this.seconds,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            Expanded(child: Text("$label: ${seconds}s")),
            IconButton(onPressed: onMinus, icon: const Icon(Icons.remove)),
            IconButton(onPressed: onPlus, icon: const Icon(Icons.add)),
          ],
        ),
      ),
    );
  }
}