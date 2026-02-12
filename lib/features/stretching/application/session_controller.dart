import 'dart:async';
// import 'package:fitthy/core/audio/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../domain/exercise.dart';
import '../domain/session_phase.dart';
import '../domain/session_state.dart';
import '../data/default_exercises.dart';
import '../../../core/audio/audioplayers.dart';

final sessionControllerProvider =
StateNotifierProvider<SessionController, SessionState>((ref) {
  return SessionController();
});

class SessionController extends StateNotifier<SessionState> {
  Timer? _timer;

  SessionController()
      : super(
    SessionState(
      exercises: defaultExercises,
      exerciseSeconds: 30,
      restSeconds: 10,
      currentIndexInIncluded: 0,
      phase: SessionPhase.exercise,
      remainingSeconds: 30,
      isRunning: false,
      elapsedSeconds: 0,
      totalPlannedSeconds: _computeTotal(defaultExercises, 30, 10),
    ),
  );

  static int _computeTotal(List<Exercise> all, int ex, int rest) {
    final included = all.where((e) => e.included).toList();
    if (included.isEmpty) return 0;

    // Option A: rest after every exercise except last
    return included.length * ex + (included.length - 1) * rest;
  }

  List<Exercise> get _included => state.exercises.where((e) => e.included).toList();

  Exercise? get currentExercise {
    final inc = _included;
    if (inc.isEmpty) return null;
    final idx = state.currentIndexInIncluded.clamp(0, inc.length - 1);
    return inc[idx];
  }

  void start() async {
    if (state.isRunning) return;
    if (_included.isEmpty) return;

    await WakelockPlus.enable(); //  prevent sleep

    state = state.copyWith(isRunning: true);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void pause() async {
    if (!state.isRunning) return;
    _timer?.cancel();
    _timer = null;
    await WakelockPlus.disable(); // allow sleep again
    state = state.copyWith(isRunning: false);
  }

  void reset() {
    pause();
    final total = _computeTotal(state.exercises, state.exerciseSeconds, state.restSeconds);
    state = state.copyWith(
      currentIndexInIncluded: 0,
      phase: SessionPhase.exercise,
      remainingSeconds: state.exerciseSeconds,
      elapsedSeconds: 0,
      totalPlannedSeconds: total,
    );
  }

  void setExerciseSeconds(int seconds) {
    final s = seconds.clamp(5, 600);
    final total = _computeTotal(state.exercises, s, state.restSeconds);

    // If we are currently in exercise phase, keep UX consistent by snapping remaining to new duration
    final newRemaining = (state.phase == SessionPhase.exercise) ? s : state.remainingSeconds;

    state = state.copyWith(
      exerciseSeconds: s,
      totalPlannedSeconds: total,
      remainingSeconds: newRemaining,
    );
  }

  void setRestSeconds(int seconds) {
    final s = seconds.clamp(0, 300);
    final total = _computeTotal(state.exercises, state.exerciseSeconds, s);

    final newRemaining = (state.phase == SessionPhase.rest) ? s : state.remainingSeconds;

    state = state.copyWith(
      restSeconds: s,
      totalPlannedSeconds: total,
      remainingSeconds: newRemaining,
    );
  }

  void toggleInclude(String exerciseId) {
    final updated = state.exercises.map((e) {
      if (e.id == exerciseId) return e.copyWith(included: !e.included);
      return e;
    }).toList();

    final total = _computeTotal(updated, state.exerciseSeconds, state.restSeconds);
    final included = updated.where((e) => e.included).toList();

    // Keep currentIndex valid after include/exclude changes
    final newIndex = included.isEmpty
        ? 0
        : state.currentIndexInIncluded.clamp(0, included.length - 1);

    // If none included -> finish session
    final phase = included.isEmpty ? SessionPhase.finished : state.phase;

    state = state.copyWith(
      exercises: updated,
      totalPlannedSeconds: total,
      currentIndexInIncluded: newIndex,
      phase: phase,
      isRunning: included.isEmpty ? false : state.isRunning,
    );
  }

  void next({bool countAsSkip = true}) {
    final inc = _included;
    if (inc.isEmpty) return;

    final isLast = state.currentIndexInIncluded >= inc.length - 1;

    // If skipping, we should also adjust elapsed so progress bar doesn't “lie”
    // Simple approach: treat skip as completing remaining time in current phase instantly
    final delta = countAsSkip ? state.remainingSeconds : 0;

    if (isLast && state.phase == SessionPhase.exercise) {
      // last exercise completed -> finished
      pause();
      state = state.copyWith(
        phase: SessionPhase.finished,
        remainingSeconds: 0,
        elapsedSeconds: (state.elapsedSeconds + delta).clamp(0, state.totalPlannedSeconds),
        isRunning: false,
      );
      return;
    }

    if (state.phase == SessionPhase.exercise) {
      // move to rest (unless it's last exercise)
      state = state.copyWith(
        phase: SessionPhase.rest,
        remainingSeconds: state.restSeconds,
        elapsedSeconds: (state.elapsedSeconds + delta).clamp(0, state.totalPlannedSeconds),
      );
    } else if (state.phase == SessionPhase.rest) {
      // move to next exercise
      final newIndex = (state.currentIndexInIncluded + 1).clamp(0, inc.length - 1);
      state = state.copyWith(
        phase: SessionPhase.exercise,
        remainingSeconds: state.exerciseSeconds,
        currentIndexInIncluded: newIndex,
        elapsedSeconds: (state.elapsedSeconds + delta).clamp(0, state.totalPlannedSeconds),
      );
    }
  }

  void prev() {
    final inc = _included;
    if (inc.isEmpty) return;

    final newIndex = (state.currentIndexInIncluded - 1).clamp(0, inc.length - 1);
    // go back to exercise phase
    state = state.copyWith(
      currentIndexInIncluded: newIndex,
      phase: SessionPhase.exercise,
      remainingSeconds: state.exerciseSeconds,
    );
  }
  void _tick() async {
    if (!state.isRunning) return;
    if (state.phase == SessionPhase.finished) return;

    final remaining = state.remainingSeconds - 1;
    final newElapsed =
    (state.elapsedSeconds + 1).clamp(0, state.totalPlannedSeconds);

    // 🔊 SOUND LOGIC (last 3 seconds)
    if (remaining >= 0 && remaining < 3) {
      if (state.phase == SessionPhase.exercise) {
        SoundService.playExerciseTick();
      } else if (state.phase == SessionPhase.rest) {
        SoundService.playRestBeep();
      }
    }

    if (remaining > 0) {
      state = state.copyWith(
        remainingSeconds: remaining,
        elapsedSeconds: newElapsed,
      );
      return;
    }

    // ⏭ Phase transition
    if (state.phase == SessionPhase.exercise) {
      final inc = _included;
      final isLast = state.currentIndexInIncluded >= inc.length - 1;

      if (isLast) {
        await WakelockPlus.disable();
        pause();
        state = state.copyWith(
          phase: SessionPhase.finished,
          remainingSeconds: 0,
          elapsedSeconds: newElapsed,
          isRunning: false,
        );
      } else {
        state = state.copyWith(
          phase: SessionPhase.rest,
          remainingSeconds: state.restSeconds,
          elapsedSeconds: newElapsed,
        );
      }
    } else if (state.phase == SessionPhase.rest) {
      final inc = _included;
      final newIndex =
      (state.currentIndexInIncluded + 1).clamp(0, inc.length - 1);

      state = state.copyWith(
        phase: SessionPhase.exercise,
        remainingSeconds: state.exerciseSeconds,
        currentIndexInIncluded: newIndex,
        elapsedSeconds: newElapsed,
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}