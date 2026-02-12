import 'session_phase.dart';
import '../domain/exercise.dart';

class SessionState {
  final List<Exercise> exercises;        // all exercises (some may be excluded)
  final int exerciseSeconds;             // configurable
  final int restSeconds;                 // configurable

  final int currentIndexInIncluded;      // index inside included list
  final SessionPhase phase;

  final int remainingSeconds;            // countdown for current phase
  final bool isRunning;

  // progress accounting
  final int elapsedSeconds;              // total elapsed session seconds (for top progress bar)
  final int totalPlannedSeconds;         // computed from included exercises * (exercise+rest) minus last rest if you want

  const SessionState({
    required this.exercises,
    required this.exerciseSeconds,
    required this.restSeconds,
    required this.currentIndexInIncluded,
    required this.phase,
    required this.remainingSeconds,
    required this.isRunning,
    required this.elapsedSeconds,
    required this.totalPlannedSeconds,
  });

  SessionState copyWith({
    List<Exercise>? exercises,
    int? exerciseSeconds,
    int? restSeconds,
    int? currentIndexInIncluded,
    SessionPhase? phase,
    int? remainingSeconds,
    bool? isRunning,
    int? elapsedSeconds,
    int? totalPlannedSeconds,
  }) {
    return SessionState(
      exercises: exercises ?? this.exercises,
      exerciseSeconds: exerciseSeconds ?? this.exerciseSeconds,
      restSeconds: restSeconds ?? this.restSeconds,
      currentIndexInIncluded: currentIndexInIncluded ?? this.currentIndexInIncluded,
      phase: phase ?? this.phase,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      totalPlannedSeconds: totalPlannedSeconds ?? this.totalPlannedSeconds,
    );
  }
}