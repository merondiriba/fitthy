import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _exercisePlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);

  static final AudioPlayer _restPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);

  static Future<void> playExerciseTick() async {
    await _exercisePlayer.stop(); // 🔴 important
    await _exercisePlayer.play(
      AssetSource('sounds/exercise_tick.wav'),
      volume: 1.0,
    );
  }

  static Future<void> playRestBeep() async {
    await _restPlayer.stop();
    await _restPlayer.play(
      AssetSource('sounds/rest_beep.wav'),
      volume: 1.0,
    );
  }
}