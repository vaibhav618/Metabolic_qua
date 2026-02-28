import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioHelper {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isMuted = false;

  Future<void> playAudio(String assetPath) async {
    if (isMuted) return;

    try {
      if (_audioPlayer.state == PlayerState.playing) {
        await _audioPlayer.stop();
      }

      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      if (kDebugMode) print('❌ Error playing audio: $e');
    }
  }

  Future<void> playInhaleAudio() async => playAudio('audio/inhale_1.mp3');

  Future<void> playActivatingSensors() async =>
      playAudio("audio/activating_sensors.mp3");

  Future<void> playStartBreathTest() async =>
      playAudio('audio/start_breath_test.mp3');

  Future<void> playPlaceBreatheTube() async =>
      playAudio('audio/place_tube.mp3');

  Future<void> playExhaleAudio() async => playAudio('audio/exhale.mp3');

  Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      if (kDebugMode) print('❌ Error stopping audio: $e');
    }
  }

  Future<void> toggleMute() async {
    if (isMuted) {
      await _audioPlayer.setVolume(1.0);
      isMuted = false;
    } else {
      await _audioPlayer.setVolume(0.0);
      isMuted = true;
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
