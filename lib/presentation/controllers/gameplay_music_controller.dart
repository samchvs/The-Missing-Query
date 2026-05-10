import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:graphics_project/core/constants/app_assets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameplayMusicController with WidgetsBindingObserver {
  static final GameplayMusicController _instance = GameplayMusicController._internal();
  factory GameplayMusicController() => _instance;

  GameplayMusicController._internal() {
    WidgetsBinding.instance.addObserver(this);
    _loadVolume();
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isExpectedToPlay = false;
  double _volume = 1.0;

  Future<void> _loadVolume() async {
    final prefs = await SharedPreferences.getInstance();
    _volume = prefs.getDouble('music_volume') ?? 1.0;
    await _audioPlayer.setVolume(_volume);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.detached) {
      if (_audioPlayer.state == PlayerState.playing) {
        _audioPlayer.pause();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_isExpectedToPlay && _audioPlayer.state != PlayerState.playing) {
        _audioPlayer.resume();
      }
    }
  }
  Future<void> setVolume(double volume) async {
    _volume = volume;
    await _audioPlayer.setVolume(volume);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('music_volume', volume);
  }

  double get volume => _volume;

  Future<void> play() async {
    try {
      _isExpectedToPlay = true;
      
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(_volume); 
      
      if (_audioPlayer.state == PlayerState.playing) return;
      
      if (_audioPlayer.state == PlayerState.paused) {
        await _audioPlayer.resume();
      } else {
        await _audioPlayer.play(AssetSource(AppAssets.gameplayMusic));
      }
    } catch (e) {
      debugPrint("Error playing gameplay music: $e");
    }
  }

  Future<void> stop() async {
    try {
      _isExpectedToPlay = false;
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint("Error stopping gameplay music: $e");
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer.dispose();
  }
}
