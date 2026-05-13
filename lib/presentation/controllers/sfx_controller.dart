import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:graphics_project/core/constants/app_assets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SFXController {
  static final SFXController _instance = SFXController._internal();
  factory SFXController() => _instance;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _buttonPlayer = AudioPlayer();
  double _volume = 1.0;

  SFXController._internal() {
    _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
    _buttonPlayer.setPlayerMode(PlayerMode.lowLatency);
    _loadVolume();
  }

  Future<void> _loadVolume() async {
    final prefs = await SharedPreferences.getInstance();
    _volume = prefs.getDouble('sfx_volume') ?? 1.0;
    await _audioPlayer.setVolume(_volume);
    await _buttonPlayer.setVolume(_volume);
    debugPrint("SFX Volume loaded: $_volume");
  }

  Future<void> setVolume(double volume) async {
    _volume = volume;
    await _audioPlayer.setVolume(volume);
    await _buttonPlayer.setVolume(volume);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sfx_volume', volume);
  }

  double get volume => _volume;

  Future<void> playPopup() async {
    await _audioPlayer.setVolume(_volume);
    await _audioPlayer.play(AssetSource(AppAssets.popupSound), volume: _volume);
  }

  Future<void> playButton() async {
    await _buttonPlayer.stop();
    await _buttonPlayer.setVolume(_volume);
    await _buttonPlayer.play(AssetSource('mystery/audio/button.mp3'), volume: _volume);
  }

  Future<void> playCorrectAnswer() async {
    await _audioPlayer.setVolume(_volume);
    await _audioPlayer.play(AssetSource(AppAssets.correctAnswerSound), volume: _volume);
  }
}
