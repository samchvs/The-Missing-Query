import 'package:audioplayers/audioplayers.dart';
import 'package:graphics_project/core/constants/app_assets.dart';

class SFXController {
  static final SFXController _instance = SFXController._internal();
  factory SFXController() => _instance;

  final AudioPlayer _audioPlayer = AudioPlayer();
  double _volume = 1.0;

  SFXController._internal() {
    _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
  }

  Future<void> setVolume(double volume) async {
    _volume = volume;
    await _audioPlayer.setVolume(volume);
  }

  double get volume => _volume;

  Future<void> playPopup() async {
    await _audioPlayer.setVolume(_volume);
    await _audioPlayer.play(AssetSource(AppAssets.popupSound));
  }

  Future<void> playButton() async {
    final player = AudioPlayer();
    await player.setVolume(_volume);
    await player.play(AssetSource('mystery/audio/button.mp3'));
  }

  Future<void> playCorrectAnswer() async {
    await _audioPlayer.setVolume(_volume);
    await _audioPlayer.play(AssetSource(AppAssets.correctAnswerSound));
  }
}
