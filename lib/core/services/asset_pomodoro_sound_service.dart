import 'package:audioplayers/audioplayers.dart';

import 'pomodoro_sound_service.dart';

/// Plays bundled completion sounds using a single [AudioPlayer] instance.
///
/// Stops any in-progress playback before starting a new sound.
/// All errors are swallowed internally — callers never see exceptions.
class AssetPomodoroSoundService implements PomodoroSoundService {
  AssetPomodoroSoundService();

  final AudioPlayer _player = AudioPlayer();
  bool _disposed = false;

  @override
  Future<void> playFocusCompleted() async {
    if (_disposed) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/focus_complete.mp3'));
    } catch (_) {
      // Swallow all audio errors
    }
  }

  @override
  Future<void> playBreakCompleted() async {
    if (_disposed) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/break_complete.mp3'));
    } catch (_) {
      // Swallow all audio errors
    }
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    try {
      await _player.dispose();
    } catch (_) {
      // Safe disposal
    }
  }
}
