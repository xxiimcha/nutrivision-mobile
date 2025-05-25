import 'package:audioplayers/audioplayers.dart';

class RingtonePlayer {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> play() async {
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource('sounds/incoming.mp3')); // Add this file
  }

  static Future<void> stop() async {
    await _player.stop();
  }
}
