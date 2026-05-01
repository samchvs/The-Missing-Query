import 'package:audioplayers/audioplayers.dart';
import 'package:graphics_project/core/constants/app_assets.dart';

class SFXController {
  static final SFXController _instance = SFXController._internal();
  factory SFXController() => _instance;

  SFXController._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  double _volume = 1.0;

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
    await _audioPlayer.setVolume(_volume);
    await _audioPlayer.play(AssetSource(AppAssets.buttonSound));
  }

  Future<void> playCorrectAnswer() async {
    await _audioPlayer.setVolume(_volume);
    await _audioPlayer.play(AssetSource(AppAssets.correctAnswerSound));
  }
}
