import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:graphics_project/core/constants/app_assets.dart';

class HomeMusicController with WidgetsBindingObserver {
  static final HomeMusicController _instance = HomeMusicController._internal();
  factory HomeMusicController() => _instance;

  HomeMusicController._internal() {
    WidgetsBinding.instance.addObserver(this);
    // Audio context is shared via AudioPlayer.global, 
    // but we can ensure it's set if this is the first controller initialized.
    final audioContext = AudioContext(
      android: const AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: false,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.none, // Allow SFX to play on top without ducking
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: const {
          AVAudioSessionOptions.mixWithOthers,
        },
      ),
    );
    AudioPlayer.global.setAudioContext(audioContext);
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isExpectedToPlay = false;

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

  double _volume = 1.0;

  Future<void> setVolume(double volume) async {
    _volume = volume;
    await _audioPlayer.setVolume(volume);
  }

  double get volume => _volume;

  Future<void> play() async {
    try {
      _isExpectedToPlay = true;
      if (_audioPlayer.state == PlayerState.playing) return;
      
      debugPrint("Attempting to play home music: ${AppAssets.homeMusic}");
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(_volume); 
      
      // Small delay to ensure player is ready
      await Future.delayed(const Duration(milliseconds: 200));
      
      await _audioPlayer.play(AssetSource(AppAssets.homeMusic));
      debugPrint("Home music play command sent successfully.");
    } catch (e) {
      debugPrint("Error playing home music: $e");
    }
  }

  Future<void> stop() async {
    try {
      _isExpectedToPlay = false;
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint("Error stopping home music: $e");
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer.dispose();
  }
}
